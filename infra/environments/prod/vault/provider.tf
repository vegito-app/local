data "google_client_config" "default" {}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.36.1"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "4.7.0"
    }
  }
  backend "gcs" {
    bucket = "global-europe-west1-tf-state"
    prefix = "terraform/state/vault/prod"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  # NE PAS définir credentials, ni GOOGLE_APPLICATION_CREDENTIALS
}

provider "vault" {
  address = var.vault_addr
}
