# Enables Firebase services for the new project created above.
# This action essentially "creates a Firebase project" and allows the project to use
# Firebase services (like Firebase Authentication) and
# Firebase tooling (like the Firebase console).
# Learn more about the relationship between Firebase projects and Google Cloud: https://firebase.google.com/docs/projects/learn-more?authuser=0&hl=fr#firebase-cloud-relationship.
resource "google_firebase_project" "utrade" {
  # Use the provider that performs quota checks from now on
  provider = google-beta

  project = var.project_id

  # Waits for the required APIs to be enabled.
  depends_on = [
    google_project_service.utrade
  ]
}

output "firebase_project_id" {
  description = "an identifier for the resource with format projects/{{project}}"
  value       = google_firebase_project.utrade.id
}

output "firebase_project_project_number" {
  description = "The number of the google project that firebase is enabled on."
  value       = google_firebase_project.utrade.project_number
}
output "firebase_project_display_name" {
  description = "The GCP project display name"
  value       = google_firebase_project.utrade.display_name
}

# Provisions the default Realtime Database default instance.
resource "google_firebase_database_instance" "utrade" {
  provider = google-beta
  project  = var.project_id
  # See available locations: https://firebase.google.com/docs/projects/locations#utrade-locations
  region = var.region
  # This value will become the first segment of the database's URL.
  instance_id = "${var.project_id}-default-rtdb"
  type        = "DEFAULT_DATABASE"

  # Wait for Firebase to be enabled in the Google Cloud project before initializing Realtime Database.
  depends_on = [
    google_firebase_project.utrade,
  ]
}
output "firebase_database_id" {
  description = "an identifier for the resource with format projects/{{project}}/locations/{{region}}/instances/{{instance_id}}"
  value       = google_firebase_database_instance.utrade.id
}
output "firebase_database_name" {
  description = "The fully-qualified resource name of the Firebase Realtime Database, in the format: projects/PROJECT_NUMBER/locations/REGION_IDENTIFIER/instances/INSTANCE_ID PROJECT_NUMBER: The Firebase project's ProjectNumber Learn more about using project identifiers in Google's AIP 2510 standard."
  value       = google_firebase_database_instance.utrade.name
}
output "firebase_database_database_url" {
  description = "The database URL in the form of https://{instance-id}.firebaseio.com for us-central1 instances or https://{instance-id}.{region}.firebasedatabase.app in other regions."
  value       = google_firebase_database_instance.utrade.database_url
}
output "firebase_database_state" {
  description = "The current database state. Set desired_state to :DISABLED to disable the database and :ACTIVE to reenable the database"
  value       = google_firebase_database_instance.utrade.state
}


# Creates a Firebase Android App in the new project created above.
# Learn more about the relationship between Firebase Apps and Firebase projects.
resource "google_firebase_android_app" "utrade" {
  provider = google-beta

  project      = var.project_id
  display_name = "Utrade Android app" # learn more about an app's display name
  package_name = "android.app.utrade" # learn more about an app's package name

  # Wait for Firebase to be enabled in the Google Cloud project before creating this App.
  depends_on = [
    google_firebase_project.utrade,
  ]
}

# Creates a Firebase Apple-platforms App in the new project created above.
resource "google_firebase_apple_app" "utrade" {
  provider     = google-beta
  project      = var.project_id
  display_name = "Utrade Apple app"
  bundle_id    = "apple.app.utrade"

  # Wait for Firebase to be enabled in the Google Cloud project before creating this App.
  depends_on = [
    google_firebase_project.utrade,
  ]
}

# Creates a Firebase Web App in the new project created above.
resource "google_firebase_web_app" "utrade" {
  provider     = google-beta
  project      = var.project_id
  display_name = "Utrade Web app"

  # The other App types (Android and Apple) use "DELETE" by default.
  # Web apps don't use "DELETE" by default due to backward-compatibility.
  deletion_policy = "DELETE"

  # Wait for Firebase to be enabled in the Google Cloud project before creating this App.
  depends_on = [
    google_firebase_project.utrade,
  ]
}
