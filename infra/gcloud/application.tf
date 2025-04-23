resource "google_service_account" "application_backend_cloud_run_sa" {
  account_id   = "production-application-backend"
  display_name = "Application Backend Cloud Run"
}

locals {
  google_cloud_run_service = format("%s-%s-%s-application-backend", var.environment, var.project_name, var.region)
}

# Enables required APIs.
resource "google_project_service" "application_backend_services" {
  provider = google-beta.no_user_project_override
  project  = var.project_id
  for_each = toset([
    "run.googleapis.com",
  ])
  service = each.key

  # Don't disable the service if the resource block is removed by accident.
  disable_on_destroy         = false
  disable_dependent_services = true
}

resource "google_cloud_run_service" "application_backend" {
  name     = local.google_cloud_run_service
  location = var.region
  template {
    spec {
      containers {
        image = var.application_backend_image
        env {
          name  = "FIREBASE_PROJECT_ID"
          value = google_firebase_project.default.id
        }
        env {
          name  = "VAULT_ADDR"
          value = "http://vault.vault.svc.cluster.local:8200"
        }
        env {
          name  = "VAULT_TRANSIT_KEY_NAME"
          value = "recovery"
        }
        env {
          name  = "FIREBASE_ADMINSDK_SERVICEACCOUNT_ID"
          value = google_secret_manager_secret_version.firebase_adminsdk_secret_version.id
        }
        env {
          name  = "UI_CONFIG_FIREBASE_SECRET_ID"
          value = google_secret_manager_secret_version.firebase_config_web_version.id
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
  depends_on = [
    google_project_service.application_backend_services,
    google_artifact_registry_repository_iam_member.application_backend_repo_read_member,
    google_secret_manager_secret_iam_member.application_backend_wep_googlemaps_api_key_secret_read,
    google_secret_manager_secret_iam_member.application_backend_firebase_web_uiconfig_secret_read,
    google_secret_manager_secret_iam_member.application_backend_firebase_adminsdk_secret_read
  ]
}

output "backend_url" {
  value = length(google_cloud_run_service.application_backend.status) > 0 ? one(google_cloud_run_service.application_backend.status[*].url) : ""
}

# Make Cloud Run service publicly accessible
resource "google_cloud_run_service_iam_member" "allow_unauthenticated" {
  project  = var.project_id
  service  = google_cloud_run_service.application_backend.name
  location = google_cloud_run_service.application_backend.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_artifact_registry_repository_iam_member" "application_backend_repo_read_member" {
  project    = var.project_id
  location   = var.region
  repository = google_artifact_registry_repository.private_docker_repository.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.application_backend_cloud_run_sa.email}"
}

resource "google_secret_manager_secret_iam_member" "application_backend_wep_googlemaps_api_key_secret_read" {
  secret_id = google_secret_manager_secret_version.web_google_maps_api_key_version.secret
  member    = "serviceAccount:${google_service_account.application_backend_cloud_run_sa.email}"
  role      = "roles/secretmanager.secretAccessor"
}

resource "google_secret_manager_secret_iam_member" "application_backend_firebase_web_uiconfig_secret_read" {
  secret_id = google_secret_manager_secret_version.firebase_config_web_version.secret
  member    = "serviceAccount:${google_service_account.application_backend_cloud_run_sa.email}"
  role      = "roles/secretmanager.secretAccessor"
}
resource "google_secret_manager_secret_iam_member" "application_backend_firebase_adminsdk_secret_read" {
  secret_id = google_secret_manager_secret_version.firebase_adminsdk_secret_version.secret
  member    = "serviceAccount:${google_service_account.application_backend_cloud_run_sa.email}"
  role      = "roles/secretmanager.secretAccessor"
}

resource "google_project_iam_member" "application_backend_vault_access" {
  project = var.project_id
  role    = "roles/iam.workloadIdentityUser"
  member  = "serviceAccount:${google_service_account.application_backend_cloud_run_sa.email}"
}
