INFRA_ENV ?= prod

TERRAFORM_ROOT_MODULE ?= $(CURDIR)/infra/environments/$(INFRA_ENV)

TERRAFORM = \
	TF_VAR_application_backend_image=$(APPLICATION_BACKEND_IMAGE) \
	TF_VAR_google_credentials_file=$(GOOGLE_CLOUD_CREDENTIALS_JSON_FILE) \
	TF_VAR_google_idp_oauth_key_secret_id=$(INFRA_GOOGLE_IDP_OAUTH_KEY) \
	TF_VAR_google_idp_oauth_client_id_secret_id=$(INFRA_GOOGLE_IDP_OAUTH_CLIENT_ID) \
		terraform -chdir=$(TERRAFORM_ROOT_MODULE)

terraform-init: $(GOOGLE_CLOUD_CREDENTIALS_JSON_FILE)
	@$(TERRAFORM) init --upgrade
.PHONY: terraform-init


terraform-import: $(GOOGLE_CLOUD_CREDENTIALS_JSON_FILE)
# @$(TERRAFORM) import module.infra.google_identity_platform_config.utrade $(GOOGLE_CLOUD_PROJECT_ID)
# @$(TERRAFORM) import module.gcloud.google_service_account.firebase_admin_service_account firebase-adminsdk-vxdj8@moov-438615.iam.gserviceaccount.com
# @$(TERRAFORM) import module.gcloud.google_firebase_database_instance.moov projects/$(GOOGLE_CLOUD_PROJECT_ID)/locations/$(GOOGLE_CLOUD_REGION)/instances/$(INFRA_ENV)-$(GOOGLE_CLOUD_PROJECT_ID)-rtdb
# @$(TERRAFORM) import module.gcloud.google_firebase_database_instance.utrade projects/$(GOOGLE_CLOUD_PROJECT_ID)/locations/$(GOOGLE_CLOUD_REGION)/instances/$(GOOGLE_CLOUD_PROJECT_ID)-default-rtdb
# @$(TERRAFORM) import module.gcloud.google_firebase_android_app.android_app projects/utrade-taxi-run-0/androidApps/1:$(GOOGLE_CLOUD_PROJECT_NUMBER):android:0af3c208c26031f319de54
# @$(TERRAFORM) import module.gcloud.google_firebase_apple_app.ios_app projects/utrade-taxi-run-0/iosApps/1:$(GOOGLE_CLOUD_PROJECT_NUMBER):ios:62943a0db6f9c9ff19de54
# @$(TERRAFORM) import google_service_account.firebase_admin projects/$(GOOGLE_CLOUD_PROJECT_ID)/firebase-adminsdk-vxdj8@$(GOOGLE_CLOUD_PROJECT_ID).iam.gserviceaccount.com
# @$(TERRAFORM) import module.infra.google_cloudfunctions_function.auth_before_sign_in projects/utrade-taxi-run-0/locations/us-central1/functions/utrade-us-central1-identity-platform
# @$(TERRAFORM) import module.infra.google_apikeys_key.web_google_maps_api_key projects/$(GOOGLE_CLOUD_PROJECT_NUMBER)/locations/global/keys/web-google-maps-api-key
# @$(TERRAFORM) import module.infra.google_apikeys_key.google_maps_android_api_key projects/$(GOOGLE_CLOUD_PROJECT_NUMBER)/locations/global/keys/mobile-google-maps-api-key-android
# @$(TERRAFORM) import module.infra.google_apikeys_key.google_maps_ios_api_key projects/$(GOOGLE_CLOUD_PROJECT_NUMBER)/locations/global/keys/mobile-google-maps-api-key-ios
# @$(TERRAFORM) import google_storage_bucket.bucket_tf_state_eu utrade-$(GOOGLE_CLOUD_REGION)-tf-state
# @$(TERRAFORM) import module.gcloud.google_service_account.application_backend_cloud_run_sa projects/$(GOOGLE_CLOUD_PROJECT_ID)/serviceAccounts/production-application-backend@$(GOOGLE_CLOUD_PROJECT_ID).iam.gserviceaccount.com
# @$(TERRAFORM) import module.gcloud.google_service_account.firebase_admin_service_account projects/$(GOOGLE_CLOUD_PROJECT_ID)/serviceAccounts/prod-firebase-admin-sa@$(GOOGLE_CLOUD_PROJECT_ID).iam.gserviceaccount.com
# @$(TERRAFORM) import module.gcloud.google_secret_manager_secret.firebase_admin_service_account_secret projects/378762893981/secrets/prod-firebase-adminsdk-service-account-key
# @$(TERRAFORM) import module.gcloud.google_secret_manager_secret.firebase_config projects/378762893981/secrets/prod-firebase-config-secret
# @$(TERRAFORM) import module.gcloud.google_service_account.github_actions projects/$(GOOGLE_CLOUD_PROJECT_ID)/serviceAccounts/github-actions-main@$(GOOGLE_CLOUD_PROJECT_ID).iam.gserviceaccount.com
# @$(TERRAFORM) import module.gcloud.module.cdn.google_compute_global_address.public_cdn  projects/$(GOOGLE_CLOUD_PROJECT_ID)/global/addresses/global-app-address
# @$(TERRAFORM) import module.gcloud.google_secret_manager_secret.web_google_maps_api_key projects/378762893981/secrets/$(GOOGLE_CLOUD_PROJECT_ID)-$(GOOGLE_CLOUD_REGION)-googlemaps-api-key
# @$(TERRAFORM) import module.gcloud.google_firebase_database_instance.moov prod-$(GOOGLE_CLOUD_PROJECT_ID)-rtdb-805c8
# @$(TERRAFORM) import module.gcloud.google_firebase_database_instance.moov prod-$(GOOGLE_CLOUD_PROJECT_ID)-rtdb-f82fe
# @$(TERRAFORM) import module.gcloud.google_firebase_database_instance.moov prod-$(GOOGLE_CLOUD_PROJECT_ID)-rtdb-964f7
# @$(TERRAFORM) import module.gcloud.google_artifact_registry_repository.private_docker_repository projects/$(GOOGLE_CLOUD_PROJECT_ID)/locations/$(GOOGLE_CLOUD_REGION)/repositories/$(INFRA_ENV)-docker-repository
# @$(TERRAFORM) import module.gcloud.google_artifact_registry_repository.public_docker_repository projects/$(GOOGLE_CLOUD_PROJECT_ID)/locations/$(GOOGLE_CLOUD_REGION)/repositories/$(INFRA_ENV)-docker-repository-public
# @$(TERRAFORM) import module.gcloud.google_artifact_registry_repository_iam_member.github_actions_private_repo_read_member \
# 	"projects/$(GOOGLE_CLOUD_PROJECT_ID)/locations/$(GOOGLE_CLOUD_REGION)/repositories/$(INFRA_ENV)-docker-repository roles/artifactregistry.reader serviceAccount:github-actions-main@$(GOOGLE_CLOUD_PROJECT_ID).iam.gserviceaccount.com"
# @$(TERRAFORM) import module.gcloud.google_artifact_registry_repository_iam_member.github_actions_private_repo_write_member \
# 	"projects/$(GOOGLE_CLOUD_PROJECT_ID)/locations/$(GOOGLE_CLOUD_REGION)/repositories/$(INFRA_ENV)-docker-repository roles/artifactregistry.writer serviceAccount:github-actions-main@$(GOOGLE_CLOUD_PROJECT_ID).iam.gserviceaccount.com"
# @$(TERRAFORM) import module.gcloud.google_apikeys_key.google_maps_android_api_key projects/$(GOOGLE_CLOUD_PROJECT_ID)/locations/global/keys/mobile-google-maps-api-key-android
# @$(TERRAFORM) import module.gcloud.google_apikeys_key.google_maps_ios_api_key projects/$(GOOGLE_CLOUD_PROJECT_ID)/locations/global/keys/mobile-google-maps-api-key-ios
# @$(TERRAFORM) import module.gcloud.google_apikeys_key.web_google_maps_api_key projects/$(GOOGLE_CLOUD_PROJECT_ID)/locations/global/keys/web-google-maps-api-key
# @$(TERRAFORM) import module.gcloud.google_cloud_run_service.application_backend locations/$(GOOGLE_CLOUD_REGION)/namespaces/$(GOOGLE_CLOUD_PROJECT_ID)/services/prod-$(GOOGLE_CLOUD_PROJECT_ID)-$(GOOGLE_CLOUD_REGION)-application-backend
# $(TERRAFORM) import module.gcloud.google_cloudfunctions_function.auth_before_sign_in $(GOOGLE_CLOUD_PROJECT_ID)/$(GOOGLE_CLOUD_REGION)/$(GOOGLE_CLOUD_PROJECT_ID)-$(GOOGLE_CLOUD_REGION)-identity-platform-before-signin
# $(TERRAFORM) import module.gcloud.google_firebase_android_app.android_app projects/$(GOOGLE_CLOUD_PROJECT_ID)/androidApps/1:378762893981:android:747f32fead20a3932b9274
# $(TERRAFORM) import module.gcloud.google_firebase_apple_app.ios_app projects/$(GOOGLE_CLOUD_PROJECT_ID)/iosApps/1:378762893981:ios:1a24632d682b72e22b9274
# $(TERRAFORM) import module.gcloud.google_storage_bucket.bucket_gcf_source prod-$(GOOGLE_CLOUD_PROJECT_ID)-$(GOOGLE_CLOUD_REGION)-gcf-source
# $(TERRAFORM) import module.gcloud.google_storage_bucket.bucket_tf_state_eu utrade-$(GOOGLE_CLOUD_REGION)-tf-state
# $(TERRAFORM) import module.gcloud.module.cdn.google_compute_global_forwarding_rule.public_cdn $(GOOGLE_CLOUD_PROJECT_ID)-$(GOOGLE_CLOUD_REGION)-public-cdn-forwarding-rule
# $(TERRAFORM) import module.gcloud.module.cdn.google_compute_target_http_proxy.public_cdn projects/$(GOOGLE_CLOUD_PROJECT_ID)/global/targetHttpProxies/$(GOOGLE_CLOUD_PROJECT_ID)-$(GOOGLE_CLOUD_REGION)-public-cdn-http-proxy
# $(TERRAFORM) import module.gcloud.module.cdn.google_compute_url_map.url_map projects/$(GOOGLE_CLOUD_PROJECT_ID)/global/urlMaps/$(GOOGLE_CLOUD_PROJECT_ID)-$(GOOGLE_CLOUD_REGION)-public-cdn-url-map
# $(TERRAFORM) import module.gcloud.module.cdn.google_storage_bucket_iam_binding.web_public_image "b/$(GOOGLE_CLOUD_PROJECT_ID)-$(GOOGLE_CLOUD_REGION)-public-images-web roles/storage.objectViewer"
# $(TERRAFORM) import module.gcloud.module.cdn.google_storage_bucket.public_images  $(GOOGLE_CLOUD_PROJECT_ID)-$(GOOGLE_CLOUD_REGION)-public-images-web
# $(TERRAFORM) import module.gcloud.google_cloudfunctions_function_iam_member.auth_before_sign_in "projects/$(GOOGLE_CLOUD_PROJECT_ID)/locations/$(GOOGLE_CLOUD_REGION)/functions/$(GOOGLE_CLOUD_PROJECT_ID)-$(GOOGLE_CLOUD_REGION)-identity-platform-before-signin roles/cloudfunctions.invoker allUsers"
# $(TERRAFORM) import module.gcloud.google_cloudfunctions_function_iam_member.auth_before_create "projects/$(GOOGLE_CLOUD_PROJECT_ID)/locations/$(GOOGLE_CLOUD_REGION)/functions/$(GOOGLE_CLOUD_PROJECT_ID)-$(GOOGLE_CLOUD_REGION)-identity-platform-before-create roles/cloudfunctions.invoker allUsers"
# $(TERRAFORM) import module.gcloud.google_cloud_run_service_iam_member.allow_unauthenticated "projects/$(GOOGLE_CLOUD_PROJECT_ID)/locations/$(GOOGLE_CLOUD_REGION)/services/prod-$(GOOGLE_CLOUD_PROJECT_ID)-$(GOOGLE_CLOUD_REGION)-application-backend roles/run.invoker allUsers"
# $(TERRAFORM) import module.gcloud.google_cloudfunctions_function.auth_before_create $(GOOGLE_CLOUD_PROJECT_ID)/$(GOOGLE_CLOUD_REGION)/$(GOOGLE_CLOUD_PROJECT_ID)-$(GOOGLE_CLOUD_REGION)-identity-platform-before-create
# $(TERRAFORM) import module.gcloud.module.cdn.google_compute_backend_bucket.public_cdn projects/$(GOOGLE_CLOUD_PROJECT_ID)/global/backendBuckets/$(GOOGLE_CLOUD_PROJECT_ID)-$(GOOGLE_CLOUD_REGION)-public-cdn
# $(TERRAFORM) import module.gcloud.google_project_iam_custom_role.limited_service_user projects/moov-438615/roles/iam.serviceAccounts.actAs
# $(TERRAFORM) import module.gcloud.google_secret_manager_secret_version.web_google_maps_api_key_version projects/378762893981/secrets/$(GOOGLE_CLOUD_PROJECT_ID)-$(GOOGLE_CLOUD_REGION)-googlemaps-api-key/versions/2
# $(TERRAFORM) import module.gcloud.google_identity_platform_config.moov projects/$(GOOGLE_CLOUD_PROJECT_ID)/config
.PHONY: terraform-import

