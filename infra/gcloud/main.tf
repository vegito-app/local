# Enables required APIs.
output "environment" {
  value = var.environment
}

variable "env" {
  type    = string
  default = "dev" # "staging" ou "prod"
}

data "google_project" "project" {
  project_id = var.project_id
}

resource "google_storage_bucket" "bucket_gcf_source" {
  name                        = "${var.environment}-${data.google_project.project.project_id}-${var.region}-gcf-source" # Every bucket name must be globally unique
  location                    = var.cloud_storage_location
  uniform_bucket_level_access = true
}

// Création d'un rôle personnalisé avec les permissions nécessaires
resource "google_project_iam_custom_role" "limited_service_user" {
  role_id     = "limitedServiceUser"
  title       = "Limited Service User"
  description = "Can use specific service account and nothing else"
  permissions = ["iam.serviceAccounts.actAs"]
}

resource "google_project_service" "google_services_maps" {
  provider = google-beta.no_user_project_override
  project  = data.google_project.project.project_id
  for_each = toset([
    "directions-backend.googleapis.com",
    "geocoding-backend.googleapis.com",
    # "maps-android-backend.googleapis.com ",
    "maps-backend.googleapis.com",
    "maps-ios-backend.googleapis.com",
  ])
  service = each.key

  # Don't disable the service if the resource block is removed by accident.
  disable_on_destroy         = false
  disable_dependent_services = true
}

