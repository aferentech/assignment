variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "region" {
  description = "Region for the subnet and Cloud Router/NAT."
  type        = string
}

variable "resource_name_prefix" {
  description = "Prefix applied to all network resource names."
  type        = string
}

variable "subnet_cidr" {
  description = "Primary CIDR range for the GKE nodes subnet."
  type        = string
}

variable "pods_cidr" {
  description = "Secondary CIDR range used for GKE Pods."
  type        = string
}

variable "services_cidr" {
  description = "Secondary CIDR range used for GKE Services."
  type        = string
}

variable "psa_prefix_length" {
  description = "Prefix length of the reserved range for Private Service Access (AlloyDB)."
  type        = number
  default     = 20
}
