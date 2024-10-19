variable "idp_google_secret_id" {
  description = "google.com IDP oauth cloud secret ID"
  type        = string
  default     = "idp_google_secret_id"
}

resource "google_secret_manager_secret" "google_idp_secret" {
  secret_id = var.idp_google_secret_id

  replication {
    auto {

    }
  }
}

variable "GOOGLE_IDP_OAUTH_SECRET" {
  description = "google.com IDP oauth secret"
  type        = string
}

resource "google_secret_manager_secret_version" "google_idp_secret_version" {
  secret      = google_secret_manager_secret.google_idp_secret.id
  secret_data = var.GOOGLE_IDP_OAUTH_SECRET
}

resource "google_identity_platform_default_supported_idp_config" "google" {
  enabled       = true
  idp_id        = "google.com"
  client_id     = "$(GOOGLE_CLOUD_PROJECT_NUMBER)-lu67bhh9fe2hsdfk2ci3r5j6js7acsvn.apps.googleusercontent.com"
  client_secret = google_secret_manager_secret_version.google_idp_secret_version.secret_data
}
