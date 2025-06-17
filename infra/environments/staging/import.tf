import {
  id = "${data.google_project.project.id}/databases/(default)"
  to = module.application.google_firestore_database.default
}
# import {
#   id = "${data.google_project.project.id}/locations/${var.region}/instances/${data.google_project.project.project_id}-staging-rtdb-default"
#   to = module.application.google_firebase_database_instance.default
# }
import {
  id = "firebase-admin-sa@${data.google_project.project.project_id}.iam.gserviceaccount.com"
  to = module.application.google_service_account.firebase_admin_service_account
}
# import {
#   id = "${data.google_project.project.id}/github-actions-main@${data.google_project.project.project_id}.iam.gserviceaccount.comeAccounts/production-application-backend@${data.google_project.project.project_id}.iam.gserviceaccount.com"
#   to = module.application.google_service_account.application_backend_cloud_run_sa
# }
import {
  id = "${data.google_project.project.id}/secrets/googlemaps-web-api-key"
  to = module.application.google_secret_manager_secret.web_google_maps_api_key
}
import {
  id = "${data.google_project.project.id}/locations/${var.region}/repositories/docker-repository-private"
  to = module.application.google_artifact_registry_repository.private_docker_repository
}
import {
  id = "${data.google_project.project.id}/locations/${var.region}/repositories/docker-repository-public"
  to = module.application.google_artifact_registry_repository.public_docker_repository
}
import {
  id = "${data.google_project.project.id}/locations/global/keys/googlemaps-android-api-key"
  to = module.application.google_apikeys_key.google_maps_android_api_key
}
import {
  id = "${data.google_project.project.id}/locations/global/keys/googlemaps-ios-api-key"
  to = module.application.google_apikeys_key.google_maps_ios_api_key
}
import {
  id = "@${data.google_project.project.id}/locations/global/keys/googlemaps-web-api-key"
  to = module.application.google_apikeys_key.web_google_maps_api_key
}
import {
  id = "${data.google_project.project.id}/androidApps/1:${data.google_project.project.number}:android:4ac626dc76c40f14d5c4f0"
  to = module.application.google_firebase_android_app.android_app
}
import {
  id = "${data.google_project.project.id}/iosApps/1:${data.google_project.project.number}:ios:4e9b04f81b79b6add5c4f0"
  to = module.application.google_firebase_apple_app.ios_app
}
import {
  id = "staging-${data.google_project.project.name}-${var.region}-gcf-source"
  to = module.application.google_storage_bucket.bucket_gcf_source
}
# import {
#   id = "${data.google_project.project.id}/locations/${var.region}/functions/${data.google_project.project.name}-${var.region}-idp-before-signin roles/cloudfunctions.invoker allUsers"
#   to = module.application.google_cloudfunctions_function_iam_member.auth_before_sign_in
# }
# import {
#   id = "${data.google_project.project.id}/locations/${var.region}/functions/${data.google_project.project.name}-${var.region}-idp-before-create roles/cloudfunctions.invoker allUsers"
#   to = module.application.google_cloudfunctions_function_iam_member.auth_before_create
# }
import {
  id = "${data.google_project.project.id}/roles/iam.serviceAccounts.actAs"
  to = module.gcloud.google_project_iam_custom_role.limited_service_user
}
import {
  id = "projects/${data.google_project.project.number}/secrets/firebase-config-web"
  to = module.application.google_secret_manager_secret.firebase_config_web
}
# import {
#   to = module.application.google_cloud_run_service_iam_member.allow_unauthenticated
#   id = "${data.google_project.project.id}/locations/${var.region}/services/dev-${data.google_project.project.name}-${var.region}-application-backend roles/run.invoker allUsers"
# }
# import {
#   to = module.application.google_cloud_run_service.application_backend
#   id = "locations/${var.region}/namespaces/${data.google_project.project.project_id}/services/dev-${data.google_project.project.name}-${var.region}-application-backend"
# }
import {
  id = "${data.google_project.project.id}/config"
  to = module.application.google_identity_platform_config.default
}
# import {
#   id = "${data.google_project.project.name}-${var.region}-idp-before-create"
#   to = module.application.google_cloudfunctions_function.auth_before_create
# }
# import {
#   id = "${data.google_project.project.name}-${var.region}-idp-before-signin"
#   to = module.application.google_cloudfunctions_function.auth_before_sign_in
# }
# import {
#   to = module.application.google_artifact_registry_repository_iam_member.application_backend_repo_read_member
#   id = "${data.google_project.project.id}/locations/${var.region}/repositories/docker-repository-private roles/artifactregistry.reader serviceAccount:staging-application-backend@${data.google_project.project.project_id}.iam.gserviceaccount.com"
# }
# import {
#   to = module.application.google_artifact_registry_repository_iam_member.public_read
#   id = "${data.google_project.project.id}/locations/${var.region}/repositories/docker-repository-public roles/artifactregistry.reader allUsers"
# }
import {
  to = module.application.google_firebase_project.default
  id = data.google_project.project.id
}
# import {
#   to = module.application.google_firebase_web_app.web_app
#   id = "${data.google_project.project.project_id} ${data.google_project.project.id}/webApps/1:${data.google_project.project.number}:web:e2d3d3e5465f72d1d5c4f0"
# }
import {
  to = module.application.google_identity_platform_default_supported_idp_config.google
  id = "${data.google_project.project.id}/defaultSupportedIdpConfigs/google.com"
}
# import {
#   to = module.application.google_project_iam_member.application_backend_vault_access
#   id = "${data.google_project.project.id} roles/iam.workloadIdentityUser serviceAccount:production-application-backend@${data.google_project.project.project_id}.iam.gserviceaccount.com"
# }
import {
  to = module.application.google_project_iam_member.firebase_admin_service_agent
  id = "${data.google_project.project.id} roles/firebase.sdkAdminServiceAgent serviceAccount:firebase-admin-sa@${data.google_project.project.project_id}.iam.gserviceaccount.com"
}
# import {
#   to = module.application.google_project_iam_member.firebase_token_creator
#   id = "${data.google_project.project.id} roles/iam.serviceAccountTokenCreator serviceAccount:firebase-admin-sa@${data.google_project.project.project_id}.iam.gserviceaccount.com"
# }
import {
  to = module.application.google_project_service.application_backend_services["run.googleapis.com"]
  id = "${data.google_project.project.project_id}/run.googleapis.com"
}
import {
  to = module.application.google_project_service.google_idp_services["identitytoolkit.googleapis.com"]
  id = "${data.google_project.project.project_id}/identitytoolkit.googleapis.com"
}
import {
  to = module.application.google_project_service.google_maps_services["apikeys.googleapis.com"]
  id = "${data.google_project.project.project_id}/apikeys.googleapis.com"
}
import {
  to = module.application.google_project_service.google_services_firebase["firebase.googleapis.com"]
  id = "${data.google_project.project.project_id}/firebase.googleapis.com"
}
import {
  to = module.application.google_project_service.google_services_firebase["firebasedatabase.googleapis.com"]
  id = "${data.google_project.project.project_id}/firebasedatabase.googleapis.com"
}
import {
  to = module.application.google_project_service.google_services_firebase["firestore.googleapis.com"]
  id = "${data.google_project.project.project_id}/firestore.googleapis.com"
}
import {
  to = module.application.google_secret_manager_secret_iam_member.application_backend_firebase_adminsdk_secret_read
  id = "${data.google_project.project.id}/secrets/firebase-adminsdk-service-account-key roles/secretmanager.secretAccessor serviceAccount:production-application-backend@${data.google_project.project.project_id}.iam.gserviceaccount.com"
}
# import {
#   to = module.application.google_secret_manager_secret_iam_member.application_backend_firebase_web_uiconfig_secret_read
#   id = "${data.google_project.project.id}/secrets/firebase-config-web roles/secretmanager.secretAccessor serviceAccount:production-application-backend@${data.google_project.project.project_id}.iam.gserviceaccount.com"
# }
import {
  to = module.application.google_secret_manager_secret_iam_member.application_backend_wep_googlemaps_api_key_secret_read
  id = "${data.google_project.project.id}/secrets/googlemaps-web-api-key roles/secretmanager.secretAccessor serviceAccount:production-application-backend@${data.google_project.project.project_id}.iam.gserviceaccount.com"
}
import {
  to = module.application.google_secret_manager_secret_iam_member.firebase_admin_service_account_secret_member
  id = "${data.google_project.project.id}/secrets/firebase-adminsdk-service-account-key roles/secretmanager.secretAccessor serviceAccount:production-application-backend@${data.google_project.project.project_id}.iam.gserviceaccount.com"
  # id = "projects/moov-438615/secrets/firebase-adminsdk-service-account-key/roles/secretmanager.secretAccessor/serviceAccount:production-application-backend@moov-438615.iam.gserviceaccount.com",
  # $ google_secret_manager_secret_iam_member.editor "projects/{{project}}/secrets/{{secret_id}} roles/secretmanager.secretAccessor user:jane@example.com"
}
# import {
#   to = module.application.google_secret_manager_secret_version.firebase_adminsdk_secret_version
#   id = "projects/${data.google_project.project.number}/secrets/firebase-adminsdk-service-account-key/versions/2"
# }
# import {
#   to = module.application.google_secret_manager_secret_version.firebase_config_web_version
#   id = "projects/${data.google_project.project.number}/secrets/firebase-config-web/versions/4"
# }
import {
  to = module.application.google_storage_bucket_iam_member.bucket_iam_member
  id = "b/gcf-sources-${data.google_project.project.number}-${var.region} roles/storage.objectViewer serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
}
import {
  to = module.application.google_secret_manager_secret.firebase_admin_service_account_secret
  id = "${data.google_project.project.id}/secrets/firebase-adminsdk-service-account-key"
}
# import {
#   to = google_service_account.github_actions
#   id = "github-actions-main@${data.google_project.project.project_id}.iam.gserviceaccount.com"
# }
# import {
#   to = module.application.google_secret_manager_secret.stripe_key
#   id = "${data.google_project.project.id}/secrets/stripe-key"
# }
import {
  to = google_storage_bucket.firebase_storage_bucket
  id = "${data.google_project.project.id}-firebase-storage"
}
