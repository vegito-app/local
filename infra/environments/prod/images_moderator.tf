
resource "google_service_account" "input_images_moderator" {
  account_id   = local.input_images_moderator_service_account_id
  display_name = "Input Images Moderator Service Account"
  description  = "Service account for input images moderator in GKE"
  project      = var.project_id
  depends_on = [
    module.kubernetes.google_project_service
  ]
}

resource "google_project_iam_member" "input_images_moderator" {
  for_each = toset([
    "roles/iam.serviceAccountUser",
    "roles/iam.workloadIdentityUser"
  ])
  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.input_images_moderator.email}"
}

resource "google_storage_bucket_iam_member" "output_validated_images_workers" {
  for_each = toset([
    "roles/storage.objectViewer",
    "roles/storage.objectAdmin"
  ])
  bucket = module.cdn.public_images_bucket_name
  role   = each.key
  member = "serviceAccount:${google_service_account.input_images_moderator.email}"
}

resource "google_storage_bucket_iam_member" "input_created_images_moderator" {
  for_each = toset([
    "roles/storage.objectViewer",
    "roles/storage.objectAdmin"
  ])
  bucket = google_storage_bucket.firebase_storage_bucket.name
  role   = each.key
  member = "serviceAccount:${google_service_account.input_images_moderator.email}"
}

resource "google_service_account_iam_member" "bind_input_images_moderator_ksa_to_gsa" {
  service_account_id = google_service_account.input_images_moderator.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[default/input-images-moderator]"
}

resource "google_project_iam_member" "input_images_moderator_vision" {
  project = var.project_id
  role    = "roles/visionai.annotationEditor"
  member  = "serviceAccount:${google_service_account.input_images_moderator.email}"
}

resource "google_pubsub_topic_iam_member" "input_images_moderator_subscriber" {
  topic  = google_pubsub_topic.vegetable_created.name
  role   = "roles/pubsub.subscriber"
  member = "serviceAccount:${google_service_account.input_images_moderator.email}"
}

resource "google_pubsub_topic_iam_member" "input_images_moderator_publisher" {
  topic  = google_pubsub_topic.vegetable_validated.name
  role   = "roles/pubsub.publisher"
  member = "serviceAccount:${google_service_account.input_images_moderator.email}"
}

resource "google_pubsub_subscription_iam_member" "input_images_moderator_subscription_subscriber" {
  subscription = google_pubsub_subscription.vegetable_created_moderator_psubscription.name
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:${google_service_account.input_images_moderator.email}"
}

resource "google_service_account_iam_member" "input_images_moderator_token_creator" {
  service_account_id = google_service_account.input_images_moderator.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${google_service_account.input_images_moderator.email}"
}
