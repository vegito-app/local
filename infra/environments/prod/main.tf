locals {
  environment = "prod"
}

data "google_project" "project" {
  project_id = var.project_id
}

module "cdn" {
  source      = "./cdn"
  environment = local.environment
  project_id  = data.google_project.project.project_id
  region      = var.region
}

locals {
  input_images_service_account_id = "input-images-workers"
  input_images_workers_email      = "${local.input_images_service_account_id}@${var.project_id}.iam.gserviceaccount.com"
}

module "kubernetes" {
  source         = "./kubernetes"
  region         = var.region
  project_id     = data.google_project.project.project_id
  project_number = data.google_project.project.number

  vault_tf_apply_member_sa_list = concat(
    local.production_admin_service_accounts,
    local.root_admin_service_accounts,
  )

  # The Pub/Sub topic where the vegetable images validation input data are sent for moderation
  vegetable_image_created_moderator_pubsub_topic_input       = google_pubsub_topic.vegetable_created.name
  vegetable_image_created_moderator_pull_pubsub_subscription = google_pubsub_subscription.vegetable_created_moderator_psubscription.name
  # The Pub/Sub topic where the vegetable images validation output data are sent after moderation
  vegetable_image_validated_moderator_pubsub_topic_output = google_pubsub_topic.vegetable_validated.name

  # The bucket where the images are stored before moderation
  created_images_input_bucket_name = module.application.created_images_input_bucket_name
  # The bucket where the images are stored after moderation
  validated_output_bucket = module.cdn.public_images_bucket_name


  input_images_moderator_image  = var.input_images_moderator_image
  input_images_cleaner_image    = var.input_images_cleaner_image
  input_images_workers_sa_email = local.input_images_workers_email
}

module "gcloud" {
  bucket_tf_state_eu_global_name = local.bucket_tf_state_eu_global_name
  cloud_storage_location         = var.cloud_storage_location
  environment                    = local.environment
  project_id                     = data.google_project.project.project_id
  region                         = var.region
  source                         = "../../gcloud"
}

output "project" {
  value = data.google_project.project.id
}


import {
  to = module.gcloud.google_storage_bucket.bucket_tf_state_eu_global
  id = "global-${var.region}-tf-state"
}

# Enables required APIs.
resource "google_project_service" "google_services_default" {
  provider = google-beta.no_user_project_override
  project  = data.google_project.project.project_id
  for_each = toset([
    "cloudbilling.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudkms.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "identitytoolkit.googleapis.com",
    "secretmanager.googleapis.com",
    "serviceusage.googleapis.com",
    "storage.googleapis.com",
    "vision.googleapis.com"
  ])
  service                    = each.key
  disable_on_destroy         = false
  disable_dependent_services = true
}

resource "google_project_iam_member" "application_backend_vault_access" {
  project = data.google_project.project.project_id
  role    = "roles/iam.workloadIdentityUser"
  member  = "serviceAccount:${module.application.application_backend_cloud_run_sa_email}"
}

module "application" {
  source                                                 = "../../../application/run"
  region                                                 = var.region
  environment                                            = local.environment
  project_name                                           = data.google_project.project.name
  project_id                                             = var.project_id
  application_backend_image                              = var.application_backend_image
  google_idp_oauth_key_secret_id                         = var.google_idp_oauth_key_secret_id
  google_idp_oauth_client_id_secret_id                   = var.google_idp_oauth_client_id_secret_id
  vegetable_images_validated_backend_pubsub_subscription = google_pubsub_subscription.vegetable_validated_backend_subscription.name
  vegetable_image_created_moderator_pubsub_topic         = google_pubsub_topic.vegetable_created.name
  cdn_images_url_prefix                                  = "http://${google_compute_global_address.public_cdn.address}/"
}

resource "google_pubsub_topic" "vegetable_created" {
  provider = google-beta.no_user_project_override
  project  = var.project_id
  name     = "vegetable-created"
}

resource "google_pubsub_subscription" "vegetable_created_moderator_psubscription" {
  provider = google-beta.no_user_project_override
  project  = var.project_id
  name     = "vegetable-created-subscription"
  topic    = google_pubsub_topic.vegetable_created.id

  ack_deadline_seconds       = 60
  message_retention_duration = "604800s" # 7 days
}

resource "google_pubsub_topic" "vegetable_validated" {
  provider = google-beta.no_user_project_override
  project  = var.project_id
  name     = "vegetable-validated"
}

resource "google_pubsub_subscription" "vegetable_validated_backend_subscription" {
  provider = google-beta.no_user_project_override
  project  = var.project_id
  name     = "vegetable-validated-subscription"
  topic    = google_pubsub_topic.vegetable_validated.id

  ack_deadline_seconds       = 60
  message_retention_duration = "604800s" # 7 days
}


resource "google_service_account" "input_images_workers" {
  account_id   = local.input_images_service_account_id
  project      = var.project_id
  display_name = "Input Images Workers Service Account"
  description  = "Service account for input images workers in GKE"
  depends_on = [
    module.kubernetes.google_project_service
  ]
}

resource "google_project_iam_member" "input_images_workers" {
  for_each = toset([
    "roles/iam.serviceAccountUser",
    "roles/iam.workloadIdentityUser"
  ])
  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.input_images_workers.email}"
}

resource "google_storage_bucket_iam_member" "output_validated_images_workers" {
  for_each = toset([
    "roles/storage.objectViewer",
    "roles/storage.objectAdmin"
  ])
  bucket = module.cdn.public_images_bucket_name
  role   = each.key
  member = "serviceAccount:${google_service_account.input_images_workers.email}"
}

resource "google_storage_bucket_iam_member" "input_created_images_workers" {
  for_each = toset([
    "roles/storage.objectViewer",
    "roles/storage.objectAdmin"
  ])
  bucket = module.application.created_images_input_bucket_name
  role   = each.key
  member = "serviceAccount:${google_service_account.input_images_workers.email}"
}

resource "google_service_account_iam_member" "bind_ksa_to_gsa" {
  service_account_id = google_service_account.input_images_workers.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[default/input-images-workers]"
}

resource "google_project_iam_member" "input_images_workers_vision" {
  project = var.project_id
  role    = "roles/visionai.reader"
  member  = "serviceAccount:${google_service_account.input_images_workers.email}"
}
