variable "project_id" {
  description = "GCP - project ID"
  type        = string
}
variable "project_name" {
  description = "GCP project Name"
  type        = string
}
variable "region" {
  description = "GCP used region"
  type        = string
}
variable "application_backend_image" {
  description = "application Docker image"
  type        = string
}
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}
variable "google_idp_oauth_key_secret_id" {
  description = "google.com IDP oauth key cloud secret"
  type        = string
}
variable "google_idp_oauth_client_id_secret_id" {
  description = "google.com IDP oauth client ID cloud secret"
  type        = string
}
variable "cloud_storage_location" {
  description = "The Google Cloud Storage location"
  type        = string
  default     = "EU"
}
