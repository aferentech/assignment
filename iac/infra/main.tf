resource "google_project_service" "apis" {
  for_each = toset([
    "compute.googleapis.com",
    "container.googleapis.com",
    "servicenetworking.googleapis.com",
    "alloydb.googleapis.com",
    "secretmanager.googleapis.com",
    "artifactregistry.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "sts.googleapis.com",
    "cloudresourcemanager.googleapis.com",
  ])
  project            = local.cfg.project_id
  service            = each.value
  disable_on_destroy = false
}

module "network" {
  source = "../modules/network"

  project_id           = local.cfg.project_id
  region               = local.cfg.region
  resource_name_prefix = local.cfg.resource_name_prefix
  subnet_cidr          = local.cfg.subnet_cidr
  pods_cidr            = local.cfg.pods_cidr
  services_cidr        = local.cfg.services_cidr

  depends_on = [google_project_service.apis]
}

module "gke" {
  source = "../modules/gke"

  project_id             = local.cfg.project_id
  region                 = local.cfg.region
  resource_name_prefix   = local.cfg.resource_name_prefix
  network_name           = module.network.network_name
  subnet_name            = module.network.subnet_name
  pods_range_name        = module.network.pods_range_name
  services_range_name    = module.network.services_range_name
  master_ipv4_cidr_block = local.cfg.master_ipv4_cidr_block
  master_authorized_cidr = local.cfg.master_authorized_cidr
  node_pools             = local.cfg.node_pools
  regional               = local.cfg.regional_cluster
  deletion_protection    = local.cfg.deletion_protection
}

module "alloydb" {
  source   = "../modules/alloydb"
  for_each = local.cfg.databases

  project_id           = local.cfg.project_id
  region               = local.cfg.region
  resource_name_prefix = local.cfg.resource_name_prefix
  db_name              = each.key
  database_user        = each.value.user
  cpu_count            = each.value.cpu_count
  password_rotation    = each.value.password_rotation
  network_id           = module.network.network_id
  psa_connection       = module.network.psa_connection
  deletion_protection  = local.cfg.deletion_protection
}

module "artifact_registry" {
  source = "../modules/artifact-registry"

  project_id           = local.cfg.project_id
  region               = local.cfg.region
  resource_name_prefix = local.cfg.resource_name_prefix
  reader_members       = ["serviceAccount:${module.gke.node_service_account}"]
  writer_members       = var.ci_writer_member == "" ? [] : [var.ci_writer_member]
}

module "workload_identity" {
  source = "../modules/workload-identity"

  project_id                 = local.cfg.project_id
  resource_name_prefix       = local.cfg.resource_name_prefix
  kubernetes_namespace       = var.app_namespace
  kubernetes_service_account = var.app_ksa_name

  secret_ids           = { for k, db in module.alloydb : "${k}-db-password" => db.secret_id }
  grant_alloydb_client = true
}

# Single Direct WIF identity for GitHub Actions, used by BOTH the image
# build/push workflow and the Terraform pipeline.
module "github_wif" {
  source = "../modules/github-wif"
  count  = local.cfg.wif_provider_enabled ? 1 : 0

  project_id           = local.cfg.project_id
  resource_name_prefix = local.cfg.resource_name_prefix
  github_repositories  = var.github_repositories

  depends_on = [google_project_service.apis]
}

locals {
  # Projects the identity is granted into (defaults to just this env's project).
  wif_projects = length(var.wif_target_projects) > 0 ? var.wif_target_projects : [local.cfg.project_id]

  # repo × project × role — static keys so for_each is plan-safe; only populated
  # in the env that hosts the provider. The member string embeds the pool name.
  ci_grants = local.cfg.wif_provider_enabled ? {
    for t in setproduct(var.github_repositories, local.wif_projects, var.ci_roles) :
    "${t[0]}::${t[1]}::${t[2]}" => {
      project = t[1]
      role    = t[2]
      member  = "principalSet://iam.googleapis.com/${one(module.github_wif[*].pool_name)}/attribute.repository/${t[0]}"
    }
  } : {}
}

resource "google_project_iam_member" "ci" {
  for_each = local.ci_grants
  project  = each.value.project
  role     = each.value.role
  member   = each.value.member
}
