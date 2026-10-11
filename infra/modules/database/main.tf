# Managed Cloud SQL PostgreSQL Instance
resource "google_sql_database_instance" "db_instance" {
  name             = var.db_instance_name
  database_version = var.db_version
  region           = var.region

  settings {
    tier = var.db_tier

    ip_configuration {
      ipv4_enabled    = true
      private_network = var.network_id
    }

    backup_configuration {
      enabled    = true
      start_time = "04:00"
    }
  }

  deletion_protection = false
}

# CloudNotes Application Database Schema
resource "google_sql_database" "db" {
  name     = var.db_name
  instance = google_sql_database_instance.db_instance.name
}
