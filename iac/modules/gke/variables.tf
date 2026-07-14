variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "region" {
  description = "Region for the cluster (regional control plane)."
  type        = string
}

variable "resource_name_prefix" {
  description = "Prefix applied to cluster and node pool names."
  type        = string
}

variable "network_name" {
  description = "VPC name the cluster attaches to."
  type        = string
}

variable "subnet_name" {
  description = "Subnet name for the cluster."
  type        = string
}

variable "pods_range_name" {
  description = "Secondary range name for Pods."
  type        = string
}

variable "services_range_name" {
  description = "Secondary range name for Services."
  type        = string
}

variable "master_ipv4_cidr_block" {
  description = "CIDR /28 for the private control plane."
  type        = string
  default     = "172.16.0.0/28"
}

variable "release_channel" {
  description = "GKE release channel."
  type        = string
  default     = "REGULAR"
}

variable "node_pools" {
  description = <<-EOT
    Node pools to create, keyed by name. Each pool autoscales between min_count
    and max_count (per zone). At least one pool is required.
  EOT
  type = map(object({
    machine_type = string
    min_count    = number
    max_count    = number
    disk_size_gb = optional(number, 50)
    disk_type    = optional(string, "pd-standard")
    spot         = optional(bool, false)
    labels       = optional(map(string), {})
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string # NO_SCHEDULE | PREFER_NO_SCHEDULE | NO_EXECUTE
    })), [])
  }))

  validation {
    condition     = length(var.node_pools) > 0
    error_message = "At least one node pool must be defined."
  }
}

variable "regional" {
  description = "If true, spreads nodes across zones in the region; if false, single-zone node pool (cheaper for dev)."
  type        = bool
  default     = true
}

variable "master_authorized_cidr" {
  description = "CIDR allowed to reach the public endpoint of the control plane (e.g. CI/CD or admin IP)."
  type        = string
  default     = "0.0.0.0/0"
}

variable "deletion_protection" {
  description = "Protect the cluster from terraform destroy."
  type        = bool
  default     = false
}
