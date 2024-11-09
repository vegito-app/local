locals {
  environment = "prod"
}

module "cdn" {
  source      = "./cdn"
  environment = local.environment

  project_id = var.project_id
  region     = var.region
}

module "gcloud" {
  source      = "../../gcloud"
  environment = local.environment

  cloud_storage_location = var.cloud_storage_location

  project_name = data.google_project.project.name
  project_id   = var.project_id
  region       = var.region

  google_idp_oauth_client_id_secret_id = var.google_idp_oauth_client_id_secret_id
  google_idp_oauth_key_secret_id       = var.google_idp_oauth_key_secret_id

  application_public_domain = "${local.environment}-${data.google_project.project.name}-${var.region}-application-backend-v4bqtohg4a-ew.a.run.app"
  application_backend_image = var.application_backend_image

  ui_firebase_secret_id   = var.ui_firebase_secret_id
  ui_googlemaps_secret_id = var.ui_googlemaps_secret_id
}

output "project" {
  value = data.google_project.project.id
}

# Enables required APIs.
resource "google_project_service" "google_services_default" {
  provider = google-beta.no_user_project_override
  project  = var.project_id
  for_each = toset([
    "cloudbilling.googleapis.com",
    "identitytoolkit.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "secretmanager.googleapis.com",
    "serviceusage.googleapis.com",
  ])
  service = each.key

  # Don't disable the service if the resource block is removed by accident.
  disable_on_destroy         = false
  disable_dependent_services = true
}

data "google_project" "project" {
  project_id = var.project_id
}

resource "google_storage_bucket" "bucket_tf_state_eu_global" {
  name     = "global-${var.region}-tf-state"
  location = var.region

  storage_class = "STANDARD"

  force_destroy = false # Do not remove bucket if remaining tf_state

  uniform_bucket_level_access = true # Needed to use with tf tf_lock

  versioning {
    enabled = true
  }
}

import {
  to = google_storage_bucket.bucket_tf_state_eu_global
  id = "global-${var.region}-tf-state"
}

output "tf_state_bucket_url" {
  description = "Terraform state GCS bucket URL."
  value       = google_storage_bucket.bucket_tf_state_eu_global.url
}
