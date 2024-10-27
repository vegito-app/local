
# Enables required APIs.
resource "google_project_service" "google_maps_services" {
  provider = google-beta.no_user_project_override
  project  = data.google_project.project.project_id
  for_each = toset([
    "apikeys.googleapis.com",
  ])
  service = each.key

  # Don't disable the service if the resource block is removed by accident.
  disable_on_destroy         = false
  disable_dependent_services = true
}

resource "google_secret_manager_secret" "web_google_maps_api_key" {
  secret_id = "prod-google-maps-api-key"

  replication {
    auto {

    }
  }
  depends_on = [google_project_service.google_maps_services]
}

locals {
  allowed_referrers = [
    "localhost",
    "${data.google_project.project.project_id}.firebaseapp.com",
    "${data.google_project.project.project_id}.web.app",
    "prod-moov-438615-europe-west1-application-backend-v4bqtohg4a-ew.a.run.app",
    # trimprefix(one(google_cloud_run_service.application_backend.status[*].url), "https://")
  ]
}

# Créer la clé API Google Maps pour le web
resource "google_apikeys_key" "web_google_maps_api_key" {
  name         = "web-google-maps-api-key"
  display_name = "Web Maps API Key"
  restrictions {
    # Limiter l'usage de cette clé API aux requêtes provenant du domaine Cloud Run
    browser_key_restrictions {
      allowed_referrers = local.allowed_referrers
    }

    # Restreindre aux API Google Maps spécifiques
    api_targets {
      service = "maps-backend.googleapis.com"
    }
  }
}

resource "google_secret_manager_secret_version" "web_google_maps_api_key_version" {
  secret = google_secret_manager_secret.web_google_maps_api_key.id
  secret_data = jsonencode({
    apiKey = google_apikeys_key.web_google_maps_api_key.key_string
  })
}

output "google_maps_api_key_web" {
  value       = google_secret_manager_secret_version.web_google_maps_api_key_version.secret
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
        google_firebase_apple_app.ios_app.bundle_id
      ]
    }
    api_targets {
      service = "maps.googleapis.com"
      methods = ["*"]
    }
  }
}
