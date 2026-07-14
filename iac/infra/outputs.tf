output "environment" {
  description = "Active workspace / environment."
  value       = local.environment
}

output "cluster_name" {
  value = module.gke.cluster_name
}

output "cluster_location" {
  value = module.gke.cluster_location
}

output "artifact_registry_url" {
  value = module.artifact_registry.repository_url
}

output "alloydb_private_ips" {
  description = "Per-database private IPs of AlloyDB"
  value       = { for k, db in module.alloydb : k => db.instance_ip }
}

output "app_service_account_email" {
  description = "Annotate the app KSA with this via iam.gke.io/gcp-service-account."
  value       = module.workload_identity.service_account_email
}
