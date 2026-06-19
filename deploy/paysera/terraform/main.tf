# ---------------------------------------------------------------------------
# main.tf — Paysera Open Design single-instance GCP deployment
#
# Topology:
#   * One dedicated VPC + /28 subnet (Private Google Access ON).
#   * Cloud Router + Cloud NAT for outbound egress (no external IP on the VM).
#   * Firewall: IAP-range SSH ingress only; explicit allow-all egress.
#   * Least-privilege service account for the VM.
#   * Secret Manager secret for the cloudflared connector token (value out-of-band).
#   * Dedicated persistent disk for daemon data (OD_DATA_DIR — see root
#     AGENTS.md "Daemon data directory contract": OD_DATA_DIR is the single
#     data-root truth source; the daemon resolves it into RUNTIME_DATA_DIR and
#     every daemon-owned path derives from there).
#   * One GCE instance running docker compose (open-design + cloudflared).
#
# Ingress to the daemon is ONLY via the Cloudflare tunnel -> localhost:7456.
# The daemon runs with OD_DISABLE_API_AUTH=1; request auth is enforced by
# Cloudflare Access in front of the tunnel.
# ---------------------------------------------------------------------------

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.40.0, < 7.0.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# ---------------------------------------------------------------------------
# Project services
# Enable the APIs this stack depends on. Safe to keep enabled if already on.
# ---------------------------------------------------------------------------

locals {
  required_services = [
    "compute.googleapis.com",
    "secretmanager.googleapis.com",
    "artifactregistry.googleapis.com",
    "iap.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    # aiplatform is enabled here for the later model-wiring step (Vertex).
    # Enabling the API is harmless without the IAM role; the role binding
    # itself is left as a commented placeholder in the SA section below.
    "aiplatform.googleapis.com",
  ]
}

