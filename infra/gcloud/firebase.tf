# Learn more about the relationship between Firebase projects and Google Cloud: https://firebase.google.com/docs/projects/learn-more?authuser=0&hl=fr#firebase-cloud-relationship.
resource "google_firebase_project" "moov" {
  # Use the provider that performs quota checks from now on
  provider = google-beta

  project = var.project_id

  # Waits for the required APIs to be enabled.
  depends_on = [
    google_project_service.google_services_firebase
  ]
}

output "firebase_project_id" {
  description = "an identifier for the resource with format projects/{{project}}"
  value       = google_firebase_project.moov.id
}

output "firebase_project_project_number" {
  description = "The number of the google project that firebase is enabled on."
  value       = google_firebase_project.moov.project_number
}
output "firebase_project_display_name" {
  description = "The GCP project display name"
  value       = google_firebase_project.moov.display_name
}

# Enables Firebase services for the new project created above.
# This action essentially "creates a Firebase project" and allows the project to use
# Firebase services (like Firebase Authentication) and
# Firebase tooling (like the Firebase console).
resource "google_project_service" "google_services_firebase" {
  provider = google-beta.no_user_project_override
  project  = var.project_id
  for_each = toset([
    "firebase.googleapis.com",
    "firebasedatabase.googleapis.com",
    "firestore.googleapis.com",
  ])
  service = each.key

  # Don't disable the service if the resource block is removed by accident.
  disable_on_destroy         = false
  disable_dependent_services = true
}

# Provisions the default Realtime Database default instance.
resource "google_firebase_database_instance" "moov" {
  provider = google-beta
  project  = google_firebase_project.moov.project
  region   = var.region

  instance_id   = "${var.environment}-${google_firebase_project.moov.project}-rtdb"
  type          = "USER_DATABASE"
  desired_state = "ACTIVE"

  depends_on = [
    google_firebase_project.moov,
  ]
}

output "firebase_database_id" {
  description = "an identifier for the resource with format projects/{{project}}/locations/{{region}}/instances/{{instance_id}}"
  value       = google_firebase_database_instance.moov.id
}

output "firebase_database_name" {
  description = "The fully-qualified resource name of the Firebase Realtime Database, in the format: projects/PROJECT_NUMBER/locations/GOOGLE_CLOUD_REGION_IDENTIFIER/instances/INSTANCE_ID PROJECT_NUMBER: The Firebase project's ProjectNumber Learn more about using project identifiers in Google's AIP 2510 standard."
  value       = google_firebase_database_instance.moov.name
}

output "firebase_database_database_url" {
  description = "The database URL in the form of https://{instance-id}.firebaseio.com for europe-west1 instances or https://{instance-id}.{region}.firebasedatabase.app in other regions."
  value       = google_firebase_database_instance.moov.database_url
}

output "firebase_database_state" {
  description = "The current database state. Set desired_state to :DISABLED to disable the database and :ACTIVE to reenable the database"
  value       = google_firebase_database_instance.moov.state
}

# Creates a Firebase Android App in the new project created above.
# Learn more about the relationship between Firebase Apps and Firebase projects.
resource "google_firebase_android_app" "android_app" {
  provider = google-beta

  project      = var.project_id
  display_name = "Utrade Android app (${var.environment})" # learn more about an app's display name
  package_name = "${var.environment}.mobile.app.android"   # learn more about an app's package name

  # Wait for Firebase to be enabled in the Google Cloud project before creating this App.
  depends_on = [
    google_firebase_project.moov,
  ]
}

# Récupérer la configuration client Firebase pour iOS
data "google_firebase_android_app_config" "android_config" {
  provider = google-beta
  project  = var.project_id
  app_id   = google_firebase_android_app.android_app.app_id
}

data "google_firebase_android_app" "android_sha" {
  provider = google-beta
  project  = var.project_id
  app_id   = google_firebase_android_app.android_app.app_id
}

output "android_sha1" {
  value       = data.google_firebase_android_app.android_sha.sha1_hashes
  description = "Empreinte SHA-1 de l'application Android"
}

