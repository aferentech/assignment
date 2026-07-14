variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "region" {
  description = "Region for the AlloyDB cluster and its password secret."
  type        = string
}

variable "resource_name_prefix" {
  description = "Prefix applied to AlloyDB resource names."
  type        = string
}

variable "db_name" {
  description = "Short identifier for this database"
  type        = string
}

variable "network_id" {
  description = "Self link / ID of the VPC AlloyDB peers into"
  type        = string
}

variable "psa_connection" {
  description = "The service networking connection dependency"
  type        = string
}

variable "database_user" {
  description = "Application database username."
  type        = string
  default     = "app_user"
}

variable "cpu_count" {
  description = "vCPUs for the primary instance"
  type        = number
  default     = 2
}

variable "password_rotation" {
  description = "Bump this value to rotate the DB password on the next apply."
  type        = string
  default     = "1"
}

variable "deletion_protection" {
  description = "Protect the cluster from terraform destroy."
  type        = bool
  default     = false
}
