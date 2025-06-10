resource "google_secret_manager_secret" "google_idp_oauth_key" {
  secret_id = "google-idp-oauth-key"

  replication {
    auto {

    }
  }
}

resource "google_secret_manager_secret" "google_idp_oauth_client_id" {
  secret_id = "google-idp-oauth-client-id"

  replication {
    auto {

    }
  }
}
