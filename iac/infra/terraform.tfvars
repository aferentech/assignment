github_repositories = ["aferentech/assignment"]

wif_target_projects = [
  "home-assignment-devops-dev",
  "home-assignment-devops-prod",
]

environments = {
  dev = {
    project_id           = "home-assignment-devops-dev"
    resource_name_prefix = "assignment-dev"
    region               = "northamerica-northeast2"

    regional_cluster = false
    node_pools = {
      default = {
        machine_type = "e2-standard-2"
        min_count    = 1
        max_count    = 3
        spot         = true
      }
    }

    databases = {
      app = {
        user              = "app_user"
        cpu_count         = 2
        password_rotation = "1"
      }
    }

    subnet_cidr            = "10.10.0.0/20"
    pods_cidr              = "10.20.0.0/16"
    services_cidr          = "10.30.0.0/20"
    master_ipv4_cidr_block = "172.16.0.0/28"

    deletion_protection = false
  }

  prod = {
    project_id           = "home-assignment-devops-prod"
    resource_name_prefix = "assignment-prod"
    region               = "northamerica-northeast2"

    regional_cluster = true
    node_pools = {
      general = {
        machine_type = "e2-standard-2"
        min_count    = 1
        max_count    = 3
      }

      spot = {
        machine_type = "e2-standard-4"
        min_count    = 0
        max_count    = 12
        spot         = true
        labels       = { workload = "batch" }
        taints = [{
          key    = "spot"
          value  = "true"
          effect = "NO_SCHEDULE"
        }]
      }
    }

    databases = {
      app = {
        user      = "app_user"
        cpu_count = 2
      }
    }

    subnet_cidr            = "10.40.0.0/20"
    pods_cidr              = "10.50.0.0/16"
    services_cidr          = "10.60.0.0/20"
    master_ipv4_cidr_block = "172.16.0.16/28"

    deletion_protection = true

    wif_provider_enabled = true
  }
}
