# ---------------------------------------------------------------------------
# variables.tf — Paysera Open Design single-instance GCP deployment
#
# All values are pinned to the canonical Paysera deployment by default. Override
# only via terraform.tfvars when a value genuinely differs per environment.
# ---------------------------------------------------------------------------

# --- GCP placement -----------------------------------------------------------

variable "project_id" {
  description = "GCP project that hosts the Open Design VM, VPC, NAT, and secret."
  type        = string
  default     = "pt-ai-hub"
}

variable "region" {
  description = "Region for the subnet, Cloud Router, Cloud NAT, persistent disk, and Artifact Registry."
  type        = string
  default     = "europe-west1"
}

variable "zone" {
  description = "Zone for the single GCE instance and its data disk."
  type        = string
  default     = "europe-west1-b"
}

# --- Networking --------------------------------------------------------------

variable "network_name" {
  description = "Name of the dedicated VPC network created for this deployment."
  type        = string
  default     = "open-design-net"
}

variable "subnet_name" {
  description = "Name of the subnet hosting the VM. Private Google Access is enabled on it."
  type        = string
  default     = "open-design-subnet"
}

variable "subnet_cidr" {
  description = "Primary IPv4 CIDR for the subnet. /28 is plenty for a single instance."
  type        = string
  default     = "10.10.0.0/28"
}

# IAP TCP-forwarding source range. This is the only ingress allowed (SSH 22).
# It is a Google-owned fixed range; do not change unless Google republishes it.
variable "iap_source_range" {
  description = "IAP TCP forwarding source CIDR. SSH ingress is restricted to this range only."
  type        = string
  default     = "35.235.240.0/20"
}

# --- Compute -----------------------------------------------------------------

variable "instance_name" {
  description = "Name of the GCE instance."
  type        = string
  default     = "open-design"
}

variable "machine_type" {
  description = "Machine type for the VM. e2-standard-2 = 2 vCPU / 8 GiB, matches the 3 GiB Node heap + cloudflared."
  type        = string
  default     = "e2-standard-2"
}

# Ubuntu 24.04 LTS (Noble) — chosen over Container-Optimized OS so we can run a
# two-service docker compose stack (open-design + cloudflared) on one host.
variable "boot_image" {
  description = "Boot disk image family for the VM."
  type        = string
  default     = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2404-lts-amd64"
}

variable "boot_disk_size_gb" {
  description = "Boot disk size in GB (OS + Docker images only; daemon data lives on a separate disk)."
  type        = number
  default     = 30
}

variable "boot_disk_type" {
  description = "Boot disk type."
  type        = string
  default     = "pd-balanced"
}

# --- Persistent data disk ----------------------------------------------------

variable "data_disk_name" {
  description = "Name of the dedicated persistent disk holding daemon data (OD_DATA_DIR)."
  type        = string
  default     = "open-design-data"
}

variable "data_disk_size_gb" {
  description = "Size of the daemon data disk in GB."
  type        = number
  default     = 50
}

variable "data_disk_type" {
  description = "Type of the daemon data disk."
  type        = string
  default     = "pd-balanced"
}

# Device name as seen inside the guest at /dev/disk/by-id/google-<device_name>.
# The startup script formats and mounts this device idempotently.
variable "data_disk_device_name" {
  description = "Stable guest device name for the attached data disk."
  type        = string
  default     = "open-design-data"
}

# --- Container image ---------------------------------------------------------

# Paysera-layered image: ghcr.io/nexu-io/od:latest + baked Paysera design system
# + (in the model-wiring step) the Claude CLI, republished to Artifact Registry.
variable "container_image" {
  description = "Fully-qualified Open Design container image to run on the VM."
  type        = string
  default     = "europe-west1-docker.pkg.dev/pt-ai-hub/open-design/od-paysera:latest"
}

variable "artifact_registry_host" {
  description = "Artifact Registry Docker host used for `gcloud auth configure-docker` on the VM."
  type        = string
  default     = "europe-west1-docker.pkg.dev"
}

variable "artifact_registry_repo" {
  description = "Artifact Registry repository name for the Open Design image."
  type        = string
  default     = "open-design"
}

