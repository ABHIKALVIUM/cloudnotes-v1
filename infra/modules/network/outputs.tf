output "network_id" {
  description = "The ID of the VPC network"
  value       = google_compute_network.vpc.id
}

output "network_name" {
  description = "The name of the VPC network"
  value       = google_compute_network.vpc.name
}

output "subnet_id" {
  description = "The application subnet ID (wired to compute module)"
  value       = google_compute_subnetwork.app_subnet.id
}

output "web_subnet_id" {
  description = "The web subnet ID"
  value       = google_compute_subnetwork.web_subnet.id
}

output "app_subnet_id" {
  description = "The application subnet ID"
  value       = google_compute_subnetwork.app_subnet.id
}

output "db_subnet_id" {
  description = "The database subnet ID"
  value       = google_compute_subnetwork.db_subnet.id
}
