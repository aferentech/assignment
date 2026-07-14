output "service_account_email" {
  description = "Email of the app Google service account (annotate the KSA with this via iam.gke.io/gcp-service-account)."
  value       = google_service_account.app.email
}
