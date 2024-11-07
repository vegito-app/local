module "gcloud" {
  source       = "../../gcloud"
  environment  = "dev"
  project_name = data.google_project.project.name
  project_id   = var.project_id

  cloud_storage_location    = var.cloud_storage_location
  application_backend_image = var.application_backend_image
  region                    = var.region
  ui_firebase_secret_id     = var.ui_firebase_secret_id
  ui_googlemaps_secret_id   = var.ui_googlemaps_secret_id
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
