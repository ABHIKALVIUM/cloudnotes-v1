terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# Provider setup for zero-cost validation:
# Configured with local mock service account credentials so that terraform init,
# terraform validate, and terraform plan run completely locally with no real cloud
# account required and zero cost.
provider "google" {
  project     = var.project_id
  region      = var.region
  zone        = var.zone
  credentials = "{\"type\": \"service_account\", \"project_id\": \"${var.project_id}\"}"
}
