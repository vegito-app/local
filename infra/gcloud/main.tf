# Enables required APIs.
output "environment" {
  value = var.environment
}
module "cdn" {
  source      = "./cdn"
  environment = var.environment

  project_id = var.project_id
  region     = var.region
}

module "secrets" {
  source      = "./secrets"
  environment = var.environment

  GOOGLE_IDP_OAUTH_SECRET = var.GOOGLE_IDP_OAUTH_SECRET

  create_secret = var.create_secret
}

variable "env" {
  type    = string
  default = "dev" # "staging" ou "prod"
}

resource "google_storage_bucket" "bucket_gcf_source" {
  name                        = "${var.environment}-${var.project_id}-${var.region}-gcf-source" # Every bucket name must be globally unique
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
  project  = var.project_id
  for_each = toset([
    "geocoding-backend.googleapis.com",
    # "maps-android-backend.googleapis.com ",
    "maps-backend.googleapis.com",
    "maps-ios-backend.googleapis.com",
    "directions-backend.googleapis.com"
  ])
  service = each.key

  # Don't disable the service if the resource block is removed by accident.
  disable_on_destroy         = false
  disable_dependent_services = true
}

resource "google_service_account" "github_actions" {
  account_id   = "github-actions-main"
  display_name = "Github Actions"
  project      = var.project_id
}

resource "google_service_account_key" "github_actions_key" {
  service_account_id = google_service_account.github_actions.account_id
  private_key_type   = "TYPE_GOOGLE_CREDENTIALS_FILE"
}

output "github_actions_private_key" {
  value     = google_service_account_key.github_actions_key.private_key
  sensitive = true
}

resource "google_storage_bucket" "bucket_tf_state_eu" {
  name     = "utrade-${var.region}-tf-state"
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
  value       = google_storage_bucket.bucket_tf_state_eu.url
}
