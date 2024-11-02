# Enables required APIs.
resource "google_project_service" "google_idp_services" {
  project = data.google_project.project.project_id
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
resource "google_identity_platform_config" "moov" {

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
  source_dir  = "${path.module}/auth/"
}

resource "google_storage_bucket_object" "auth" {
  name   = "${data.google_project.project.project_id}-${var.region}-identity-platform-auth-function-source.zip"
  bucket = google_storage_bucket.bucket_gcf_source.name
  source = data.archive_file.auth_func_src.output_path # Add path to the zipped function source code
}

resource "google_cloudfunctions_function" "auth_before_sign_in" {
  name                  = "${data.google_project.project.project_id}-${var.region}-identity-platform-before-signin"
  description           = "OIDC callback before sign in"
  runtime               = "go122"
  entry_point           = "IDPbeforeSignIn" # Set the entry point
  source_archive_bucket = google_storage_bucket.bucket_gcf_source.name
  source_archive_object = google_storage_bucket_object.auth.name
  service_account_email = google_service_account.firebase_admin_service_account.email
  trigger_http          = true

  # environment_variables = {
  # FIREBASE_ADMINSDK_SERVICEACCOUNT_ID = google_service_account.firebase_admin_service_account.id
  # }
}

output "auth_func_utrade_before_sign_in_id" {
  value = google_cloudfunctions_function.auth_before_sign_in.id
}

resource "google_cloudfunctions_function" "auth_before_create" {
  name        = "${data.google_project.project.project_id}-${var.region}-identity-platform-before-create"
  description = "OIDC callback create user"
  runtime     = "nodejs22"     // Change the runtime to Node.js
  entry_point = "beforeCreate" // Set the entry point to your function in Node.js

  # runtime               = "go122"
  # entry_point           = "IDPbeforeCreate" # Set the entry point
  source_archive_bucket = google_storage_bucket.bucket_gcf_source.name
  source_archive_object = google_storage_bucket_object.auth.name
  service_account_email = google_service_account.firebase_admin_service_account.email
  trigger_http          = true

  # environment_variables = {
  # GCLOUD_PROJECT  = data.google_project.project.project_id
  # FIREBASE_CONFIG = base64decode(google_secret_manager_secret_version.firebase_adminsdk_secret_version.secret_data)
  # }
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
