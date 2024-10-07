
resource "google_secret_manager_secret" "web_google_maps_api_key" {
  count     = var.create_secret ? 1 : 0
  secret_id = "${var.project_name}-${var.region}-googlemaps-api-key"

  replication {
    auto {

    }
  }
}

# Créer la clé API Google Maps pour le web
resource "google_apikeys_key" "web_google_maps_api_key" {
  count        = var.create_secret ? 1 : 0
  name         = "web-google-maps-api-key"
  display_name = "Web Maps API Key"
  restrictions {
    # Limiter l'usage de cette clé API aux requêtes provenant du domaine Cloud Run
    browser_key_restrictions {
      allowed_referrers = [
        "${var.web_backend_server_url}/*", # Domaine public de Cloud Run
      ]
    }

    # Restreindre aux API Google Maps spécifiques
    api_targets {
      service = "maps.googleapis.com" # API Google Maps JavaScript
    }
  }
}

resource "google_secret_manager_secret_version" "web_google_maps_api_key_version" {
  count  = var.create_secret ? 1 : 0
  secret = google_secret_manager_secret.web_google_maps_api_key[count.index].id
  secret_data = jsonencode({
    apiKey = google_apikeys_key.web_google_maps_api_key[count.index].key_string
  })
}

output "google_maps_api_key_web" {
  value       = length(google_secret_manager_secret_version.web_google_maps_api_key_version) > 0 ? google_secret_manager_secret_version.web_google_maps_api_key_version[0].secret : null
  description = "Web Google Maps API key usable on Cloud Run backend service domain"
}

# Clé API pour Android
resource "google_apikeys_key" "google_maps_android_api_key" {
  display_name = "Google Maps Android API Key"
  name         = "mobile-google-maps-api-key-android"
  restrictions {
    # android_key_restrictions {
    #   allowed_applications {
    #     # sha1_fingerprint = var.google_firebase_android_app_sha1_fingerprint
    #     # package_name     = var.google_firebase_android_app_package_name
    #   }
    # }
    api_targets {
      service = "maps.googleapis.com"
      methods = ["*"]
    }
  }
}

# Clé API pour iOS
resource "google_apikeys_key" "google_maps_ios_api_key" {
  display_name = "Google Maps iOS API Key"
  name         = "mobile-google-maps-api-key-ios"

  restrictions {
    ios_key_restrictions {
      allowed_bundle_ids = [
        var.google_firebase_apple_ios_app_bundle_id
      ]
    }
    api_targets {
      service = "maps.googleapis.com"
      methods = ["*"]
    }
  }
}
