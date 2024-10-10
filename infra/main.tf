output "project" {
  value = var.project_id
}

module "infra" {
  source = "./gcloud"

  application_backend_image = var.application_backend_image
  billing_account           = var.billing_account
  project_id                = var.project_id
  region                    = var.region
  repository_id             = var.repository_id
  public_repository_id      = var.public_repository_id
  ui_firebase_secret_id     = var.ui_firebase_secret_id
  ui_googlemaps_secret_id   = var.ui_googlemaps_secret_id

  GOOGLE_CLOUD_WEB_IDP_GOOGLE_OAUTH_SECRET = var.GOOGLE_CLOUD_WEB_IDP_GOOGLE_OAUTH_SECRET
  create_secret                            = var.create_secret
}

# Creates a new Google Cloud project.
resource "google_project" "utrade" {

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


resource "google_storage_bucket" "bucket_tf_state_eu" {

  name     = "${var.project_name}-europe-west1-tf-state"
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
  value       = jsondecode(file("./gcloud-credentials"))["client_email"]
}
