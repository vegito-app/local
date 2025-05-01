resource "google_service_account" "github_actions" {
  account_id   = "github-actions-main"
  display_name = "Github Actions"
  project      = var.project_id
}

resource "google_service_account_key" "github_actions_key" {
  service_account_id = google_service_account.github_actions.account_id
  private_key_type   = "TYPE_GOOGLE_CREDENTIALS_FILE"
}

output "github_actions_private_key" {
  value     = google_service_account_key.github_actions_key.private_key
  sensitive = true
}

resource "google_artifact_registry_repository_iam_member" "github_actions_public_repo_write_member" {
  provider   = google
  project    = var.project_id
  location   = var.region
  repository = google_artifact_registry_repository.public_docker_repository.name
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${google_service_account.github_actions.email}"
}

resource "google_project_iam_member" "github_action_project_editor" {
  role    = "roles/editor"
  project = var.project_id
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

resource "google_project_iam_member" "github_action_project_secret_admin" {
  role    = "roles/secretmanager.admin"
  project = var.project_id
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

resource "google_project_iam_member" "github_action_project_storage_admin" {
  role    = "roles/storage.admin"
  project = var.project_id
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

resource "google_storage_bucket_iam_member" "github_actions_public_strorage_object_user" {
  bucket = google_storage_bucket.bucket_tf_state_eu_global.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.github_actions.email}"
}

resource "google_storage_bucket_iam_member" "github_actions_global_tf_state_strorage_admin" {
  bucket = google_storage_bucket.bucket_tf_state_eu_global.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.github_actions.email}"
}

resource "google_artifact_registry_repository_iam_member" "github_actions_private_repo_write_member" {
  project    = var.project_id
  location   = var.region
  repository = google_artifact_registry_repository.private_docker_repository.id
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${google_service_account.github_actions.email}"
}

resource "google_artifact_registry_repository_iam_member" "github_actions_private_repo_read_member" {
  project    = var.project_id
  location   = var.region
  repository = google_artifact_registry_repository.private_docker_repository.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.github_actions.email}"
}
