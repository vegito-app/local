module "infra" {
  source                 = "../../gcloud"
  environment            = "dev"
  cloud_storage_location = "EU"

  application_backend_image    = var.application_backend_image
  project_id                   = var.project_id
  region                       = var.region
  private_docker_repository_id = "prod-docker-repository-private"
  public_docker_repository_id  = "prod-docker-repository-public"
  ui_firebase_secret_id        = var.ui_firebase_secret_id
  ui_googlemaps_secret_id      = var.ui_googlemaps_secret_id
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

data "google_project" "project" {
  project_id = var.project_id
}

output "project_number" {
  value = data.google_project.project.number
}

output "project_name" {
  value = data.google_project.project.name
}
