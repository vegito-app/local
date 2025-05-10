# Enables required APIs.
output "environment" {
  value = var.environment
}

variable "env" {
  type    = string
  default = "dev" # "staging" ou "prod"
}

resource "google_storage_bucket" "bucket_gcf_source" {
  name     = "${var.environment}-${var.project_name}-${var.region}-gcf-source" # Every bucket name must be globally unique
  location = var.cloud_storage_location

  uniform_bucket_level_access = true
}

resource "google_project_iam_member" "compute_service_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
}

resource "google_project_iam_member" "compute_service_artifactory_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
}

resource "google_project_iam_member" "compute_service_artifactory_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
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
  project  = var.project_id
  for_each = toset([
    "directions-backend.googleapis.com",
    "geocoding-backend.googleapis.com",
    "maps-android-backend.googleapis.com",
    "maps-backend.googleapis.com",
    "maps-ios-backend.googleapis.com",
  ])
  service = each.key

  # Don't disable the service if the resource block is removed by accident.
  disable_on_destroy         = false
  disable_dependent_services = true
}

variable "bucket_tf_state_eu_global_name" {}

resource "google_storage_bucket" "bucket_tf_state_eu_global" {
  name     = var.bucket_tf_state_eu_global_name
  location = var.region

  storage_class = "STANDARD"

  force_destroy = false # Do not remove bucket if remaining tf_state

  uniform_bucket_level_access = true # Needed to use with tf tf_lock

  versioning {
    enabled = true
  }
}

output "tf_state_bucket_url" {
  description = "Terraform state GCS bucket URL."
  value       = google_storage_bucket.bucket_tf_state_eu_global.url
}
