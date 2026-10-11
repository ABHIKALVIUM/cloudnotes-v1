output "instance_id" {
  description = "Unique ID of the compute instance"
  value       = google_compute_instance.app_instance.id
}

output "instance_name" {
  description = "Name of the compute instance"
  value       = google_compute_instance.app_instance.name
}

output "instance_internal_ip" {
  description = "Internal IP address of the compute instance"
  value       = google_compute_instance.app_instance.network_interface[0].network_ip
}

output "app_ip" {
  description = "Public IP address of the CloudNotes app instance"
  value       = google_compute_instance.app_instance.network_interface[0].access_config[0].nat_ip
}
