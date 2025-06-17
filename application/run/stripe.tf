resource "google_secret_manager_secret" "stripe_key" {
  secret_id = "stripe-key"

  replication {
    auto {

    }
  }
}

resource "google_secret_manager_secret" "stripe_public_key" {
  secret_id = "stripe-public-key"

  replication {
    auto {

    }
  }
}
