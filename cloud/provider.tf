# Terraform configuration to set up providers by version.
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.41"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.41"
    }
  }
}

# Configures the provider to use the resource block's specified project for quota checks.
provider "google-beta" {
  alias                 = "no_user_project_override"
  user_project_override = true
}

provider "google" {
  credentials = file("./google-cloud-credentials")
  project     = var.project_id
  region      = var.region
}