# Use this target to help updating the bellow TF_STATE_ITEMS list manually.
terraform-state-list: $(GOOGLE_CLOUD_CREDENTIALS_JSON_FILE)
	@$(TERRAFORM) state list
.PHONY: terraform-state-list

# This list is used to provide generic terraform targets 
TF_STATE_ITEMS = \
	google_project.utrade \
	google_storage_bucket.bucket_tf_state \
	module.infra.data.archive_file.auth_func_src \
	module.infra.data.google_firebase_android_app.android_sha \
	module.infra.data.google_firebase_android_app_config.android_config \
	module.infra.data.google_firebase_apple_app_config.ios_config \
	module.infra.data.google_firebase_web_app_config.web_app_config \
	module.infra.google_apikeys_key.google_maps_android_api_key \
	module.infra.google_apikeys_key.google_maps_ios_api_key \
	module.infra.google_apikeys_key.web_google_maps_api_key \
	module.infra.google_artifact_registry_repository.public_repo \
	module.infra.google_artifact_registry_repository.utrade \
	module.infra.google_artifact_registry_repository_iam_member.github_actions_private_repo_read_member \
	module.infra.google_artifact_registry_repository_iam_member.github_actions_private_repo_write_member \
	module.infra.google_artifact_registry_repository_iam_member.github_actions_public_repo_write_member \
	module.infra.google_artifact_registry_repository_iam_member.public_read \
	module.gcloud.google_cloud_run_service.application_backend \
	module.infra.google_cloud_run_service_iam_member.allow_unauthenticated \
	module.infra.google_cloudfunctions_function.auth_before_create \
	module.infra.google_cloudfunctions_function.auth_before_sign_in \
	module.infra.google_cloudfunctions_function_iam_member.auth_before_create \
	module.infra.google_cloudfunctions_function_iam_member.auth_before_sign_in \
	module.infra.google_firebase_android_app.android_app \
	module.infra.google_firebase_apple_app.ios_app \
	module.infra.google_firebase_database_instance.utrade \
	module.infra.google_firebase_project.utrade \
	module.infra.google_firebase_web_app.web_app \
	module.infra.google_identity_platform_config.utrade \
	module.infra.google_project_iam_custom_role.limited_service_user \
	module.infra.google_project_iam_member.firebase_admin_service_agent \
	module.infra.google_project_iam_member.firebase_token_creator \
	module.infra.google_project_service.google_services_default["cloudbilling.googleapis.com"] \
	module.infra.google_project_service.google_services_default["cloudbuild.googleapis.com"] \
	module.infra.google_project_service.google_services_default["cloudfunctions.googleapis.com"] \
	module.infra.google_project_service.google_services_default["cloudresourcemanager.googleapis.com"] \
	module.infra.google_project_service.google_services_default["compute.googleapis.com"] \
	module.infra.google_project_service.google_services_default["identitytoolkit.googleapis.com"] \
	module.infra.google_project_service.google_services_default["secretmanager.googleapis.com"] \
	module.infra.google_project_service.google_services_default["serviceusage.googleapis.com"] \
	module.infra.google_project_service.google_services_firebase["firebase.googleapis.com"] \
	module.infra.google_project_service.google_services_firebase["firebasedatabase.googleapis.com"] \
	module.infra.google_project_service.google_services_firebase["firestore.googleapis.com"] \
	module.infra.google_project_service.google_services_maps["directions-backend.googleapis.com"] \
	module.infra.google_project_service.google_services_maps["geocoding-backend.googleapis.com"] \
	module.infra.google_project_service.google_services_maps["maps-backend.googleapis.com"] \
	module.infra.google_project_service.google_services_maps["maps-ios-backend.googleapis.com"] \
	module.infra.google_secret_manager_secret.firebase_admin_service_account_secret \
	module.infra.google_secret_manager_secret.firebase_config \
	module.infra.google_secret_manager_secret.web_google_maps_api_key \
	module.infra.google_secret_manager_secret_iam_member.application_backend_firebase_config \
	module.infra.google_secret_manager_secret_iam_member.application_backend_web_google_maps_api_key \
	module.infra.google_secret_manager_secret_iam_member.firebase_admin_service_account_secret_member \
	module.infra.google_secret_manager_secret_version.firebase_admin_secret_version \
	module.infra.google_secret_manager_secret_version.firebase_config_version \
	module.infra.google_secret_manager_secret_version.web_google_maps_api_key_version \
	module.infra.google_service_account.application_backend_cloud_run_sa \
	module.infra.google_service_account.firebase_admin_service_account \
	module.infra.google_service_account.github_actions \
	module.infra.google_service_account_key.firebase_admin_service_account_key \
	module.infra.google_service_account_key.github_actions_key \
	module.infra.google_storage_bucket.bucket_gcf_source \
	module.infra.google_storage_bucket_object.auth \
	module.infra.null_resource.docker_auth \
	module.infra.null_resource.docker_auth_public \
	module.infra.module.cdn.google_compute_backend_bucket.public_cdn \
	module.infra.module.cdn.google_compute_global_address.public_cdn \
	module.infra.module.cdn.google_compute_global_forwarding_rule.public_cdn \
	module.infra.module.cdn.google_compute_target_http_proxy.public_cdn \
	module.infra.module.cdn.google_compute_url_map.url_map \
	module.infra.module.cdn.google_storage_bucket.public_images \
	module.infra.module.cdn.google_storage_bucket_iam_binding.web_public_image \
	module.infra.module.cdn.google_storage_bucket_object.public_web_background_image

