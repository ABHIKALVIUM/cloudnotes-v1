variable "instance_name" {
  description = "Name of the compute instance"
  type        = string
  default     = "cloudnotes-app-instance"
}

variable "machine_type" {
  description = "Machine type for the compute instance"
  type        = string
  default     = "e2-micro"
}

variable "zone" {
  description = "GCP zone where compute instance is deployed"
  type        = string
  default     = "us-central1-a"
}

variable "subnet_id" {
  description = "Subnet ID where the compute instance resides (wired from network module)"
  type        = string
}

variable "sa_email" {
  description = "Service account email attached to the compute instance (wired from iam module)"
  type        = string
}

variable "image" {
  description = "Boot disk OS image"
  type        = string
  default     = "debian-cloud/debian-11"
}
