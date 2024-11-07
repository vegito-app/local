variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}
variable "project_name" {
  description = "GCP project Name"
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
variable "application_backend_image" {
  description = "application Docker image"
  type        = string
}
variable "application_public_domain" {
  description = "application public domain"
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
