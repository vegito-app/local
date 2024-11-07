# Terraform configuration to set up providers by version.
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.10.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 6.10.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Configures the provider to use the resource block's specified project for quota checks.
provider "google-beta" {
  alias                 = "no_user_project_override"
  project               = var.project_id
  user_project_override = true
}
