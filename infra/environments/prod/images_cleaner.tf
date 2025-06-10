
resource "google_service_account" "input_images_cleaner" {
  account_id   = local.input_images_cleaner_service_account_id
  display_name = "Input Images Cleaner Service Account"
  description  = "Service account for input images cleaner in GKE"
  project      = var.project_id
  depends_on = [
    module.kubernetes.google_project_service
  ]
}

resource "google_project_iam_member" "input_images_cleaner" {
  for_each = toset([
    "roles/iam.serviceAccountUser",
    "roles/iam.workloadIdentityUser"
  ])
  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.input_images_cleaner.email}"
}

resource "google_storage_bucket_iam_member" "input_created_images_cleaner" {
  for_each = toset([
    "roles/storage.objectViewer",
    "roles/storage.objectAdmin"
  ])
  bucket = module.application.created_images_input_bucket_name
  role   = each.key
  member = "serviceAccount:${google_service_account.input_images_cleaner.email}"
}

resource "google_service_account_iam_member" "bind_input_images_cleaner_ksa_to_gsa" {
  service_account_id = google_service_account.input_images_cleaner.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[default/input-images-cleaner]"
}

resource "google_service_account_iam_member" "input_images_cleaner_token_creator" {
  service_account_id = google_service_account.input_images_cleaner.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${google_service_account.input_images_cleaner.email}"
}
