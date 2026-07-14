output "cluster_name" {
  description = "AlloyDB cluster resource name."
  value       = google_alloydb_cluster.this.name
}

output "instance_ip" {
  description = "Private IP address of the AlloyDB primary instance."
  value       = google_alloydb_instance.primary.ip_address
}

output "database_user" {
  description = "Application database username."
  value       = var.database_user
}

output "secret_id" {
  description = "Full resource ID of this database's password secret (for granting secretAccessor)."
  value       = google_secret_manager_secret.db_password.id
}

output "secret_name" {
  description = "Short name of this database's password secret."
  value       = google_secret_manager_secret.db_password.secret_id
}