# --- Public ingress (Cloudflare) ---------------------------------------------

variable "public_hostname" {
  description = "Public hostname served via the Cloudflare tunnel. Used for OD_ALLOWED_ORIGINS."
  type        = string
  default     = "design.paysera.engineering"
}

# --- Daemon runtime ----------------------------------------------------------

variable "daemon_port" {
  description = "Port the Open Design daemon binds inside the container and on the compose network."
  type        = number
  default     = 7456
}

variable "host_data_dir" {
  description = "Host path where the data disk is mounted and bind-mounted into the container as OD_DATA_DIR=/data."
  type        = string
  default     = "/opt/open-design/data"
}

# Node heap cap inside the container. e2-standard-2 has 8 GiB, so 3 GiB is safe.
variable "node_max_old_space_mb" {
  description = "Value for NODE_OPTIONS --max-old-space-size inside the open-design container."
  type        = number
  default     = 3072
}

# --- Cloudflare tunnel secret ------------------------------------------------

variable "cloudflared_secret_name" {
  description = "Secret Manager secret ID holding the cloudflared connector (tunnel) token."
  type        = string
  default     = "open-design-cloudflared-token"
}

# The connector token value is supplied OUT OF BAND (not via Terraform state) to
# avoid persisting the secret in plaintext state. When true, Terraform creates an
# empty secret container only; you then add a version with:
#   gcloud secrets versions add open-design-cloudflared-token \
#     --project pt-ai-hub --data-file=-   # paste the token, Ctrl-D
# When false, Terraform expects the secret to already exist (managed elsewhere)
# and only reads it via a data source for the IAM binding.
variable "manage_cloudflared_secret" {
  description = "If true, Terraform creates the (empty) Secret Manager container for the cloudflared token. Set false if the secret is managed out-of-band."
  type        = bool
  default     = true
}

# --- Model gateway (Paysera litellm-proxy) -----------------------------------

variable "anthropic_base_url" {
  description = "Anthropic-compatible base URL for the Claude CLI. Paysera litellm-proxy (Cloud Run, paysera-llm-gateway) fronting Vertex Claude."
  type        = string
  default     = "https://litellm-proxy-3qgmggattq-ew.a.run.app"
}

# --- SSO (oauth2-proxy) + model secrets --------------------------------------
# All secret VALUES are supplied OUT OF BAND (never in Terraform state):
#   - oauth client id/secret  : from a Google OAuth 2.0 Web client (console)
#   - oauth cookie secret      : 32-byte random (openssl rand -base64 32)
#   - litellm key              : a litellm virtual key minted from the master key
# When manage_app_secrets=true, Terraform creates the EMPTY containers; add
# versions after apply with `gcloud secrets versions add <name> --data-file=-`.

variable "manage_app_secrets" {
  description = "If true, Terraform creates the (empty) Secret Manager containers for the oauth2-proxy + litellm secrets."
  type        = bool
  default     = true
}

variable "oauth_client_id_secret_name" {
  description = "Secret Manager secret ID for the Google OAuth Web client ID (oauth2-proxy)."
  type        = string
  default     = "open-design-oauth-client-id"
}

variable "oauth_client_secret_secret_name" {
  description = "Secret Manager secret ID for the Google OAuth Web client secret (oauth2-proxy)."
  type        = string
  default     = "open-design-oauth-client-secret"
}

variable "oauth_cookie_secret_name" {
  description = "Secret Manager secret ID for the oauth2-proxy cookie secret (32-byte random)."
  type        = string
  default     = "open-design-oauth-cookie-secret"
}

variable "litellm_key_secret_name" {
  description = "Secret Manager secret ID for the litellm virtual key (ANTHROPIC_AUTH_TOKEN)."
  type        = string
  default     = "open-design-litellm-key"
}

# --- Service account ---------------------------------------------------------

variable "service_account_id" {
  description = "Account ID (local part) for the VM's least-privilege service account."
  type        = string
  default     = "open-design-vm"
}

# --- Labels ------------------------------------------------------------------

variable "labels" {
  description = "Common resource labels."
  type        = map(string)
  default = {
    app        = "open-design"
    team       = "paysera-tech"
    managed-by = "terraform"
  }
}
