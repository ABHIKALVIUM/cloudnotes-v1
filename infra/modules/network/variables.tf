variable "network_name" {
  description = "Name of the VPC network"
  type        = string
  default     = "cloudnotes-vpc"
}

variable "web_cidr" {
  description = "CIDR range for public web tier subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "app_cidr" {
  description = "CIDR range for application tier subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "db_cidr" {
  description = "CIDR range for database tier subnet"
  type        = string
  default     = "10.0.3.0/24"
}

variable "region" {
  description = "GCP region where subnets are created"
  type        = string
  default     = "us-central1"
}
