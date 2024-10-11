variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}
variable "project_id" {
  description = "ID of the GCP project"
  type        = string
}
variable "region" {
  description = "GCP used region"
  type        = string
}
