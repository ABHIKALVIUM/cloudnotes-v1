output "bucket_name" {
  description = "Name of the Cloud Storage bucket"
  value       = google_storage_bucket.assets_bucket.name
}

output "bucket_url" {
  description = "URL of the Cloud Storage bucket"
  value       = google_storage_bucket.assets_bucket.url
}

output "bucket_self_link" {
  description = "Self link URI of the bucket"
  value       = google_storage_bucket.assets_bucket.self_link
}
