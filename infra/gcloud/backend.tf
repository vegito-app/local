resource "google_cloud_run_service" "utrade" {
  name     = "utrade"
  location = var.region
  template {
    spec {
      containers {
        image = var.application_image
        env {
          name  = "GOOGLE_CLOUD_PROJECT"
          value = var.project_id
        }
        env {
          name  = "FIREBASE_ADMINSDK_SERVICEACCOUNT_ID"
          value = google_service_account.firebase_admin.id
        }
        env {
          name  = "UI_CONFIG_FIREBASE_SECRET_ID"
          value = var.ui_firebase_secret_id
        }
        env {
          name  = "UI_CONFIG_GOOGLEMAPS_SECRET_ID"
          value = var.ui_googlemaps_secret_id
        }
      }
      // Ajoutez au
    }
  }
  traffic {
    percent         = 100
    latest_revision = true
  }
}

output "backend" {
  value = one(google_cloud_run_service.utrade.status[*].url)
}

# Make Cloud Run service publicly accessible
resource "google_cloud_run_service_iam_member" "allow_unauthenticated" {
  service  = google_cloud_run_service.utrade.name
  location = google_cloud_run_service.utrade.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}
