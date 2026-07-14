variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "resource_name_prefix" {
  description = "Prefix applied to the service account name."
  type        = string
}

variable "kubernetes_namespace" {
  description = "Kubernetes namespace the app runs in."
  type        = string
}

variable "kubernetes_service_account" {
  description = "Kubernetes ServiceAccount name the app pods use."
  type        = string
}

variable "secret_ids" {
  description = <<-EOT
    Secret Manager secrets the app may read, as a map of
    { short_name = secret_resource_id }. The KEYS must be statically known
    (they become the for_each keys); the values may be apply-time attributes.
  EOT
  type        = map(string)
  default     = {}
}

variable "grant_alloydb_client" {
  description = "Grant roles/alloydb.client so the app can connect to AlloyDB."
  type        = bool
  default     = true
}
