locals {
  environment = terraform.workspace
  cfg         = var.environments[terraform.workspace]
}
