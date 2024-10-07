# Enables required APIs.
module "cdn" {
  source = "./cdn"

  project_name = var.project_name
  region       = var.region
}

module "secrets" {
  source       = "./secrets"
  project_id   = var.project_id
  project_name = var.project_name
  region       = var.region

  ui_firebase_secret_id   = var.ui_firebase_secret_id
  ui_googlemaps_secret_id = var.ui_googlemaps_secret_id

  google_firebase_apple_ios_app_bundle_id      = google_firebase_apple_app.ios_app.bundle_id
  google_firebase_android_app_sha1_fingerprint = one(data.google_firebase_android_app.android_sha.sha1_hashes)
  google_firebase_android_app_package_name     = google_firebase_android_app.android_app.package_name
  web_backend_server_url                       = one(google_cloud_run_service.utrade.status).url

  GOOGLE_CLOUD_WEB_IDP_GOOGLE_OAUTH_SECRET = var.GOOGLE_CLOUD_WEB_IDP_GOOGLE_OAUTH_SECRET

  FIREBASE_API_KEY             = var.FIREBASE_API_KEY
  FIREBASE_AUTH_DOMAIN         = var.FIREBASE_AUTH_DOMAIN
  FIREBASE_DATABASE_URL        = var.FIREBASE_DATABASE_URL
  FIREBASE_PROJECT_ID          = var.FIREBASE_PROJECT_ID
  FIREBASE_STORAGE_BUCKET      = var.FIREBASE_STORAGE_BUCKET
  FIREBASE_MESSAGING_SENDER_ID = var.FIREBASE_MESSAGING_SENDER_ID
  FIREBASE_APP_ID              = var.FIREBASE_APP_ID


  create_secret = var.create_secret
}

variable "env" {
  type    = string
  default = "dev" # "staging" ou "prod"
}

output "environment" {
  value = var.env
}
resource "google_project_service" "google_services_default" {
  provider = google-beta.no_user_project_override
  project  = var.project_id
  for_each = toset([
    "cloudbilling.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "identitytoolkit.googleapis.com",
    "secretmanager.googleapis.com",
    "serviceusage.googleapis.com",
  ])
  service = each.key

  # Don't disable the service if the resource block is removed by accident.
  disable_on_destroy         = false
  disable_dependent_services = true
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
  value = google_service_account_key.github_actions_key.private_key
  # sensitive = true
}


resource "google_storage_bucket" "bucket_gcf_source" {
  name                        = "${var.project_name}-${var.region}-gcf-source" # Every bucket name must be globally unique
  location                    = "US"
  uniform_bucket_level_access = true
}

output "function_uri" {
  value = google_cloudfunctions_function.utrade_auth_before_sign_in.https_trigger_url
}

// Création d'un rôle personnalisé avec les permissions nécessaires
resource "google_project_iam_custom_role" "limited_service_user" {
  role_id     = "limitedServiceUser"
  title       = "Limited Service User"
  description = "Can use specific service account and nothing else"
  permissions = ["iam.serviceAccounts.actAs"]
}

