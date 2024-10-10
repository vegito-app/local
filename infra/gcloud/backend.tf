

resource "google_service_account" "application_backend_cloud_run_sa" {
  account_id   = "application-backend-cloud-run"
  display_name = "Application Backend Cloud Run"
  project      = var.project_id
}

resource "google_cloud_run_service" "application_backend" {
  name     = "${var.project_id}-application-backend-${var.region}"
  location = var.region
  template {
    spec {
      containers {
        image = var.application_backend_image
        env {
          name  = "FIREBASE_PROJECT_ID"
          value = google_firebase_project.utrade.id
        }
        env {
          name  = "FIREBASE_ADMINSDK_SERVICEACCOUNT_ID"
          value = google_secret_manager_secret_version.firebase_admin_secret_version.id
        }
        env {
          name  = "UI_CONFIG_FIREBASE_SECRET_ID"
          value = google_secret_manager_secret_version.firebase_config_version.id
        }
        env {
          name  = "UI_CONFIG_GOOGLEMAPS_SECRET_ID"
          value = google_secret_manager_secret_version.web_google_maps_api_key_version.id
        }
      }
      service_account_name = google_service_account.application_backend_cloud_run_sa.email
      // Ajoutez au
    }
  }
  traffic {
    percent         = 100
    latest_revision = true
  }
}

output "backend" {
  value = length(google_cloud_run_service.application_backend.status) > 0 ? one(google_cloud_run_service.application_backend.status[*].url) : ""
}

# Make Cloud Run service publicly accessible
resource "google_cloud_run_service_iam_member" "allow_unauthenticated" {
  service  = google_cloud_run_service.application_backend.name
  location = google_cloud_run_service.application_backend.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}
