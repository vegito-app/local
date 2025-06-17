locals {
  environment = "staging"
}

module "application" {
  source       = "../../../application/run"
  environment  = local.environment
  project_name = data.google_project.project.name
  project_id   = var.project_id
  region       = var.region

  google_idp_oauth_client_id_secret_id = var.google_idp_oauth_client_id_secret_id
  google_idp_oauth_key_secret_id       = var.google_idp_oauth_key_secret_id

  application_backend_image = var.application_backend_image

  vegetable_image_created_moderator_pubsub_topic         = google_pubsub_topic.vegetable_moderation_bypass.name
  vegetable_images_validated_backend_pubsub_subscription = google_pubsub_subscription.vegetable_moderation_bypass_moderator_pull_subscription.name

  cdn_images_url_prefix = "https://firebasestorage.googleapis.com/v0/b/moov-staging-440506-firebase-storage/o"
  hosting_domain        = "staging.vegito.app"
}

module "gcloud" {
  source      = "../../gcloud"
  environment = local.environment
  project_id  = var.project_id
  region      = var.region

  bucket_tf_state_eu_global_name = "global-${var.region}-tf-state-staging"
  cloud_storage_location         = var.cloud_storage_location
}

data "google_project" "project" {
  project_id = var.project_id
}

# Enables required APIs.
resource "google_project_service" "google_services_default" {
  provider = google-beta.no_user_project_override
  project  = var.project_id
  for_each = toset([
    "cloudbilling.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "secretmanager.googleapis.com",
    "serviceusage.googleapis.com",
  ])
  service = each.key

  # Don't disable the service if the resource block is removed by accident.
  disable_on_destroy         = false
  disable_dependent_services = true
}

output "application_firebase_storage_bucket" {
  value       = google_storage_bucket.firebase_storage_bucket.name
  description = "Firebase Storage Bucket Name"
}

resource "google_storage_bucket" "firebase_storage_bucket" {
  name                        = "${var.project_id}-firebase-storage"
  provider                    = google-beta
  location                    = var.region
  project                     = var.project_id
  uniform_bucket_level_access = true
  force_destroy               = true # à retirer en prod, pour éviter des suppressions accidentelles

  lifecycle {
    prevent_destroy = false
  }
}

resource "google_pubsub_topic" "vegetable_moderation_bypass" {
  provider = google-beta.no_user_project_override
  project  = var.project_id
  name     = "vegetable-moderation-bypass"
}

resource "google_pubsub_subscription" "vegetable_moderation_bypass_moderator_pull_subscription" {
  provider = google-beta.no_user_project_override
  project  = var.project_id
  name     = "vegetable-validated-subscription"
  topic    = google_pubsub_topic.vegetable_moderation_bypass.id

  ack_deadline_seconds       = 60
  message_retention_duration = "604800s" # 7 days
}
