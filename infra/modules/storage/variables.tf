variable "bucket_name" {
  description = "Globally unique name for the Cloud Storage assets bucket"
  type        = string
}

variable "location" {
  description = "Geographic location of the bucket"
  type        = string
  default     = "US"
}

variable "storage_class" {
  description = "Storage class of the bucket"
  type        = string
  default     = "STANDARD"
}