$(TF_STATE_ITEMS:%=%-show): $(GOOGLE_CLOUD_CREDENTIALS_JSON_FILE)
	@$(TERRAFORM) state show $(@:%-show=%)
.PHONY: $(TF_STATE_ITEMS:%=%-show)

$(TF_STATE_ITEMS:%=%-rm): $(GOOGLE_CLOUD_CREDENTIALS_JSON_FILE)
	@$(TERRAFORM) state rm $(@:%-rm=%)
.PHONY: $(TF_STATE_ITEMS:%=%-rm)

$(TF_STATE_ITEMS:%=%-taint): $(GOOGLE_CLOUD_CREDENTIALS_JSON_FILE)
	@$(TERRAFORM) taint $(@:%-taint=%)
.PHONY: $(TF_STATE_ITEMS:%=%-taint)

terraform-taint-backend: module.gcloud.google_cloud_run_service.application_backend-taint
.PHONY: terraform-taint-backend

terraform-state-show-all : $(TF_STATE_ITEMS:%=%-show)
.PHONY: terraform-state-show

terraform-upgrade: $(GOOGLE_CLOUD_CREDENTIALS_JSON_FILE)
	@$(TERRAFORM) init -upgrade
.PHONY: terraform-upgrade

terraform-reconfigure: $(GOOGLE_CLOUD_CREDENTIALS_JSON_FILE)
	@$(TERRAFORM) init -reconfigure
