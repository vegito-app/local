resource "google_secret_manager_secret" "google_idp_oauth_key" {
  secret_id = "prod-google-idp-oauth-key"

  replication {
    auto {

    }
  }
}

resource "google_secret_manager_secret_version" "google_idp_oauth_client_id_version" {
  secret      = google_secret_manager_secret.google_idp_oauth_client_id.id
  secret_data = var.prod_google_idp_oauth_client_id
}

resource "google_secret_manager_secret" "google_idp_oauth_client_id" {
  secret_id = "prod-google-idp-oauth-client-id"

  replication {
    auto {

    }
  }
}

resource "google_secret_manager_secret_version" "google_idp_oauth_key_version" {
  secret      = google_secret_manager_secret.google_idp_oauth_key.id
  secret_data = var.prod_google_idp_oauth_key
}
