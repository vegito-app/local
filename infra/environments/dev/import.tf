import {
  id = "${data.google_project.project.id}/databases/(default)"
  to = module.gcloud.google_firestore_database.default
}
# import {
#   id = "${data.google_project.project.id}/locations/${var.region}/instances/${data.google_project.project.project_id}-prod-rtdb-default"
#   to = module.gcloud.google_firebase_database_instance.default
# }
# import {
#   id = "${data.google_project.project.id}/prod-firebase-admin-sa@${data.google_project.project.project_id}.iam.gserviceaccount.com"
#   to = module.gcloud.google_service_account.firebase_admin_service_account
# }
# import {
#   id = "${data.google_project.project.id}/serviceAccounts/production-application-backend@${data.google_project.project.project_id}.iam.gserviceaccount.com"
#   to = module.gcloud.google_service_account.application_backend_cloud_run_sa
# }
# import {
#   id = "${data.google_project.project.id}/secrets/prod-firebase-adminsdk-service-account-key"
#   to = module.gcloud.google_secret_manager_secret.firebase_admin_service_account_secret
# }
# import {
#   id = "${data.google_project.project.id}/serviceAccounts/github-actions-main@${data.google_project.project.project_id}.iam.gserviceaccount.com"
#   to = module.gcloud.google_service_account.github_actions
# }
# import {
#   id = "${data.google_project.project.id}/global/addresses/global-app-address"
#   to = module.cdn.google_compute_global_address.public_cdn
# }
# import {
#   id = "${data.google_project.project.id}/secrets/${data.google_project.project.project_id}-${var.region}-prod-google-maps-api-key"
#   to = module.gcloud.google_secret_manager_secret.web_google_maps_api_key
# }
# import {
#   id = "${data.google_project.project.id}/locations/${var.region}/repositories/docker-repository"
#   to = module.gcloud.google_artifact_registry_repository.private_docker_repository
# }
# import {
#   id = "${data.google_project.project.id}/locations/${var.region}/repositories/docker-repository-public"
#   to = module.gcloud.google_artifact_registry_repository.public_docker_repository
# }
# import {
#   id = "${data.google_project.project.id}/locations/${var.region}/repositories/docker-repository roles/artifactregistry.reader serviceAccount:github-actions-main@${data.google_project.project.project_id}.iam.gserviceaccount.com"
#   to = module.gcloud.google_artifact_registry_repository_iam_member.github_actions_private_repo_read_member
# }
# import {
#   id = "${data.google_project.project.id}/locations/${var.region}/repositories/docker-repository roles/artifactregistry.writer serviceAccount:github-actions-main@${data.google_project.project.project_id}.iam.gserviceaccount.com"
#   to = module.gcloud.google_artifact_registry_repository_iam_member.github_actions_private_repo_write_member
# }
# import {
#   id = "${data.google_project.project.id}/locations/global/keys/mobile-google-maps-api-key-android"
#   to = module.gcloud.google_apikeys_key.google_maps_android_api_key
# }
# import {
#   id = "${data.google_project.project.id}/locations/global/keys/mobile-google-maps-api-key-ios"
#   to = module.gcloud.google_apikeys_key.google_maps_ios_api_key
# }
# import {
#   id = "${data.google_project.project.id}/locations/global/keys/web-google-maps-api-key"
#   to = module.gcloud.google_apikeys_key.web_google_maps_api_key
# }
# import {
#   id = "${data.google_project.project.id}/locations/${var.region}/namespaces/${data.google_project.project.project_id}/services/prod-${var.project_id}-${var.region}-application-backend"
#   to = module.gcloud.google_cloud_run_service.application_backend
# }
# import {
#   id = "${data.google_project.project.project_id}/${var.region}/${data.google_project.project.project_id}-${var.region}-identity-platform-before-signin"
#   to = module.gcloud.google_cloudfunctions_function.auth_before_sign_in
# }
# import {
#   id = "${data.google_project.project.id}/androidApps/1:${data.google_project.project.project_id}:android:747f32fead20a3932b9274"
#   to = module.gcloud.google_firebase_android_app.android_app
# }
# import {
#   id = "${data.google_project.project.id}/iosApps/1:${data.google_project.project.project_id}:ios:1a24632d682b72e22b9274"
#   to = module.gcloud.google_firebase_apple_app.ios_app
# }
# import {
#   id = "prod-${data.google_project.project.project_id}-${var.region}-gcf-source"
#   to = module.gcloud.google_storage_bucket.bucket_gcf_source
# }
# import {
#   id = "${data.google_project.project.project_id}-${var.region}-public-cdn-forwarding-rule"
#   to = module.cdn.google_compute_global_forwarding_rule.public_cdn
# }
# import {
#   id = "${data.google_project.project.id}/global/targetHttpProxies/${data.google_project.project.project_id}-${var.region}-public-cdn-http-proxy"
#   to = module.cdn.google_compute_target_http_proxy.public_cdn
# }
# import {
#   id = "${data.google_project.project.id}/global/urlMaps/${data.google_project.project.project_id}-${var.region}-public-cdn-url-map"
#   to = module.cdn.google_compute_url_map.url_map
# }
# import {
#   id = "b/${data.google_project.project.project_id}-${var.region}-public-images-web roles/storage.objectViewer"
#   to = module.cdn.google_storage_bucket_iam_binding.web_public_image
# }
# import {
#   id = "${data.google_project.project.project_id}-${var.region}-public-images-web"
#   to = module.cdn.google_storage_bucket.public_images
# }
# import {
#   id = "${data.google_project.project.id}/locations/${var.region}/functions/${data.google_project.project.project_id}-${var.region}-identity-platform-before-signin roles/cloudfunctions.invoker allUsers"
#   to = module.gcloud.google_cloudfunctions_function_iam_member.auth_before_sign_in
# }
# import {
#   id = "${data.google_project.project.id}/locations/${var.region}/functions/${data.google_project.project.project_id}-${var.region}-identity-platform-before-create roles/cloudfunctions.invoker allUsers"
#   to = module.gcloud.google_cloudfunctions_function_iam_member.auth_before_create
# }
# import {
#   id = "${data.google_project.project.id}/locations/${var.region}/services/prod-${data.google_project.project.project_id}-${var.region}-application-backend roles/run.invoker allUsers"
#   to = module.gcloud.google_cloud_run_service_iam_member.allow_unauthenticated
# }
# import {
#   id = "${data.google_project.project.project_id}/${var.region}/${data.google_project.project.project_id}-${var.region}-identity-platform-before-create"
#   to = module.gcloud.google_cloudfunctions_function.auth_before_create
# }
# import {
#   id = "${data.google_project.project.id}/global/backendBuckets/${data.google_project.project.project_id}-${var.region}-public-cdn"
#   to = module.cdn.google_compute_backend_bucket.public_cdn
# }
# import {
#   id = "${data.google_project.project.id}/roles/iam.serviceAccounts.actAs"
#   to = module.gcloud.google_project_iam_custom_role.limited_service_user
# }
# import {
#   id = "${data.google_project.project.id}/secrets/${data.google_project.project.project_id}-${var.region}-prod-google-maps-api-key/versions/2"
#   to = module.gcloud.google_secret_manager_secret_version.web_google_maps_api_key_version
# }
import {
  id = "${data.google_project.project.id}/config"
  to = module.gcloud.google_identity_platform_config.default
}
# import {
#   id = "${data.google_project.project.id}/secrets/prod-firebase-web-config"
#   to = module.gcloud.google_secret_manager_secret.firebase_config_web
# }
# # import {
# #   # id = "${data.google_project.project.id}/defaultSupportedIdpConfigs/google"
# #   id = "google"
# #   to = module.gcloud.google_identity_platform_default_supported_idp_config.google
# # }