.PHONY: terraform-reconfigure

terraform-plan: $(GOOGLE_CLOUD_CREDENTIALS_JSON_FILE)
	$(TERRAFORM) plan -out=$(TERRAFORM_ROOT_MODULE)/.planed_terraform
.PHONY: terraform-plan

terraform-unlock: $(GOOGLE_CLOUD_CREDENTIALS_JSON_FILE)
	@$(TERRAFORM) force-unlock $(LOCK_ID)
.PHONY: terraform-unlock

terraform-providers: $(GOOGLE_CLOUD_CREDENTIALS_JSON_FILE)
	@$(TERRAFORM) providers -v
.PHONY: terraform-providers

terraform-validate: $(GOOGLE_CLOUD_CREDENTIALS_JSON_FILE)
	@$(TERRAFORM) validate
.PHONY: terraform-validate

terraform-refresh: $(GOOGLE_CLOUD_CREDENTIALS_JSON_FILE)
	@$(TERRAFORM) refresh
.PHONY: terraform-refresh

terraform-apply-auto-approve: $(GOOGLE_CLOUD_CREDENTIALS_JSON_FILE)
	@$(TERRAFORM) apply -auto-approve $(TERRAFORM_ROOT_MODULE)/.planed_terraform
.PHONY: terraform-apply-auto-approve

