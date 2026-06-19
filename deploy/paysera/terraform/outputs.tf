# ---------------------------------------------------------------------------
# outputs.tf — Paysera Open Design single-instance GCP deployment
# ---------------------------------------------------------------------------

output "instance_name" {
  description = "Name of the GCE instance."
  value       = google_compute_instance.vm.name
}

output "instance_zone" {
  description = "Zone of the GCE instance."
  value       = google_compute_instance.vm.zone
}

output "instance_internal_ip" {
  description = "Internal IP of the VM (no external IP is assigned)."
  value       = google_compute_instance.vm.network_interface[0].network_ip
}

output "service_account_email" {
  description = "Least-privilege service account bound to the VM."
  value       = google_service_account.vm.email
}

output "vpc_network" {
  description = "Self link of the dedicated VPC network."
  value       = google_compute_network.vpc.self_link
}

output "subnet" {
  description = "Self link of the subnet (Private Google Access enabled)."
  value       = google_compute_subnetwork.subnet.self_link
}

output "data_disk" {
  description = "Self link of the persistent data disk (mounted at host_data_dir, container OD_DATA_DIR=/data)."
  value       = google_compute_disk.data.self_link
}

output "cloudflared_secret_id" {
  description = "Secret Manager secret ID holding the cloudflared connector token. Add a version out-of-band before the VM can start the tunnel."
  value       = local.cloudflared_secret_id
}

output "public_hostname" {
  description = "Public hostname served through the Cloudflare tunnel."
  value       = var.public_hostname
}

output "ssh_command" {
  description = "Connect to the VM over IAP (no external IP)."
  value       = "gcloud compute ssh ${var.instance_name} --zone ${var.zone} --project ${var.project_id} --tunnel-through-iap"
}

output "add_cloudflared_token_command" {
  description = "One-time command to store the cloudflared connector token out-of-band (keeps it out of Terraform state)."
  value       = "gcloud secrets versions add ${local.cloudflared_secret_id} --project ${var.project_id} --data-file=-"
}
