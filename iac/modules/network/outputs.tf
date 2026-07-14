output "network_id" {
  description = "Self link / ID of the VPC."
  value       = google_compute_network.vpc.id
}

output "network_name" {
  description = "Name of the VPC."
  value       = google_compute_network.vpc.name
}

output "subnet_id" {
  description = "ID of the GKE subnet."
  value       = google_compute_subnetwork.gke.id
}

output "subnet_name" {
  description = "Name of the GKE subnet."
  value       = google_compute_subnetwork.gke.name
}

output "pods_range_name" {
  description = "Secondary range name for Pods."
  value       = "pods"
}

output "services_range_name" {
  description = "Secondary range name for Services."
  value       = "services"
}

output "psa_connection" {
  description = "The Service Networking connection AlloyDB depends on."
  value       = google_service_networking_connection.psa.id
}
