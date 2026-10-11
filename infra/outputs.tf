# ==============================================================================
# CloudNotes System Outputs — Re-exposed at the Root
# Exposes essential connection endpoints, network identifiers, and bucket details.
# ==============================================================================

output "network_id" {
  description = "The ID of the provisioned CloudNotes VPC network"
  value       = module.network.network_id
}

output "subnet_id" {
  description = "The application subnet ID where compute instances run"
  value       = module.network.subnet_id
}

output "app_instance_name" {
  description = "The name of the CloudNotes application VM instance"
  value       = module.compute.instance_name
}

output "app_ip" {
  description = "Public NAT IP address of the CloudNotes application instance"
  value       = module.compute.app_ip
}

output "app_service_account_email" {
  description = "Service account email attached to the application instance"
  value       = module.iam.app_sa_email
}

output "db_instance_name" {
  description = "Identifier for the CloudNotes managed database instance"
  value       = module.database.db_instance_name
}

output "db_name" {
  description = "Database name inside the managed database instance"
  value       = module.database.db_name
}

output "bucket_name" {
  description = "Name of the Cloud Storage bucket for assets"
  value       = module.storage.bucket_name
}
