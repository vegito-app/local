resource "google_secret_manager_secret" "googlemaps_api_key" {
  secret_id = "${var.project_name}-${var.region}-googlemaps-api-key"

  replication {
    auto {

    }
  }
}

resource "google_secret_manager_secret_version" "googlemaps_api_key_version" {
  secret = google_secret_manager_secret.googlemaps_api_key.id
  secret_data = jsonencode({
    apiKey = var.GOOGLE_MAPS_API_KEY
  })
}

resource "google_secret_manager_secret" "firebase_config" {
  secret_id = "${var.project_name}-${var.region}-firebase-config"

  replication {
    auto {

    }
  }
}

resource "google_secret_manager_secret_version" "firebase_config_version" {
  secret = google_secret_manager_secret.firebase_config.id
  secret_data = jsonencode({
    apiKey            = var.FIREBASE_API_KEY
    authDomain        = var.FIREBASE_AUTH_DOMAIN
    databaseURL       = var.FIREBASE_DATABASE_URL
    projectId         = var.FIREBASE_PROJECT_ID
    storageBucket     = var.FIREBASE_STORAGE_BUCKET
    messagingSenderId = var.FIREBASE_MESSAGING_SENDER_ID
    appId             = var.FIREBASE_APP_ID
  })
}
