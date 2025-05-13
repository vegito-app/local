variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "user_service_accounts" {
  description = "IAM serviceAccount list of environement (prod/staging/dev) users"
  type        = list(string)
}

variable "roles" {
  description = "Roles to set for the users group"
  type        = list(string)
}