resource "google_project_service" "required" {
  for_each = toset(local.required_services)

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

# ---------------------------------------------------------------------------
# Networking — dedicated VPC + subnet with Private Google Access
# ---------------------------------------------------------------------------

resource "google_compute_network" "vpc" {
  name                    = var.network_name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"

  depends_on = [google_project_service.required]
}

resource "google_compute_subnetwork" "subnet" {
  name          = var.subnet_name
  region        = var.region
  network       = google_compute_network.vpc.id
  ip_cidr_range = var.subnet_cidr

  # Private Google Access lets the VM reach Google APIs (Artifact Registry,
  # Secret Manager, Logging, Vertex) without an external IP. NAT covers all
  # other egress (GHCR base-image pulls happen at image-build time, not here).
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# ---------------------------------------------------------------------------
# Cloud Router + Cloud NAT — outbound egress for a VM with no external IP
# ---------------------------------------------------------------------------

resource "google_compute_router" "router" {
  name    = "${var.instance_name}-router"
  region  = var.region
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {
  name   = "${var.instance_name}-nat"
  router = google_compute_router.router.name
  region = var.region

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.subnet.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# ---------------------------------------------------------------------------
# Firewall
#   * No public ingress at all — the daemon is reachable only through the
#     Cloudflare tunnel, which dials OUT from cloudflared. Nothing dials in.
#   * SSH (22) ingress allowed ONLY from the IAP TCP-forwarding range, so
#     `gcloud compute ssh --tunnel-through-iap` works without an external IP.
#   * Egress is explicitly allowed (default egress is allow, but we make it
#     explicit and taggable for auditability).
# ---------------------------------------------------------------------------

resource "google_compute_firewall" "allow_iap_ssh" {
  name      = "${var.instance_name}-allow-iap-ssh"
  network   = google_compute_network.vpc.id
  direction = "INGRESS"
  priority  = 1000

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # IAP forwarders live in this fixed Google-owned range.
  source_ranges = [var.iap_source_range]
  target_tags   = ["open-design"]
}

resource "google_compute_firewall" "allow_egress" {
  name      = "${var.instance_name}-allow-egress"
  network   = google_compute_network.vpc.id
  direction = "EGRESS"
  priority  = 1000

  allow {
    protocol = "all"
  }

  destination_ranges = ["0.0.0.0/0"]
  target_tags        = ["open-design"]
}

# Belt-and-suspenders: an explicit high-priority deny for any public ingress.
# There is no allow rule for 0.0.0.0/0 ingress, so this is defensive only.
resource "google_compute_firewall" "deny_public_ingress" {
  name      = "${var.instance_name}-deny-public-ingress"
  network   = google_compute_network.vpc.id
  direction = "INGRESS"
  priority  = 65534

  deny {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["open-design"]
}

# ---------------------------------------------------------------------------
# Least-privilege service account for the VM
# ---------------------------------------------------------------------------

resource "google_service_account" "vm" {
  account_id   = var.service_account_id
  display_name = "Open Design VM (least-privilege runtime SA)"
  project      = var.project_id
}

# Pull the Paysera image from Artifact Registry.
resource "google_project_iam_member" "ar_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.vm.email}"
}

# Write application + system logs to Cloud Logging.
resource "google_project_iam_member" "log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.vm.email}"
}

# Write metrics to Cloud Monitoring.
resource "google_project_iam_member" "metric_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.vm.email}"
}

# Read the cloudflared connector token. Scoped to the single secret (resource-
# level binding) rather than project-wide secretAccessor — least privilege.
resource "google_secret_manager_secret_iam_member" "cloudflared_token_accessor" {
  secret_id = local.cloudflared_secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.vm.email}"
}

# ---------------------------------------------------------------------------
# PLACEHOLDER — Vertex AI / model wiring (added in the model-wiring step)
#
# When Claude is wired to Vertex (paysera-llm-gateway / aiplatform), grant the
# VM SA the minimal Vertex predict role. Uncomment and apply THEN, not now:
#
# resource "google_project_iam_member" "vertex_user" {
#   project = var.project_id
#   role    = "roles/aiplatform.user"   # prefer a custom role limited to
#                                        # aiplatform.endpoints.predict if the
#                                        # gateway exposes a specific endpoint.
#   member  = "serviceAccount:${google_service_account.vm.email}"
# }
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Secret Manager — cloudflared connector token
#
# The token VALUE is supplied out of band so it never lands in Terraform state.
# Terraform manages only the secret CONTAINER (when manage_cloudflared_secret).
# Add the version manually after apply:
#   gcloud secrets versions add open-design-cloudflared-token \
#     --project pt-ai-hub --data-file=-
# ---------------------------------------------------------------------------

resource "google_secret_manager_secret" "cloudflared_token" {
  count     = var.manage_cloudflared_secret ? 1 : 0
  secret_id = var.cloudflared_secret_name
  project   = var.project_id
  labels    = var.labels

  replication {
    auto {}
  }

  depends_on = [google_project_service.required]
}

# If the secret is managed out-of-band, read it via a data source so the IAM
# binding above can reference a concrete secret_id.
data "google_secret_manager_secret" "cloudflared_token" {
  count     = var.manage_cloudflared_secret ? 0 : 1
  secret_id = var.cloudflared_secret_name
  project   = var.project_id
}

locals {
  cloudflared_secret_id = var.manage_cloudflared_secret ? google_secret_manager_secret.cloudflared_token[0].secret_id : data.google_secret_manager_secret.cloudflared_token[0].secret_id
}

# ---------------------------------------------------------------------------
# App secrets — oauth2-proxy (Google SSO) + litellm virtual key (model gateway)
#
# Values are supplied OUT OF BAND so they never enter Terraform state. With
# manage_app_secrets=true Terraform creates EMPTY containers; add versions with:
#   gcloud secrets versions add open-design-oauth-client-id     --data-file=- ...
#   gcloud secrets versions add open-design-oauth-client-secret --data-file=- ...
#   gcloud secrets versions add open-design-oauth-cookie-secret --data-file=- ...
#   gcloud secrets versions add open-design-litellm-key         --data-file=- ...
# ---------------------------------------------------------------------------

locals {
  app_secret_names = {
    oauth_client_id     = var.oauth_client_id_secret_name
    oauth_client_secret = var.oauth_client_secret_secret_name
    oauth_cookie_secret = var.oauth_cookie_secret_name
    litellm_key         = var.litellm_key_secret_name
  }
}

resource "google_secret_manager_secret" "app" {
  for_each  = var.manage_app_secrets ? local.app_secret_names : {}
  secret_id = each.value
  project   = var.project_id
  labels    = var.labels

  replication {
    auto {}
  }

  depends_on = [google_project_service.required]
}

# Resource-scoped accessor on each app secret (least privilege, not project-wide).
resource "google_secret_manager_secret_iam_member" "app_accessor" {
  for_each  = local.app_secret_names
  secret_id = each.value
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.vm.email}"

  depends_on = [google_secret_manager_secret.app]
}

