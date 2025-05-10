# Enables required APIs.
resource "google_project_service" "google_idp_services" {
  project = var.project_id
  for_each = toset([
    "identitytoolkit.googleapis.com",
  ])
  service = each.key

  # Don't disable the service if the resource block is removed by accident.
  disable_on_destroy         = false
  disable_dependent_services = true
}

# Creates an Identity Platform config.
# Also enables Firebase Authentication with Identity Platform in the project if not.
resource "google_identity_platform_config" "default" {
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
        "EU",
        "US",
        "CA"
      ]
    }
  }
  blocking_functions {
    triggers {
      event_type   = "beforeSignIn"
      function_uri = google_cloudfunctions_function.auth_before_sign_in.https_trigger_url
    }
    triggers {
      event_type   = "beforeCreate"
      function_uri = google_cloudfunctions_function.auth_before_create.https_trigger_url
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
  authorized_domains = local.allowed_referrers
  # Wait for identitytoolkit.googleapis.com to be enabled before initializing Authentication.
  depends_on = [
    google_project_service.google_idp_services,
  ]
}

data "archive_file" "auth_func_src" {
  type        = "zip"
  output_path = "/tmp/auth-function-source.zip"
  source_dir  = "${path.module}/../../application/firebase/functions/auth/"
}

resource "google_storage_bucket_object" "auth" {
  name   = "${var.project_name}-${var.region}-idp-auth-function-source.zip"
  bucket = google_storage_bucket.bucket_gcf_source.name
  source = data.archive_file.auth_func_src.output_path # Add path to the zipped function source code
}

resource "google_cloudfunctions_function" "auth_before_sign_in" {
  name         = "${var.project_name}-${var.region}-idp-before-signin"
  description  = "OIDC callback before sign in"
  runtime      = "go122"
  entry_point  = "IDPbeforeSignIn" # Set the entry point
  trigger_http = true

  source_archive_bucket = google_storage_bucket.bucket_gcf_source.name
  source_archive_object = google_storage_bucket_object.auth.name
  service_account_email = google_service_account.firebase_admin_service_account.email
}

output "auth_func_utrade_before_sign_in_id" {
  value = google_cloudfunctions_function.auth_before_sign_in.id
}

resource "google_cloudfunctions_function" "auth_before_create" {
  name         = "${var.project_name}-${var.region}-idp-before-create"
  description  = "OIDC callback create user"
  runtime      = "nodejs22"     // Change the runtime to Node.js
  entry_point  = "beforeCreate" // Set the entry point to your function in Node.js
  trigger_http = true

  source_archive_bucket = google_storage_bucket.bucket_gcf_source.name
  source_archive_object = google_storage_bucket_object.auth.name
  service_account_email = google_service_account.firebase_admin_service_account.email
}

output "auth_func_utrade_before_create_id" {
  value = google_cloudfunctions_function.auth_before_create.id
}

resource "google_cloudfunctions_function_iam_member" "auth_before_sign_in" {
  cloud_function = google_cloudfunctions_function.auth_before_sign_in.id
  role           = "roles/cloudfunctions.invoker"
  member         = "allUsers"
}

resource "google_cloudfunctions_function_iam_member" "auth_before_create" {
  cloud_function = google_cloudfunctions_function.auth_before_create.id
  role           = "roles/cloudfunctions.invoker"
  member         = "allUsers"
}
data "google_project" "project" {
  project_id = var.project_id
}
resource "google_storage_bucket_iam_member" "bucket_iam_member" {
  bucket = "gcf-sources-${data.google_project.project.number}-europe-west1"
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
}

data "google_secret_manager_secret_version" "google_idp_oauth_client_secret" {
  secret = var.google_idp_oauth_key_secret_id
}

data "google_secret_manager_secret_version" "google_idp_oauth_client_id" {
  secret = var.google_idp_oauth_client_id_secret_id
}

# Assigner les secrets
resource "google_identity_platform_default_supported_idp_config" "google" {
  enabled = true
  idp_id  = "google.com"

  client_id     = data.google_secret_manager_secret_version.google_idp_oauth_client_id.secret_data
  client_secret = data.google_secret_manager_secret_version.google_idp_oauth_client_secret.secret_data
}
