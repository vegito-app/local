
variable "public_docker_repository_id" {
  type        = string
  description = "Public public Docker repository name"
}
# Dépôt public (accessible en lecture seule pour tout le monde)
resource "google_artifact_registry_repository" "public_docker_repository" {
  location      = var.region
  repository_id = var.public_docker_repository_id
  description   = "Public Docker repository"
  format        = "DOCKER"
}

output "public_docker_repository" {
  description = "Project docker container registry."
  value       = "${var.region}-docker.pkg.dev/${data.google_project.project.project_id}/${google_artifact_registry_repository.public_docker_repository.repository_id}"
}

resource "google_artifact_registry_repository_iam_member" "public_read" {
  location   = google_artifact_registry_repository.public_docker_repository.location
  repository = google_artifact_registry_repository.public_docker_repository.repository_id
  role       = "roles/artifactregistry.reader"
  member     = "allUsers"
}

resource "null_resource" "docker_auth" {
  depends_on = [google_artifact_registry_repository.public_docker_repository]

  provisioner "local-exec" {
    command = "gcloud auth configure-docker ${var.region}-docker.pkg.dev/${data.google_project.project.project_id}/${var.public_docker_repository_id}"
  }
}

variable "private_docker_repository_id" {
  type        = string
  description = "Private Docker repository name"
}

resource "google_artifact_registry_repository" "private_docker_repository" {
  provider      = google
  location      = var.region
  repository_id = var.private_docker_repository_id
  description   = "private_docker_repository main private docker repository"
  format        = "DOCKER"
}

resource "null_resource" "docker_auth_public" {
  depends_on = [google_artifact_registry_repository.private_docker_repository]

  provisioner "local-exec" {
    command = "gcloud auth configure-docker ${var.region}-docker.pkg.dev/${data.google_project.project.project_id}/${var.private_docker_repository_id}"
  }
}

output "docker_repository" {
  description = "Project docker container registry."
  value       = "${var.region}-docker.pkg.dev/${data.google_project.project.project_id}/${google_artifact_registry_repository.private_docker_repository.repository_id}"
}
