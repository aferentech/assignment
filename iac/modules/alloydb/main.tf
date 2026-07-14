terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.30"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5"
    }
  }
}

resource "google_secret_manager_secret" "db_password" {
  project   = var.project_id
  secret_id = "${var.resource_name_prefix}-${var.db_name}-db-password"

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "random_password" "db" {
  length           = 24
  special          = true
  override_special = "_-#%&"

  keepers = {
    rotation = var.password_rotation
  }
}

resource "google_secret_manager_secret_version" "db_password" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = random_password.db.result
}

resource "google_alloydb_cluster" "this" {
  project    = var.project_id
  cluster_id = "${var.resource_name_prefix}-${var.db_name}"
  location   = var.region

  network_config {
    network = var.network_id
  }

  initial_user {
    user     = var.database_user
    password = random_password.db.result
  }

  deletion_protection = var.deletion_protection

  deletion_policy = var.deletion_protection ? "DEFAULT" : "FORCE"
  depends_on      = [var.psa_connection]
}

resource "google_alloydb_instance" "primary" {
  cluster       = google_alloydb_cluster.this.name
  instance_id   = "${var.resource_name_prefix}-${var.db_name}-primary"
  instance_type = "PRIMARY"

  machine_config {
    cpu_count = var.cpu_count
  }
}
