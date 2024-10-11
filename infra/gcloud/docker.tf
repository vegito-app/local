
# Dépôt public (accessible en lecture seule pour tout le monde)
resource "google_artifact_registry_repository" "public_docker_repository" {
  location      = var.region
  repository_id = "${var.environment}-${var.public_repository_id}"
  description   = "Public Docker repository"
  format        = "DOCKER"
}

output "public_docker_repository" {
  description = "Project docker container registry."
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.public_docker_repository.repository_id}"
}

resource "google_artifact_registry_repository_iam_member" "github_actions_public_repo_write_member" {
  provider   = google
  project    = var.project_id
  location   = var.region
  repository = google_artifact_registry_repository.public_docker_repository.name
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${google_service_account.github_actions.email}"
}

resource "google_artifact_registry_repository_iam_member" "public_read" {
  location   = google_artifact_registry_repository.public_docker_repository.location
  repository = google_artifact_registry_repository.public_docker_repository.repository_id
  role       = "roles/artifactregistry.reader"
  member     = "allUsers"
}

# resource "null_resource" "docker_auth" {
#   depends_on = [google_artifact_registry_repository.moov]

#   provisioner "local-exec" {
#     command = "gcloud auth configure-docker ${var.region}-docker.pkg.dev/${var.project_id}/${var.public_repository_id}"
#   }
# }

resource "google_artifact_registry_repository" "private_docker_repository" {
  provider      = google
  location      = var.region
  repository_id = "${var.environment}-${var.repository_id}"
  description   = "private_docker_repository main private docker repository"
  format        = "DOCKER"
}

# resource "null_resource" "docker_auth_public" {
#   depends_on = [google_artifact_registry_repository.private_docker_repository]

#   provisioner "local-exec" {
#     command = "gcloud auth configure-docker ${var.region}-docker.pkg.dev/${var.project_id}/${var.repository_id}"
#   }
# }

output "docker_repository" {
  description = "Project docker container registry."
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.private_docker_repository.repository_id}"
}

resource "google_artifact_registry_repository_iam_member" "github_actions_private_repo_write_member" {
  provider   = google
  project    = var.project_id
  location   = var.region
  repository = google_artifact_registry_repository.private_docker_repository.id
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${google_service_account.github_actions.email}"
}

resource "google_artifact_registry_repository_iam_member" "github_actions_private_repo_read_member" {
  provider   = google
  project    = var.project_id
  location   = var.region
  repository = google_artifact_registry_repository.private_docker_repository.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.github_actions.email}"
}
