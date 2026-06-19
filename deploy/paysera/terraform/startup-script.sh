#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# startup-script.sh — Paysera Open Design VM bootstrap
#
# Rendered by Terraform via templatefile(). The following $${...} tokens are
# Terraform template variables, NOT shell expansions:
#   ${artifact_registry_host}   e.g. europe-west1-docker.pkg.dev
#   ${cloudflared_secret_name}  Secret Manager secret ID for the tunnel token
#   ${data_disk_device_name}    guest device id -> /dev/disk/by-id/google-<name>
#   ${host_data_dir}            host mount + container OD_DATA_DIR source
#   ${project_id}               GCP project id
#
# Every real shell variable in this file is written as $${VAR} so Terraform
# leaves it untouched and the guest shell expands it at runtime.
#
# Responsibilities (all idempotent — re-runs on every boot):
#   1. Install Docker engine + compose plugin.
#   2. Format (first boot only) and mount the data disk at ${host_data_dir}.
#   3. Ensure uid 1001 (the container's "open-design" user) can write the data.
#   4. Authenticate Docker to Artifact Registry via the VM service account.
#   5. Fetch the cloudflared connector token from Secret Manager into an env file.
#   6. Write docker-compose.yml from instance metadata and `docker compose up -d`.
# ---------------------------------------------------------------------------
set -euo pipefail

log() { echo "[open-design-bootstrap] $${*}"; }

export DEBIAN_FRONTEND=noninteractive

# --- 1. Docker engine + compose plugin -------------------------------------

if ! command -v docker >/dev/null 2>&1; then
  log "Installing Docker engine + compose plugin"
  apt-get update -y
  apt-get install -y ca-certificates curl gnupg jq

  install -m 0755 -d /etc/apt/keyrings
  if [ ! -f /etc/apt/keyrings/docker.asc ]; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
      -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc
  fi

  . /etc/os-release
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu $${VERSION_CODENAME} stable" \
    > /etc/apt/sources.list.d/docker.list

  apt-get update -y
  apt-get install -y \
    docker-ce docker-ce-cli containerd.io \
    docker-buildx-plugin docker-compose-plugin

  systemctl enable --now docker
else
  log "Docker already present; skipping install"
fi

# gcloud ships in Google's Ubuntu images; guard anyway.
if ! command -v gcloud >/dev/null 2>&1; then
  log "ERROR: gcloud not found on image; cannot auth to Artifact Registry / Secret Manager"
  exit 1
fi

# --- 2. Format + mount the data disk (idempotent) --------------------------

DATA_DEVICE="/dev/disk/by-id/google-${data_disk_device_name}"
DATA_DIR="${host_data_dir}"

log "Waiting for data disk at $${DATA_DEVICE}"
for _ in $(seq 1 30); do
  [ -b "$${DATA_DEVICE}" ] && break
  sleep 2
done
if [ ! -b "$${DATA_DEVICE}" ]; then
  log "ERROR: data disk $${DATA_DEVICE} not found"
  exit 1
fi

# Format only if the disk has no filesystem yet (first boot). blkid is empty
# on a raw disk; this guard makes re-runs safe and never reformats data.
if ! blkid "$${DATA_DEVICE}" >/dev/null 2>&1; then
  log "No filesystem on $${DATA_DEVICE}; creating ext4 (first boot)"
  mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard "$${DATA_DEVICE}"
else
  log "Filesystem already present on $${DATA_DEVICE}; not formatting"
fi

mkdir -p "$${DATA_DIR}"

# Persist the mount via fstab keyed on UUID (stable across device reorders).
DATA_UUID="$(blkid -s UUID -o value "$${DATA_DEVICE}")"
if ! grep -q "$${DATA_UUID}" /etc/fstab; then
  log "Adding $${DATA_DIR} to /etc/fstab"
  echo "UUID=$${DATA_UUID} $${DATA_DIR} ext4 discard,defaults,nofail 0 2" >> /etc/fstab
