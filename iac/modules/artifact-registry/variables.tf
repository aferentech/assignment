variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "region" {
  description = "Region for the Artifact Registry repository."
  type        = string
}

variable "resource_name_prefix" {
  description = "Prefix applied to the repository name."
  type        = string
}

variable "repository_id" {
  description = "Repository short name."
  type        = string
  default     = "containers"
}

variable "reader_members" {
  description = "IAM members granted read (pull) access, e.g. the GKE node SA."
  type        = list(string)
  default     = []
}

variable "writer_members" {
  description = "IAM members granted write (push) access, e.g. the CI/CD SA."
  type        = list(string)
  default     = []
}

variable "keep_recent_versions" {
  description = "Number of recent image versions to retain (cleanup policy)."
  type        = number
  default     = 10
}
