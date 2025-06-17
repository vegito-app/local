resource "google_secret_manager_secret" "facebook_oauth_client_id" {
  secret_id = "facebook_oauth_client_id"
  replication {
    auto {

    }
  }
}

resource "google_secret_manager_secret" "facebook_oauth_client_secret" {
  secret_id = "facebook_oauth_client_secret"
  replication {
    auto {

    }
  }
}

data "google_secret_manager_secret_version" "facebook_oauth_client_id" {
  secret = google_secret_manager_secret.facebook_oauth_client_id.secret_id
}

data "google_secret_manager_secret_version" "facebook_oauth_client_secret" {
  secret = google_secret_manager_secret.facebook_oauth_client_secret.secret_id
}

resource "google_identity_platform_default_supported_idp_config" "facebook" {
  project = var.project_id
  enabled = true
  idp_id  = "facebook.com"

  client_id     = data.google_secret_manager_secret_version.facebook_oauth_client_id.secret_data
  client_secret = data.google_secret_manager_secret_version.facebook_oauth_client_secret.secret_data
}
