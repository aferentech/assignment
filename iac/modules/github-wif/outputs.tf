output "provider_name" {
  description = "Full provider resource name — use as the GitHub secret GCP_WIF_PROVIDER."
  value       = google_iam_workload_identity_pool_provider.github.name
}

output "pool_name" {
  description = "Full pool resource name (projects/<number>/locations/global/workloadIdentityPools/<id>). Callers build principalSet members from this."
  value       = google_iam_workload_identity_pool.this.name
}
