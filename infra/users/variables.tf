variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "users_email" {
  type = map(string)
}

variable "environment" {
  type = string
}
