variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "sa_account_id" {
  description = "The account ID for the CloudNotes service account"
  type        = string
  default     = "cloudnotes-app-sa"
}

variable "sa_display_name" {
  description = "Display name for the service account"
  type        = string
  default     = "CloudNotes Application Service Account"
}
