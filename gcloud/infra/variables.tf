variable "billing_account" {
  description = "ACCOUNT_ID of used billing account"
  type        = string
}
variable "project_name" {
  description = "Name of the GCP project"
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
variable "repository_id" {
  description = "docker repository image name: container-registry/<repository_id>:<image-tag>"
  type        = string
}
variable "public_repository_id" {
  description = "docker repository image name: container-registry/<repository_id>:public-<image-tag>"
  type        = string
}
variable "application_image" {
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
