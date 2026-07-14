output "state_bucket_name" {
  description = "Name of the GCS bucket to use in infra/backend.tf."
  value       = google_storage_bucket.tfstate.name
}
