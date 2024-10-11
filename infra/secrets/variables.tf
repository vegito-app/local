variable "google_credentials_file" {
  description = "Google Service Account JSON file"
  type        = string
}
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