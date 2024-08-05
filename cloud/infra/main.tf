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
    "identitytoolkit.googleapis.com",
    "secretmanager.googleapis.com",
    "serviceusage.googleapis.com",
  ])
  service = each.key

  # Don't disable the service if the resource block is removed by accident.
  disable_on_destroy = false
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
          name  = "MY_VARIABLE"
          value = "my value"
        }
        env {
          name  = "ANOTHER_VARIABLE"
          value = "another value"
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
      function_uri = google_cloudfunctions_function.utrade_auth.https_trigger_url
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
      start_time     = "2024-8-31T21:00:00+02:00"
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
  source_dir  = "${path.module}/go/auth/"
}

resource "google_storage_bucket_object" "utrade_auth" {
  name   = "${var.project_name}-${var.region}-${var.application_image}-identity-platform-auth-function-source.zip"
  bucket = google_storage_bucket.bucket_gcf_source.name
  source = data.archive_file.utrade_auth_func_src.output_path # Add path to the zipped function source code
}

resource "google_cloudfunctions_function" "utrade_auth" {
  name        = "${var.project_name}-${var.region}-identity-platform"
  description = "OIDC callback"

  runtime               = "go122"
  entry_point           = "IdentityPaltformAuth" # Set the entry point
  source_archive_bucket = google_storage_bucket.bucket_gcf_source.name
  source_archive_object = google_storage_bucket_object.utrade_auth.name

  trigger_http = true
}
output "auth_func_id" {
  value = google_cloudfunctions_function.utrade_auth.id
}

resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.utrade_auth.project
  region         = google_cloudfunctions_function.utrade_auth.region
  cloud_function = google_cloudfunctions_function.utrade_auth.name
  role           = "roles/cloudfunctions.invoker"
  member         = "allUsers"
}

output "function_uri" {
  value = google_cloudfunctions_function.utrade_auth.https_trigger_url
}
