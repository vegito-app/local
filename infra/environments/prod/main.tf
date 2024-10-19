output "project" {
  value = var.project_id
}

module "gcloud" {
  source      = "../../gcloud"
  environment = "prod"

  project_id                = var.project_id
  region                    = var.region
  cloud_storage_location    = var.cloud_storage_location
  public_repository_id      = var.public_repository_id
  repository_id             = var.repository_id
  application_backend_image = var.application_backend_image

  ui_firebase_secret_id   = var.ui_firebase_secret_id
  ui_googlemaps_secret_id = var.ui_googlemaps_secret_id
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
