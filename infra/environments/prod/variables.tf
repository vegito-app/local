variable "project_id" {
  description = "GCP project ID"
  type        = string
  default     = "moov-438615"
}
variable "region" {
  description = "GCP used region"
  type        = string
  default     = "europe-west1"
}
variable "cloud_storage_location" {
  description = "The Google Cloud Storage location"
  type        = string
  default     = "EU"
}
variable "application_backend_image" {
  description = "application Docker image"
  type        = string
}
variable "application_public_domain" {
  description = "application Docker image"
  type        = string
  default     = "https://moov-438615-europe-west1-application-backend-v4bqtohg4a-ew.a.run.app"
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
variable "google_idp_oauth_key_secret_id" {
  description = "google.com IDP oauth key cloud secret"
  type        = string
}
variable "google_idp_oauth_client_id_secret_id" {
  description = "google.com IDP oauth client ID cloud secret"
  type        = string
}
