# Terraform configuration to set up providers by version.
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.7.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 6.7.0"
    }
  }
  backend "gcs" {
    bucket = "global-europe-west1-tf-state"
    prefix = "terraform/state/prod"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Configures the provider to use the resource block's specified project for quota checks.
provider "google-beta" {
  alias                 = "no_user_project_override"
  user_project_override = true
}
