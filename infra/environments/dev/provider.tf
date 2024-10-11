# Terraform configuration to set up providers by version.
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.7.0"
    }
  }
}

provider "google" {
  credentials = file(var.google_credentials_file)
  project     = var.project_id
  region      = var.region
}