# Creates a Firebase Apple-platforms App in the new project created above.
resource "google_firebase_apple_app" "ios_app" {
  provider     = google-beta
  project      = var.project_id
  display_name = "Utrade Apple app (${var.environment})"
  bundle_id    = "${var.environment}.mobile.app.apple"

  # Wait for Firebase to be enabled in the Google Cloud project before creating this App.
  depends_on = [
    google_firebase_project.moov,
  ]
}

# Récupérer la configuration client Firebase pour iOS
data "google_firebase_apple_app_config" "ios_config" {
  provider = google-beta
  project  = var.project_id
  app_id   = google_firebase_apple_app.ios_app.app_id
}

# Creates a Firebase Web App in the new project created above.
resource "google_firebase_web_app" "web_app" {
  provider = google-beta
  project  = var.project_id
  # display_name is used as unique ID for this resource
  display_name = "Utrade Web app (${var.environment})"

  # The other App types (Android and Apple) use "DELETE" by default.
  # Web apps don't use "DELETE" by default due to backward-compatibility.
  deletion_policy = "DELETE"

  # Wait for Firebase to be enabled in the Google Cloud project before creating this App.
  depends_on = [
    google_firebase_project.moov
  ]
}

data "google_firebase_web_app_config" "web_app_config" {
  provider   = google-beta
  project    = var.project_id
  web_app_id = google_firebase_web_app.web_app.app_id
}

output "oauth_redirect_uri" {
  description = "Web OAUTH redirect URI (must authorized set on google console 'ID clients OAuth 2.0' credentials)"
  value       = "https://${google_firebase_project.moov.id}.firebaseapp.com/__/auth/handler"
}

resource "google_service_account" "firebase_admin_service_account" {
  account_id   = "${var.environment}-firebase-admin-sa"
  display_name = "Firebase Admin SDK Service Account"
  description  = "Ce compte de service est utilisé par Firebase Admin SDK pour interagir avec Firebase"
}

resource "google_project_iam_member" "firebase_admin_service_agent" {
  project = var.project_id
  role    = "roles/firebase.sdkAdminServiceAgent"
  member  = "serviceAccount:${google_service_account.firebase_admin_service_account.email}"
}

resource "google_project_iam_member" "firebase_token_creator" {
  project = var.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = "serviceAccount:${google_service_account.firebase_admin_service_account.email}"
}

resource "google_secret_manager_secret" "firebase_admin_service_account_secret" {
  secret_id = "${var.environment}-firebase-adminsdk-service-account-key"
  project   = var.project_id

  labels = {
    environment = "production"
  }

  replication {
    auto {

    }
  }
}

resource "google_service_account_key" "firebase_admin_service_account_key" {
  service_account_id = google_service_account.firebase_admin_service_account.name
}

resource "google_secret_manager_secret_version" "firebase_adminsdk_secret_version" {
  secret      = google_secret_manager_secret.firebase_admin_service_account_secret.id
  secret_data = base64decode(google_service_account_key.firebase_admin_service_account_key.private_key)
}

resource "google_secret_manager_secret_iam_member" "firebase_admin_service_account_secret_member" {
  secret_id = google_secret_manager_secret.firebase_admin_service_account_secret.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.application_backend_cloud_run_sa.email}"
}

resource "google_secret_manager_secret" "firebase_config_web" {
  secret_id = "${var.environment}-firebase-config-secret"

  replication {
    auto {

    }
  }
}

resource "google_secret_manager_secret_version" "firebase_config_web_version" {
  secret = google_secret_manager_secret.firebase_config_web.id
  secret_data = jsonencode({
    apiKey            = data.google_firebase_web_app_config.web_app_config.api_key
    authDomain        = data.google_firebase_web_app_config.web_app_config.auth_domain
    databaseURL       = data.google_firebase_web_app_config.web_app_config.database_url
    projectId         = data.google_firebase_web_app_config.web_app_config.project
    storageBucket     = data.google_firebase_web_app_config.web_app_config.storage_bucket
    messagingSenderId = data.google_firebase_web_app_config.web_app_config.messaging_sender_id
    appId             = google_firebase_web_app.web_app.app_id
  })
}
