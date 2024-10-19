output "project" {
  value = var.project_id
}

module "gcloud" {
  source      = "../../gcloud"
  environment = "prod"

  # project_name           = var.project_name
  project_id = var.project_id
  # billing_account        = data.google_project.project.billing_account
  region                 = var.region
  cloud_storage_location = var.cloud_storage_location
  # project_name              = data.google_project.project.project_name
  public_repository_id      = var.public_repository_id
  repository_id             = var.repository_id
  application_backend_image = var.application_backend_image

  ui_firebase_secret_id   = var.ui_firebase_secret_id
  ui_googlemaps_secret_id = var.ui_googlemaps_secret_id
  GOOGLE_IDP_OAUTH_SECRET = var.GOOGLE_IDP_OAUTH_SECRET
}

# Enables required APIs.
resource "google_project_service" "google_services_default" {
  provider = google-beta.no_user_project_override
  project  = var.project_id
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

data "google_project" "project" {
  project_id = var.project_id
}

output "project_number" {
  value = data.google_project.project.number
}

output "project_name" {
  value = data.google_project.project.name
}

# resource "google_project_iam_member" "member" {
#   role    = "roles/resourcemanager.projectCreator"
#   member  = "serviceAccount:${var.root_admin_service_account_email}"
#   project = data.google_project.project.project_id
# }

# resource "google_project" "project_staging" {
#   name       = "Staging - ${data.google_project.project.name}"
#   project_id = "staging-${var.project_id}"
# }

# data "google_service_account" "root_admin_sercice_accound_staging" {
#   account_id = var.root_admin_service_account_email
# }

# resource "google_service_account" "account_staging" {
#   account_id = "staging-${split("@", "${var.root_admin_service_account_email}")[0]}"

#   display_name = "Staging Administrator Service Account"
#   project      = google_project.project_staging.project_id
# }

# resource "google_service_account_key" "key_staging" {
#   service_account_id = google_service_account.account_staging.name
# }

# resource "google_project" "project_dev" {
#   name       = "Dev - ${data.google_project.project.name}"
#   project_id = "dev-${var.project_id}"
# }

# data "google_service_account" "root_admin_sercice_accound_dev" {
#   account_id = var.root_admin_service_account_email
# }

# resource "google_service_account" "account_dev" {
#   account_id   = "dev-${split("@", "${var.root_admin_service_account_email}")[0]}"
#   display_name = "Dev Administrator Service Account"
#   project      = google_project.project_dev.project_id
# }

# resource "google_service_account_key" "key_dev" {
#   service_account_id = google_service_account.account_dev.name
# }
