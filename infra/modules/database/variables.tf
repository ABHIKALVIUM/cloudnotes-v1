variable "db_instance_name" {
  description = "Name of the Cloud SQL database instance"
  type        = string
  default     = "cloudnotes-db-instance"
}

variable "db_name" {
  description = "Name of the CloudNotes database schema"
  type        = string
  default     = "cloudnotes_db"
}

variable "db_version" {
  description = "Database version engine"
  type        = string
  default     = "POSTGRES_15"
}

variable "db_tier" {
  description = "Machine tier for the database instance"
  type        = string
  default     = "db-f1-micro"
}

variable "region" {
  description = "GCP region where database is deployed"
  type        = string
  default     = "us-central1"
}

variable "network_id" {
  description = "VPC network ID for private network configuration (wired from network module)"
  type        = string
}
