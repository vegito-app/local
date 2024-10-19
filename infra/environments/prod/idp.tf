data "google_secret_manager_secret_version" "google_idp_oauth_client_secret" {
  secret = var.google_idp_oauth_key_secret_id
}

data "google_secret_manager_secret_version" "google_idp_oauth_client_id" {
  secret = var.google_idp_oauth_client_id_secret_id
}

# Assigner les secrets
resource "google_identity_platform_default_supported_idp_config" "google" {
  enabled = true
  idp_id  = "google.com"

  client_id     = data.google_secret_manager_secret_version.google_idp_oauth_client_id.secret_data
  client_secret = data.google_secret_manager_secret_version.google_idp_oauth_client_secret.secret_data
}
