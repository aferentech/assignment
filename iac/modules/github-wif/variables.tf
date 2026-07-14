variable "project_id" {
  description = "GCP project ID that owns the Workload Identity Pool."
  type        = string
}

variable "resource_name_prefix" {
  description = "Prefix applied to the pool/provider IDs."
  type        = string
}

variable "github_repositories" {
  description = "GitHub repos allowed to federate, as \"owner/repo\". These are the only identities the provider accepts and the ones granted access."
  type        = list(string)
  validation {
    condition     = length(var.github_repositories) > 0
    error_message = "Provide at least one \"owner/repo\"."
  }
}

variable "issuer_uri" {
  description = "OIDC issuer for GitHub Actions."
  type        = string
  default     = "https://token.actions.githubusercontent.com"
}
