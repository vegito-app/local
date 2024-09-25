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
# Googlemaps API key
variable "GOOGLE_MAPS_API_KEY" {}
# Firebase options
variable "FIREBASE_API_KEY" {}
variable "FIREBASE_AUTH_DOMAIN" {}
variable "FIREBASE_DATABASE_URL" {}
variable "FIREBASE_PROJECT_ID" {}
variable "FIREBASE_STORAGE_BUCKET" {}
variable "FIREBASE_MESSAGING_SENDER_ID" {}
variable "FIREBASE_APP_ID" {}
# 
# variable "ui_firebase_secret_id" {
#   description = "Firebase - UI config - secret ID"
#   type        = string
# }
# variable "ui_googlemaps_secret_id" {
#   description = "GoogleMaps - UI API Key - secret ID"
#   type        = string
# }

variable "GOOGLE_CLOUD_WEB_IDP_GOOGLE_OAUTH_SECRET" {
  description = "google.com IDP oauth secret for web application"
  type        = string
}
