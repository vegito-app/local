variable "domain" {
  type        = string
  description = "Nom de domaine pour Firebase Hosting"
}

variable "legal_sites" {
  type = map(map(string))
}
variable "project_id" {}
variable "site_id" {}
variable "public_dir" {}

variable "project_name" {
  description = "GCP project Name"
  type        = string
}
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}
