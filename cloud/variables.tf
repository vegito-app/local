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
  description = "docker repository image name: container-registry/<repository_id>:image-tag"
  type        = string
}
variable "application_image" {
  description = "application Docker image"
  type        = string
}
variable "google_idp_auth_secret" {
  description = "Create secrets if true"
  type        = bool
  default     = false
}
variable "create_secret" {
  description = "Create secrets if true"
  type        = bool
  default     = false
}
variable "google_cloud_idp_google_web_auth_secret" {
  description = "google.com IDP oauth secret for web application"
  type        = string
  default     = false
}
