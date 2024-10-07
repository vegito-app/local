
# Dépôt public (accessible en lecture seule pour tout le monde)
resource "google_artifact_registry_repository" "public_repo" {
  location      = var.region
  repository_id = var.public_repository_id
  description   = "Public Docker repository"
  format        = "DOCKER"
}

resource "google_artifact_registry_repository_iam_member" "github_actions_public_repo_write_member" {
  provider   = google
  project    = var.project_id
  location   = var.region
  repository = google_artifact_registry_repository.public_repo.name
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${google_service_account.github_actions.email}"
}

resource "google_artifact_registry_repository_iam_member" "public_read" {
  location   = google_artifact_registry_repository.public_repo.location
  repository = google_artifact_registry_repository.public_repo.repository_id
  role       = "roles/artifactregistry.reader"
  member     = "allUsers"
}

resource "null_resource" "docker_auth" {
  depends_on = [google_artifact_registry_repository.utrade]

  provisioner "local-exec" {
    command = "gcloud auth configure-docker ${var.region}-docker.pkg.dev/${var.project_id}/${var.public_repository_id}"
  }
}

output "docker_repository_public" {
  description = "Project public docker container registry."
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${var.public_repository_id}"
}

resource "google_artifact_registry_repository" "utrade" {
  provider      = google
  location      = var.region
  repository_id = var.repository_id
  description   = "utrade main docker repository"
  format        = "DOCKER"
}

resource "null_resource" "docker_auth_public" {
  depends_on = [google_artifact_registry_repository.utrade]

  provisioner "local-exec" {
    command = "gcloud auth configure-docker ${var.region}-docker.pkg.dev/${var.project_id}/${var.repository_id}"
  }
}

output "docker_repository" {
  description = "Project docker container registry."
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${var.repository_id}"
}

resource "google_artifact_registry_repository_iam_member" "github_actions_private_repo_write_member" {
  provider   = google
  project    = var.project_id
  location   = var.region
  repository = google_artifact_registry_repository.utrade.id
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${google_service_account.github_actions.email}"
}

resource "google_artifact_registry_repository_iam_member" "github_actions_private_repo_read_member" {
  provider   = google
  project    = var.project_id
  location   = var.region
  repository = google_artifact_registry_repository.utrade.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.github_actions.email}"
}
