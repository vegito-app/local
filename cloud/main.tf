output "project" {
  value = var.project_id
}

module "infra" {
  source = "./infra"
  // Pass in variables if needed
  project_name      = var.project_name
  repository_id     = var.repository_id
  region            = var.region
  project_id        = var.project_id
  billing_account   = var.billing_account
  application_image = var.application_image
}

module "secrets" {
  source = "./secrets"
  // Pass in variables if needed
  google_cloud_idp_google_web_auth_secret = var.google_cloud_idp_google_web_auth_secret
  create_secret                           = var.create_secret
}

# Creates a new Google Cloud project.
resource "google_project" "utrade" {
  # provider = google-beta.no_user_project_override

  name       = var.project_name
  project_id = var.project_id
  # Required for any service that requires the Blaze pricing plan
  # (like Firebase Authentication with GCIP)
  billing_account = var.billing_account

  # Required for the project to display in any list of Firebase projects.
  labels = {
    "firebase" = "enabled"
  }
}


resource "google_storage_bucket" "bucket_tf_state" {
  name     = "${var.project_name}-${var.region}-tf-state-prod"
  location = var.region

  storage_class = "STANDARD"

  force_destroy = false # Do not remove bucket if remaining tf_state

  uniform_bucket_level_access = true # Needed to use with tf tf_lock

  versioning {
    enabled = true
  }
}

output "tf_state_bucket_url" {
  description = "Terraform state GCS bucket URL."
  value       = google_storage_bucket.bucket_tf_state.url
}

output "gcp_creds_client_email" {
  description = "Project docker container Registry."
  value       = jsondecode(file("./google-cloud-credentials"))["client_email"]
}
