module "cdn" {
  source      = "./cdn"
  environment = "prod"

  project_id = data.google_project.project.project_id
  region     = var.region
}

module "gcloud" {
  source      = "../../gcloud"
  environment = "prod"

  project_id = data.google_project.project.id
  region     = var.region

  cloud_storage_location = var.cloud_storage_location

  application_backend_image = var.application_backend_image

  ui_firebase_secret_id   = var.ui_firebase_secret_id
  ui_googlemaps_secret_id = var.ui_googlemaps_secret_id
}

output "project" {
  value = data.google_project.project.id
}

import {
  id = "projects/${data.google_project.project.project_id}/databases/(default)"
  to = module.gcloud.google_firestore_database.production
}
import {
  id = "prod-${data.google_project.project.project_id}-rtdb"
  to = module.gcloud.google_firebase_database_instance.moov
}
import {
  id = "projects/${data.google_project.project.project_id}/prod-firebase-admin-sa@${data.google_project.project.project_id}.iam.gserviceaccount.com"
  to = module.gcloud.google_service_account.firebase_admin_service_account
}
import {
  id = "projects/${data.google_project.project.project_id}/serviceAccounts/production-application-backend@${data.google_project.project.project_id}.iam.gserviceaccount.com"
  to = module.gcloud.google_service_account.application_backend_cloud_run_sa
}
import {
  id = "projects/${data.google_project.project.project_id}/secrets/prod-firebase-adminsdk-service-account-key"
  to = module.gcloud.google_secret_manager_secret.firebase_admin_service_account_secret
}
import {
  id = "projects/${data.google_project.project.project_id}/serviceAccounts/github-actions-main@${data.google_project.project.project_id}.iam.gserviceaccount.com"
  to = module.gcloud.google_service_account.github_actions
}
import {
  id = "projects/${data.google_project.project.project_id}/global/addresses/global-app-address"
  to = module.cdn.google_compute_global_address.public_cdn
}
import {
  id = "projects/${data.google_project.project.project_id}/secrets/${data.google_project.project.project_id}-${var.region}-prod-google-maps-api-key"
  to = module.gcloud.google_secret_manager_secret.web_google_maps_api_key
}
import {
  id = "projects/${data.google_project.project.project_id}/locations/${var.region}/repositories/prod-docker-repository"
  to = module.gcloud.google_artifact_registry_repository.private_docker_repository
}
import {
  id = "projects/${data.google_project.project.project_id}/locations/${var.region}/repositories/prod-docker-repository-public"
  to = module.gcloud.google_artifact_registry_repository.public_docker_repository
}
import {
  id = "projects/${data.google_project.project.project_id}/locations/${var.region}/repositories/prod-docker-repository roles/artifactregistry.reader serviceAccount:github-actions-main@${data.google_project.project.project_id}.iam.gserviceaccount.com"
  to = module.gcloud.google_artifact_registry_repository_iam_member.github_actions_private_repo_read_member
}
import {
  id = "projects/${data.google_project.project.project_id}/locations/${var.region}/repositories/prod-docker-repository roles/artifactregistry.writer serviceAccount:github-actions-main@${data.google_project.project.project_id}.iam.gserviceaccount.com"
  to = module.gcloud.google_artifact_registry_repository_iam_member.github_actions_private_repo_write_member
}
import {
  id = "projects/${data.google_project.project.project_id}/locations/global/keys/mobile-google-maps-api-key-android"
  to = module.gcloud.google_apikeys_key.google_maps_android_api_key
}
import {
  id = "projects/${data.google_project.project.project_id}/locations/global/keys/mobile-google-maps-api-key-ios"
  to = module.gcloud.google_apikeys_key.google_maps_ios_api_key
}
import {
  id = "projects/${data.google_project.project.project_id}/locations/global/keys/web-google-maps-api-key"
  to = module.gcloud.google_apikeys_key.web_google_maps_api_key
}
import {
  id = "locations/${var.region}/namespaces/${data.google_project.project.project_id}/services/prod-${data.google_project.project.project_id}-${var.region}-application-backend"
  to = module.gcloud.google_cloud_run_service.application_backend
}
import {
  to = module.gcloud.google_cloudfunctions_function.auth_before_sign_in
  id = "${data.google_project.project.project_id}/${var.region}/${data.google_project.project.project_id}-${var.region}-identity-platform-before-signin"
}
import {
  to = module.gcloud.google_firebase_android_app.android_app
  id = "projects/${data.google_project.project.project_id}/androidApps/1:${data.google_project.project.project_id}:android:747f32fead20a3932b9274"
}
import {
  to = module.gcloud.google_firebase_apple_app.ios_app
  id = "projects/${data.google_project.project.project_id}/iosApps/1:${data.google_project.project.project_id}:ios:1a24632d682b72e22b9274"
}
import {
  to = module.gcloud.google_storage_bucket.bucket_gcf_source
  id = "prod-${data.google_project.project.project_id}-${var.region}-gcf-source"
}
import {
  to = module.cdn.google_compute_global_forwarding_rule.public_cdn
  id = "${data.google_project.project.project_id}-${var.region}-public-cdn-forwarding-rule"
}
import {
  to = module.cdn.google_compute_target_http_proxy.public_cdn
  id = "projects/${data.google_project.project.project_id}/global/targetHttpProxies/${data.google_project.project.project_id}-${var.region}-public-cdn-http-proxy"
}
import {
  to = module.cdn.google_compute_url_map.url_map
  id = "projects/${data.google_project.project.project_id}/global/urlMaps/${data.google_project.project.project_id}-${var.region}-public-cdn-url-map"
}
import {
  to = module.cdn.google_storage_bucket_iam_binding.web_public_image
  id = "b/${data.google_project.project.project_id}-${var.region}-public-images-web roles/storage.objectViewer"
}
import {
  to = module.cdn.google_storage_bucket.public_images
  id = "${data.google_project.project.project_id}-${var.region}-public-images-web"
}
import {
  to = module.gcloud.google_cloudfunctions_function_iam_member.auth_before_sign_in
  id = "projects/${data.google_project.project.project_id}/locations/${var.region}/functions/${data.google_project.project.project_id}-${var.region}-identity-platform-before-signin roles/cloudfunctions.invoker allUsers"
}
import {
  to = module.gcloud.google_cloudfunctions_function_iam_member.auth_before_create
  id = "projects/${data.google_project.project.project_id}/locations/${var.region}/functions/${data.google_project.project.project_id}-${var.region}-identity-platform-before-create roles/cloudfunctions.invoker allUsers"
}
import {
  to = module.gcloud.google_cloud_run_service_iam_member.allow_unauthenticated
  id = "projects/${data.google_project.project.project_id}/locations/${var.region}/services/prod-${data.google_project.project.project_id}-${var.region}-application-backend roles/run.invoker allUsers"
}
import {
  to = module.gcloud.google_cloudfunctions_function.auth_before_create
  id = "${data.google_project.project.project_id}/${var.region}/${data.google_project.project.project_id}-${var.region}-identity-platform-before-create"
}
import {
  to = module.cdn.google_compute_backend_bucket.public_cdn
  id = "projects/${data.google_project.project.project_id}/global/backendBuckets/${data.google_project.project.project_id}-${var.region}-public-cdn"
}
import {
  to = module.gcloud.google_project_iam_custom_role.limited_service_user
  id = "projects/${data.google_project.project.project_id}/roles/iam.serviceAccounts.actAs"
}
import {
  to = module.gcloud.google_secret_manager_secret_version.web_google_maps_api_key_version
  id = "projects/${data.google_project.project.project_id}/secrets/${data.google_project.project.project_id}-${var.region}-prod-google-maps-api-key/versions/2"
}
import {
  to = module.gcloud.google_identity_platform_config.moov
  id = "projects/${data.google_project.project.project_id}/config"
}
import {
  to = module.gcloud.google_secret_manager_secret.firebase_config_web
  id = "projects/${data.google_project.project.project_id}/secrets/prod-firebase-web-config"
}
import {
  to = google_identity_platform_default_supported_idp_config.google
  id = "projects/${data.google_project.project.project_id}/defaultSupportedIdpConfigs/google"
}

# Enables required APIs.
resource "google_project_service" "google_services_default" {
  provider = google-beta.no_user_project_override
  project  = data.google_project.project.id
  for_each = toset([
    "cloudbilling.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "secretmanager.googleapis.com",
    "serviceusage.googleapis.com",
  ])
  service = each.key

  # Don't disable the service if the resource block is removed by accident.
  disable_on_destroy         = false
  disable_dependent_services = true
}

resource "google_storage_bucket" "bucket_tf_state_eu_global" {
  name     = "global-${var.region}-tf-state"
  location = var.region

  storage_class = "STANDARD"

  force_destroy = false # Do not remove bucket if remaining tf_state

  uniform_bucket_level_access = true # Needed to use with tf tf_lock

  versioning {
    enabled = true
  }
}

import {
  to = google_storage_bucket.bucket_tf_state_eu_global
  id = "global-${var.region}-tf-state"
}

output "tf_state_bucket_url" {
  description = "Terraform state GCS bucket URL."
  value       = google_storage_bucket.bucket_tf_state_eu_global.url
}
