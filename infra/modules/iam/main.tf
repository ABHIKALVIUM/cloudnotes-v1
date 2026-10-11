# Service Account for CloudNotes Application
resource "google_service_account" "app_sa" {
  account_id   = var.sa_account_id
  display_name = var.sa_display_name
  description  = "Dedicated least-privilege service account for CloudNotes application"
  project      = var.project_id
}

# Least-privilege IAM Role 1: Cloud Storage Object Viewer (for reading static assets)
resource "google_project_iam_member" "storage_viewer" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.app_sa.email}"
}

# Least-privilege IAM Role 2: Cloud SQL Client (for connecting to managed PostgreSQL)
resource "google_project_iam_member" "cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.app_sa.email}"
}

# Least-privilege IAM Role 3: Cloud Logging Log Writer (for exporting application logs)
resource "google_project_iam_member" "logging_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.app_sa.email}"
}