fi

if ! mountpoint -q "$${DATA_DIR}"; then
  log "Mounting $${DATA_DIR}"
  mount "$${DATA_DIR}"
fi

# --- 3. Ownership for the container's open-design user (uid/gid 1001) -------
# The container runs as uid 1001; the bind-mounted data dir must be writable by
# that uid. We chown the host directory to 1001:1001 so OD_DATA_DIR works.
# See root AGENTS.md "Daemon data directory contract": all daemon data derives
# from OD_DATA_DIR -> RUNTIME_DATA_DIR, so this one mount is the data root.
log "Setting ownership of $${DATA_DIR} to uid:gid 1001:1001"
chown -R 1001:1001 "$${DATA_DIR}"
chmod 0750 "$${DATA_DIR}"

# --- 4. Docker auth to Artifact Registry via the VM service account ---------
# The VM SA has roles/artifactregistry.reader. configure-docker installs the
# gcloud credential helper for the registry host; pulls then use the SA token.
log "Configuring Docker auth for ${artifact_registry_host}"
gcloud auth configure-docker "${artifact_registry_host}" --quiet

# --- 5. Assemble app.env from Secret Manager -------------------------------
# A single root-only env file consumed by docker compose. Secret VALUES flow
# from gcloud straight into the file (never echoed to logs). Secrets are treated
# as OPTIONAL here so the VM boots and open-design serves immediately even
# before the human-supplied secrets (Google OAuth client, Cloudflare tunnel
# token) exist; the dependent service simply stays down until its secret is
# added and the stack is re-upped. The litellm key should be present so
# generation works on first boot.
APP_DIR="/opt/open-design"
ENV_FILE="$${APP_DIR}/app.env"
mkdir -p "$${APP_DIR}"

umask 077
: > "$${ENV_FILE}"
chmod 0600 "$${ENV_FILE}"

# fetch_secret <ENV_KEY> <secret_name>
# Appends KEY=value to app.env if the secret has a non-empty latest version.
fetch_secret() {
  local key="$${1}" name="$${2}" val
  if ! val="$(gcloud secrets versions access latest --secret="$${name}" --project="${project_id}" 2>/dev/null)"; then
    val=""
  fi
  if [ -z "$${val}" ]; then
    log "WARN: secret $${name} has no value yet; $${key} not set (dependent service stays down until provided)"
    return 0
  fi
  printf '%s=%s\n' "$${key}" "$${val}" >> "$${ENV_FILE}"
  log "Loaded $${key} from $${name}"
}

# Model gateway virtual key -> open-design (ANTHROPIC_AUTH_TOKEN).
fetch_secret ANTHROPIC_AUTH_TOKEN "${litellm_key_secret_name}"
# Google SSO -> oauth2-proxy.
fetch_secret OAUTH2_PROXY_CLIENT_ID "${oauth_client_id_secret_name}"
fetch_secret OAUTH2_PROXY_CLIENT_SECRET "${oauth_client_secret_secret_name}"
fetch_secret OAUTH2_PROXY_COOKIE_SECRET "${oauth_cookie_secret_name}"
# Cloudflare tunnel connector -> cloudflared.
fetch_secret TUNNEL_TOKEN "${cloudflared_secret_name}"

# --- 6. Materialize compose file from metadata and start the stack ---------
log "Writing docker-compose.yml from instance metadata"
curl -s -H "Metadata-Flavor: Google" \
  "http://metadata.google.internal/computeMetadata/v1/instance/attributes/docker-compose-yml" \
  -o "$${APP_DIR}/docker-compose.yml"

log "Pulling images and starting the stack"
cd "$${APP_DIR}"
docker compose --env-file "$${ENV_FILE}" pull
docker compose --env-file "$${ENV_FILE}" up -d --remove-orphans

log "Bootstrap complete"
