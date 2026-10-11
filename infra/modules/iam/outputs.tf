output "app_sa_email" {
  description = "Email of the CloudNotes service account (wired to compute module)"
  value       = google_service_account.app_sa.email
}

output "app_sa_id" {
  description = "Unique ID of the CloudNotes service account"
  value       = google_service_account.app_sa.id
}

output "app_sa_name" {
  description = "Full resource name of the CloudNotes service account"
  value       = google_service_account.app_sa.name
}
