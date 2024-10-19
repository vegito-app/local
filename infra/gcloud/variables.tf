variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}
variable "project_id" {
  description = "GCP project ID"
  type        = string
}
variable "region" {
  description = "GCP used region"
  type        = string
}
variable "cloud_storage_location" {
  description = "The Google Cloud Storage location"
  type        = string
}
variable "repository_id" {
  description = "docker repository image name: container-registry/<repository_id>:<image-tag>"
  type        = string
}
variable "public_repository_id" {
  description = "docker repository image name: container-registry/<repository_id>:public-<image-tag>"
  type        = string
}
variable "application_backend_image" {
  description = "application Docker image"
  type        = string
}
variable "ui_firebase_secret_id" {
  description = "Firebase - UI config - secret ID"
  type        = string
}
variable "ui_googlemaps_secret_id" {
  description = "GoogleMaps - UI API Key - secret ID"
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
