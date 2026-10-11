resource "google_storage_bucket" "assets_bucket" {
  name                        = var.bucket_name
  location                    = var.location
  storage_class               = var.storage_class
  force_destroy               = true
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
}
