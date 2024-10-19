variable "google_credentials_file" {
  description = "Google Service Account JSON file"
  type        = string
}
variable "billing_account" {
  description = "ACCOUNT_ID of used billing account"
  type        = string
}
variable "project_name" {
  description = "Name of the GCP project"
  type        = string
  default     = "utrade"
}
variable "project_id" {
  description = "GCP project ID"
  type        = string
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
  default     = "prod-docker-repository-public"
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

variable "GOOGLE_IDP_OAUTH_SECRET" {
  description = "google.com IDP oauth secret for web application"
  type        = string
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