terraform-output-json: $(GOOGLE_CLOUD_CREDENTIALS_JSON_FILE)
	@$(TERRAFORM) output -json
.PHONY: terraform-output-json

terraform-destroy: $(GOOGLE_CLOUD_CREDENTIALS_JSON_FILE)
	@$(TERRAFORM) destroy
.PHONY: terraform-destroy

terraform-state-backup: $(GOOGLE_CLOUD_CREDENTIALS_JSON_FILE)
	@$(TERRAFORM) state pull > $(TERRAFORM_ROOT_MODULE)/backup.tfstate
.PHONY: terraform-state-backup

terraform-output-github-actions-private-key:
	@$(TERRAFORM) output -json | jq '.github_actions_private_key.value' | sed 's/\"//g' | base64 --decode 
.PHONY: terraform-output-github-actions-private-key

terraform-output-firebase-android-config-json:
	@@$(TERRAFORM) output firebase_android_config_json | sed -e '1d' -e '$$d' -e '/^$$/d'
.PHONY: terraform-output-firebase-android-config-json

terraform-output-firebase-ios-config-plist:
	@$(TERRAFORM) output firebase_ios_config_plist | sed -e '1d' -e '$$d' -e '/^$$/d'
.PHONY: terraform-output-firebase-ios-config-plist