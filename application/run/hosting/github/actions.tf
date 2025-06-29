resource "google_storage_bucket" "ci_artifacts" {
  name          = "vegito-ci-artifacts-${var.project_id}"
  location      = "EU"
  storage_class = "STANDARD"
  force_destroy = true

  uniform_bucket_level_access = true

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 30
    }
  }
}

resource "google_storage_bucket_iam_member" "github_actions_ci_artifacts_writer" {
  bucket = google_storage_bucket.ci_artifacts.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.github_actions.email}"
}
