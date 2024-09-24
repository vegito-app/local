# Terraform configuration to set up providers by version.
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.2.0"
    }
  }
}

provider "google" {
  credentials = file("./google-cloud-credentials")
  project     = var.project_id
  region      = var.region
}