# ---------------------------------------------------------------------------
# Persistent data disk — holds OD_DATA_DIR (single data-root truth source)
# ---------------------------------------------------------------------------

resource "google_compute_disk" "data" {
  name   = var.data_disk_name
  type   = var.data_disk_type
  zone   = var.zone
  size   = var.data_disk_size_gb
  labels = var.labels
}

# ---------------------------------------------------------------------------
# Startup script + compose file rendered for the VM
#
# The compose file is delivered through instance metadata and written to disk
# by the startup script, keeping the two artifacts version-controlled together.
# ---------------------------------------------------------------------------

locals {
  startup_script = templatefile("${path.module}/startup-script.sh", {
    artifact_registry_host          = var.artifact_registry_host
    cloudflared_secret_name         = var.cloudflared_secret_name
    oauth_client_id_secret_name     = var.oauth_client_id_secret_name
    oauth_client_secret_secret_name = var.oauth_client_secret_secret_name
    oauth_cookie_secret_name        = var.oauth_cookie_secret_name
    litellm_key_secret_name         = var.litellm_key_secret_name
    data_disk_device_name           = var.data_disk_device_name
    host_data_dir                   = var.host_data_dir
    project_id                      = var.project_id
  })

  docker_compose = templatefile("${path.module}/docker-compose.yml", {
    container_image       = var.container_image
    daemon_port           = var.daemon_port
    public_hostname       = var.public_hostname
    host_data_dir         = var.host_data_dir
    node_max_old_space_mb = var.node_max_old_space_mb
    anthropic_base_url    = var.anthropic_base_url
  })
}

# ---------------------------------------------------------------------------
# GCE instance
# ---------------------------------------------------------------------------

resource "google_compute_instance" "vm" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone
  labels       = var.labels
  tags         = ["open-design"]

  boot_disk {
    initialize_params {
      image = var.boot_image
      size  = var.boot_disk_size_gb
      type  = var.boot_disk_type
    }
  }

  # Attach the dedicated data disk; the startup script mounts it idempotently.
  attached_disk {
    source      = google_compute_disk.data.id
    device_name = var.data_disk_device_name
    mode        = "READ_WRITE"
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.id
    # No access_config block => NO external IP. Egress goes via Cloud NAT.
  }

  # Bind the least-privilege SA. cloud-platform scope is the modern default;
  # the SA's IAM roles (not the scope) are what actually gate access.
  service_account {
    email  = google_service_account.vm.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  metadata = {
    # Block project-wide SSH keys; only IAP + OS Login may connect.
    block-project-ssh-keys = "true"
    enable-oslogin         = "TRUE"

    startup-script     = local.startup_script
    docker-compose-yml = local.docker_compose
  }

  # Shielded VM — secure boot + vTPM + integrity monitoring.
  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  # Survive maintenance without manual intervention.
  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
  }

  allow_stopping_for_update = true

  depends_on = [
    google_compute_router_nat.nat,
    google_project_iam_member.ar_reader,
    google_secret_manager_secret_iam_member.cloudflared_token_accessor,
    google_secret_manager_secret_iam_member.app_accessor,
  ]
}
