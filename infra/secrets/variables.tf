variable "project_id" {
  description = "GCP project ID"
  type        = string
}
variable "region" {
  description = "GCP used region"
  type        = string
}
variable "prod_google_idp_oauth_client_id" {
  description = "google.com IDP oauth client ID"
  type        = string
}
variable "google_idp_oauth_client_id_secret_id" {
  description = "google.com IDP oauth client ID cloud secret"
  type        = string
}
variable "prod_google_idp_oauth_key" {
  description = "google.com IDP oauth key"
  type        = string
}
variable "google_idp_oauth_key_secret_id" {
  description = "google.com IDP oauth key cloud secret"
  type        = string
}
