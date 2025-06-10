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
variable "vegetable_image_created_moderator_pubsub_topic" {
  description = "Vegetable image created Pub/Sub topic for sending images to the moderator for validation"
  type        = string
}
variable "vegetable_images_validated_backend_pubsub_subscription" {
  description = "Vegetable image validated Pub/Sub subscription for receiving messages from the moderator"
  type        = string
}
variable "cdn_images_url_prefix" {
  description = "CDN images URL prefix for filtering messages to validate from the backend"
  type        = string
}
variable "cdn_images_bucket" {
  description = "The name of the bucket where validated images will be stored."
  type        = string
}
