variable "google_credentials_file" {
  description = "Google Service Account JSON file"
  type        = string
}
variable "project_id" {
  description = "GCP project ID"
  type        = string
  default     = "moov-staging-440506"
}
variable "region" {
  description = "GCP used region"
  type        = string
  default     = "europe-west1"
}
variable "repository_id" {
  description = "docker repository image name: container-registry/<repository_id>:image-tag"
  type        = string
  default     = "docker-repository"
}
variable "public_repository_id" {
  description = "docker repository image name: container-registry/<repository_id>:public-<image-tag>"
  type        = string
  default     = "docker-repository-public"
}
variable "private_docker_repository_id" {
  type        = string
  description = "Private Docker repository name"
}
variable "application_backend_image" {
  description = "application Docker image"
  type        = string
}
variable "create_secret" {
  description = "Create secrets if true"
  type        = bool
  default     = false
}
variable "ui_firebase_secret_id" {
  description = "Firebase - UI config - secret ID"
  type        = string
  default     = "ui_firebase_config"
}
variable "ui_googlemaps_secret_id" {
  description = "GoogleMaps - UI API Key - secret ID"
  type        = string
  default     = "ui_googlemaps_secret"
}
