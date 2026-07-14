variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "region" {
  description = "Region for the state bucket."
  type        = string
  default     = "northamerica-northeast2"
}

variable "state_bucket_name" {
  description = "Globally-unique name for the Terraform remote-state bucket."
  type        = string
}
