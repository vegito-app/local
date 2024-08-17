# Enables required APIs.
resource "google_project_service" "utrade" {
  provider = google-beta.no_user_project_override
  project  = var.project_id
  for_each = toset([
    "cloudbilling.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "firebase.googleapis.com",
    "firebasedatabase.googleapis.com",
    "firestore.googleapis.com",
    "identitytoolkit.googleapis.com",
    "secretmanager.googleapis.com",
    "serviceusage.googleapis.com",
  ])
  service = each.key

  # Don't disable the service if the resource block is removed by accident.
  disable_on_destroy         = false
  disable_dependent_services = true
}

resource "google_artifact_registry_repository" "utrade" {
  provider      = google
  location      = var.region
  repository_id = var.repository_id
  description   = "utrade main docker repository"
  format        = "DOCKER"
}

resource "null_resource" "docker_auth" {
  depends_on = [google_artifact_registry_repository.utrade]

  provisioner "local-exec" {
    command = "gcloud auth configure-docker ${var.region}-docker.pkg.dev/${var.project_id}/${var.repository_id}"
  }
}
output "image_url" {
  description = "Project docker container Registry."
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${var.repository_id}"
}

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

# Creates an Identity Platform config.
# Also enables Firebase Authentication with Identity Platform in the project if not.
resource "google_identity_platform_config" "utrade" {

  provider = google-beta
  project  = var.project_id

  # Auto-deletes anonymous users
  autodelete_anonymous_users = true

  # Configures local sign-in methods, like anonymous, email/password, and phone authentication.
  sign_in {
    allow_duplicate_emails = true

    anonymous {
      enabled = true
    }

    email {
      enabled           = true
      password_required = false
    }

    phone_number {
      enabled = true
      test_phone_numbers = {
        "+11231231234" = "000000"
      }
    }
  }

  # Sets an SMS region policy.
  sms_region_config {
    allowlist_only {
      allowed_regions = [
        "US",
        "CA",
      ]
    }
  }

  # Configures blocking functions.
  blocking_functions {
    triggers {
      event_type   = "beforeSignIn"
      function_uri = google_cloudfunctions_function.utrade_auth_before_sign_in.https_trigger_url
    }
    triggers {
      event_type   = "beforeCreate"
      function_uri = google_cloudfunctions_function.utrade_auth_before_create.https_trigger_url
    }
    forward_inbound_credentials {
      refresh_token = true
      access_token  = true
      id_token      = true
    }
  }

  # Configures a temporary quota for new signups for anonymous, email/password, and phone number.
  quota {
    sign_up_quota_config {
      quota          = 1000
      start_time     = timestamp()
      quota_duration = "7200s"
    }
  }

  # Configures authorized domains.
  authorized_domains = [
    "localhost",
    "${var.project_id}.firebaseapp.com",
    "${var.project_id}.web.app",
    trimprefix(one(google_cloud_run_service.utrade.status[*].url), "https://")
  ]

  # Wait for identitytoolkit.googleapis.com to be enabled before initializing Authentication.
  depends_on = [
    google_cloud_run_service.utrade,
    google_project_service.utrade,
  ]
}

resource "google_storage_bucket" "bucket_gcf_source" {
  name                        = "${var.project_name}-${var.region}-gcf-source" # Every bucket name must be globally unique
  location                    = "US"
  uniform_bucket_level_access = true
}

data "archive_file" "utrade_auth_func_src" {
  type        = "zip"
  output_path = "/tmp/auth-function-source.zip"
  source_dir  = "${path.module}/auth/"
}

resource "google_storage_bucket_object" "utrade_auth" {
  name   = "${var.project_name}-${var.region}-${var.application_image}-identity-platform-auth-function-source.zip"
  bucket = google_storage_bucket.bucket_gcf_source.name
  source = data.archive_file.utrade_auth_func_src.output_path # Add path to the zipped function source code
}


resource "google_cloudfunctions_function" "utrade_auth_before_sign_in" {
  name                  = "${var.project_name}-${var.region}-identity-platform-before-signin"
  description           = "OIDC callback before sign in"
  project               = google_firebase_project.utrade.project
  runtime               = "go122"
  entry_point           = "IDPbeforeSignIn" # Set the entry point
  source_archive_bucket = google_storage_bucket.bucket_gcf_source.name
  source_archive_object = google_storage_bucket_object.utrade_auth.name
  service_account_email = google_service_account.firebase_admin.email
  trigger_http          = true

  environment_variables = {
    FIREBASE_ADMINSDK_SERVICEACCOUNT_ID = google_service_account.firebase_admin.id
  }
}

output "auth_func_utrade_before_sign_in_id" {
  value = google_cloudfunctions_function.utrade_auth_before_sign_in.id
}

resource "google_cloudfunctions_function" "utrade_auth_before_create" {
  name        = "${var.project_name}-${var.region}-identity-platform-before-create"
  description = "OIDC callback create user"
  # project               = google_firebase_project.utrade.id
  runtime     = "nodejs22"     // Change the runtime to Node.js
  entry_point = "beforeCreate" // Set the entry point to your function in Node.js

  # runtime               = "go122"
  # entry_point           = "IDPbeforeCreate" # Set the entry point
  source_archive_bucket = google_storage_bucket.bucket_gcf_source.name
  source_archive_object = google_storage_bucket_object.utrade_auth.name
  service_account_email = "utrade-taxi-run-0@appspot.gserviceaccount.com"
  # service_account_email = google_service_account.firebase_admin.email
  trigger_http = true

  environment_variables = {
    GCLOUD_PROJECT  = var.project_id
    FIREBASE_CONFIG = base64decode(google_secret_manager_secret_version.firebase_admin_v1.secret_data)
  }
}
output "auth_func_utrade_before_create_id" {
  value = google_cloudfunctions_function.utrade_auth_before_create.id
}

resource "google_cloudfunctions_function_iam_member" "auth_before_sign_in" {
  project        = google_cloudfunctions_function.utrade_auth_before_sign_in.project
  region         = google_cloudfunctions_function.utrade_auth_before_sign_in.region
  cloud_function = google_cloudfunctions_function.utrade_auth_before_sign_in.id
  role           = "roles/cloudfunctions.invoker"
  member         = "allUsers"
}
resource "google_cloudfunctions_function_iam_member" "auth_before_create" {
  project        = google_cloudfunctions_function.utrade_auth_before_create.project
  region         = google_cloudfunctions_function.utrade_auth_before_create.region
  cloud_function = google_cloudfunctions_function.utrade_auth_before_create.id
  role           = "roles/cloudfunctions.invoker"
  member         = "allUsers"
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

