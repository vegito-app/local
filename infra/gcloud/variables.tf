variable "environment" {
  description = "Environment name (dev, staging, prod)"
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
variable "application_backend_domain" {
  description = "The public domain of the application"
  type        = string
}
variable "bucket_tf_state_eu_global_name" {
  description = "Name of the GCS bucket for Terraform state"
  type        = string
}
