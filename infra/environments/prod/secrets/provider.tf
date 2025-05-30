# Terraform configuration to set up providers by version.
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.36.1"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}
