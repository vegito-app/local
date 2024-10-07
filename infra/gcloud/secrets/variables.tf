variable "create_secret" {
  description = "Create secrets if true"
  type        = bool
  default     = false
}
variable "project_id" {
  description = "GCP project ID"
  type        = string
}
variable "project_name" {
  description = "Name of the GCP project"
  type        = string
}
variable "region" {
  description = "GCP used region"
  type        = string
}
# Firebase options
variable "FIREBASE_API_KEY" {}
variable "FIREBASE_AUTH_DOMAIN" {}
variable "FIREBASE_DATABASE_URL" {}
variable "FIREBASE_PROJECT_ID" {}
variable "FIREBASE_STORAGE_BUCKET" {}
variable "FIREBASE_MESSAGING_SENDER_ID" {}
variable "FIREBASE_APP_ID" {}
# 
variable "ui_firebase_secret_id" {
  description = "Firebase - UI config - secret ID"
  type        = string
}
variable "ui_googlemaps_secret_id" {
  description = "GoogleMaps - UI API Key - secret ID"
  type        = string
}
variable "web_backend_server_url" {
  description = "Web Backend Server"
  type        = string
}
variable "google_firebase_apple_ios_app_bundle_id" {
  description = "Firebase application iOS BundleID Backend Server"
  type        = string
}
variable "google_firebase_android_app_sha1_fingerprint" {
  description = "Firebase application Android SHA1 fingerprint"
  type        = string
}
variable "google_firebase_android_app_package_name" {
  description = "Firebase application Android package name"
  type        = string
}
