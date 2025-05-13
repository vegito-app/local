locals {
  environment = "dev"
}

module "gcloud" {
  bucket_tf_state_eu_global_name = "global-${var.region}-tf-state-dev"

  source      = "../../gcloud"
  region      = var.region
  environment = local.environment
  project_id  = var.project_id

  cloud_storage_location = var.cloud_storage_location
}

module "application" {
  source = "../../../application/run"

  region       = var.region
  environment  = local.environment
  project_name = data.google_project.project.name
  project_id   = var.project_id

  application_backend_image = var.application_backend_image

  google_idp_oauth_key_secret_id       = var.google_idp_oauth_key_secret_id
  google_idp_oauth_client_id_secret_id = var.google_idp_oauth_client_id_secret_id
}

data "google_project" "project" {
  project_id = var.project_id
}

# Enables required APIs.
resource "google_project_service" "google_services_default" {
  provider = google-beta.no_user_project_override
  project  = data.google_project.project.id
  for_each = toset([
    "cloudbilling.googleapis.com",
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
