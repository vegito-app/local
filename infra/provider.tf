# Terraform configuration to set up providers by version.
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.5.0"
    }
  }
}

provider "google" {
  credentials = file("./gcloud-credentials")
  project     = var.project_id
  region      = var.region
}
