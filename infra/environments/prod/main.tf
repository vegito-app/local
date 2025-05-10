locals {
  environment = "prod"
}

data "google_project" "project" {
  project_id = var.project_id
}

module "cdn" {
  source      = "./cdn"
  environment = local.environment

  project_id = data.google_project.project.project_id
  region     = var.region
}

# module "vault" {
#   source = "../../vault"

#   project_id = data.google_project.project.project_id
#   region     = var.region
# }

module "kubernetes" {
  source = "./kubernetes"
  region = var.region

  project_id     = data.google_project.project.project_id
  project_number = data.google_project.project.number

  vault_tf_apply_member_sa_list = concat(
    local.prod_admins_service_accounts,
    local.root_admins_service_accounts,
  )
}

module "gcloud" {
  source = "../../gcloud"
  region = var.region

  environment = local.environment

  bucket_tf_state_eu_global_name = local.bucket_tf_state_eu_global_name

  cloud_storage_location = var.cloud_storage_location

  project_name = data.google_project.project.name
  project_id   = data.google_project.project.project_id

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


import {
  to = module.gcloud.google_storage_bucket.bucket_tf_state_eu_global
  id = "global-${var.region}-tf-state"
}

# Enables required APIs.
resource "google_project_service" "google_services_default" {
  provider = google-beta.no_user_project_override
  project  = data.google_project.project.project_id
  for_each = toset([
    "cloudbilling.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudkms.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "identitytoolkit.googleapis.com",
    "secretmanager.googleapis.com",
    "serviceusage.googleapis.com",
  ])
  service = each.key

  # Don't disable the service if the resource block is removed by accident.
  disable_on_destroy         = false
  disable_dependent_services = true
}

resource "google_project_iam_member" "application_backend_vault_access" {
  project = data.google_project.project.project_id
  role    = "roles/iam.workloadIdentityUser"
  member  = "serviceAccount:${module.gcloud.application_backend_cloud_run_sa_email}"
}
