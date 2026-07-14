variable "environments" {
  description = "Per-environment configuration, keyed by environment name."
  type = map(object({
    project_id = string

    resource_name_prefix = string

    region = optional(string, "northamerica-northeast2")

    regional_cluster = bool

    node_pools = map(object({
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
        effect = string
      })), [])
    }))

    databases = map(object({
      user              = optional(string, "app_user")
      cpu_count         = optional(number, 2)
      password_rotation = optional(string, "1")
    }))

    subnet_cidr            = string
    pods_cidr              = string
    services_cidr          = string
    master_ipv4_cidr_block = string
    master_authorized_cidr = optional(string, "0.0.0.0/0")
    deletion_protection    = bool

    wif_provider_enabled = optional(bool, false)
  }))
}

variable "app_namespace" {
  description = "Kubernetes namespace the tenant API runs in."
  type        = string
  default     = "app"
}

variable "app_ksa_name" {
  description = "Kubernetes ServiceAccount name for the app."
  type        = string
  default     = "app-sa"
}

variable "ci_writer_member" {
  description = "Extra IAM member allowed to push images."
  type        = string
  default     = ""
}

variable "github_repositories" {
  description = "GitHub repos (\"owner/repo\") allowed to push images / run Terraform CI via Direct WIF."
  type        = list(string)
  default     = [""]
}

variable "wif_target_projects" {
  description = "Project IDs the single WIF identity is granted access to"
  type        = list(string)
  default     = []
}

variable "ci_roles" {
  description = "Project roles granted to the Terraform-CI identity (broad enough to manage this stack)."
  type        = list(string)
  default = [
    "roles/compute.admin",
    "roles/container.admin",
    "roles/alloydb.admin",
    "roles/secretmanager.admin",
    "roles/artifactregistry.admin",
    "roles/servicenetworking.networksAdmin",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.serviceAccountUser",
    "roles/iam.workloadIdentityPoolAdmin",
    "roles/resourcemanager.projectIamAdmin",
    "roles/serviceusage.serviceUsageAdmin",
    "roles/storage.admin",
  ]
}
