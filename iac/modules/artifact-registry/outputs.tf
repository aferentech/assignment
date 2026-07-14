output "repository_id" {
  description = "Full resource ID of the repository."
  value       = google_artifact_registry_repository.this.id
}

output "repository_name" {
  description = "Short name of the repository."
  value       = google_artifact_registry_repository.this.repository_id
}

output "repository_url" {
  description = "Base URL for pushing/pulling images."
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.this.repository_id}"
}
