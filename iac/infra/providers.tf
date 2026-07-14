provider "google" {
  project = local.cfg.project_id
  region  = local.cfg.region
}

# Short-lived OAuth token for the caller; auths the k8s/helm providers below.
data "google_client_config" "default" {}
