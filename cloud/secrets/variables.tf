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
