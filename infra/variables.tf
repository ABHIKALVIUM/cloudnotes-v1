# ==============================================================================
# CloudNotes Infrastructure — Root Variables
# Declared once at the root to keep child modules generic and environment-agnostic.
# ==============================================================================

variable "project_id" {
  description = "GCP Project ID for CloudNotes infrastructure"
  type        = string
  default     = "cloudnotes-production"
}

variable "region" {
  description = "Primary GCP region for resource deployment"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "Primary GCP zone for compute resources"
  type        = string
  default     = "us-central1-a"
}

variable "web_cidr" {
  description = "CIDR block for the public web tier subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "app_cidr" {
  description = "CIDR block for the application tier subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "db_cidr" {
  description = "CIDR block for the database tier subnet"
  type        = string
  default     = "10.0.3.0/24"
}

variable "instance_name" {
  description = "Name of the CloudNotes compute VM instance"
  type        = string
  default     = "cloudnotes-app-instance"
}

variable "machine_type" {
  description = "Compute engine machine type for the application instance"
  type        = string
  default     = "e2-micro"
}

variable "db_instance_name" {
  description = "Instance identifier for the managed Cloud SQL database"
  type        = string
  default     = "cloudnotes-db-instance"
}

variable "db_name" {
  description = "Name of the CloudNotes database schema"
  type        = string
  default     = "cloudnotes_prod"
}

variable "bucket_name" {
  description = "Globally unique name for CloudNotes object storage bucket"
  type        = string
  default     = "cloudnotes-static-assets-prod-2026"
}
