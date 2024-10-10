-include infra/gcloud/gcloud.mk
-include infra/github/github.mk

ENV_TERRAFORM_ROOT_MODULE = $(CURDIR)/infra

ENV ?= dev
ENV_TERRAFORM_ROOT_MODULE ?= $(CURDIR)/infra/environments/$(ENV)
CREATE_SECRET ?= false

TERRAFORM = \
	TF_VAR_GOOGLE_CLOUD_WEB_IDP_GOOGLE_OAUTH_SECRET=$(UTRADE_GOOGLE_CLOUD_WEB_IDP_GOOGLE_OAUTH_SECRET) \
	TF_VAR_application_backend_image=$(BACKEND_IMAGE) \
	TF_VAR_create_secret=$(CREATE_SECRET) \
	terraform -chdir=$(ENV_TERRAFORM_ROOT_MODULE)

terraform-init: $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) init --upgrade
.PHONY: terraform-init

terraform-import: $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)
# @$(TERRAFORM) import module.infra.module.secrets.google_identity_platform_default_supported_idp_config.google[0] projects/$(GOOGLE_CLOUD_PROJECT_ID)/defaultSupportedIdpConfigs/google.com
	@$(TERRAFORM) import module.infra.google_identity_platform_config.utrade $(GOOGLE_CLOUD_PROJECT_ID)
# @$(TERRAFORM) import module.infra.google_secret_manager_secret.firebase_adminsdk_service_account projects/402960374845/secrets/firebase-adminsdk-serviceaccount
# @$(TERRAFORM) import module.infra.google_firebase_database_instance.utrade $(GOOGLE_CLOUD_PROJECT_ID)/$(REGION)/$(GOOGLE_CLOUD_PROJECT_ID)-default-rtdb
# @$(TERRAFORM) import module.infra.google_firebase_database_instance.utrade projects/$(GOOGLE_CLOUD_PROJECT_ID)/locations/$(REGION)/instances/$(GOOGLE_CLOUD_PROJECT_ID)-default-rtdb
# @$(TERRAFORM) import google_service_account.firebase_admin projects/$(GOOGLE_CLOUD_PROJECT_ID)/firebase-adminsdk-vxdj8@$(GOOGLE_CLOUD_PROJECT_ID).iam.gserviceaccount.com
# @$(TERRAFORM) import module.infra.google_cloudfunctions_function.utrade_auth_before_sign_in projects/utrade-taxi-run-0/locations/us-central1/functions/utrade-us-central1-identity-platform
# @$(TERRAFORM) import module.infra.module.secrets.google_secret_manager_secret_version.google_idp_secret_version[0] projects/402960374845/secrets/idp_google_secret_id/versions/1
# @$(TERRAFORM) import module.infra.google_apikeys_key.web_google_maps_api_key projects/402960374845/locations/global/keys/web-google-maps-api-key
# @$(TERRAFORM) import module.infra.google_apikeys_key.google_maps_android_api_key projects/402960374845/locations/global/keys/mobile-google-maps-api-key-android
# @$(TERRAFORM) import module.infra.google_apikeys_key.google_maps_ios_api_key projects/402960374845/locations/global/keys/mobile-google-maps-api-key-ios
.PHONY: terraform-import

FIREBASE_IOS_CONFIG_PLIST = $(CURDIR)/infra/GoogleService-Info.plist

$(FIREBASE_IOS_CONFIG_PLIST): 
	@$(MAKE) firebase-ios-config-plist

firebase-ios-config-plist:
	@echo Creating file "'$(FIREBASE_IOS_CONFIG_PLIST)'"
	@$(TERRAFORM) output firebase_ios_config_plist | \
		sed -e '1d' -e '$$d' -e '/^$$/d' > $(FIREBASE_IOS_CONFIG_PLIST)
.PHONY: firebase-ios-config-plist

FIREBASE_ANDROID_CONFIG_JSON = $(CURDIR)/infra/google-services.json

$(FIREBASE_ANDROID_CONFIG_JSON):
	@$(MAKE) firebase-android-config-json

firebase-android-config-json:
	@echo Creating file "'$(FIREBASE_ANDROID_CONFIG_JSON)'"
	@$(TERRAFORM) output firebase_android_config_json | \
		sed -e '1d' -e '$$d' -e '/^$$/d' > $(FIREBASE_ANDROID_CONFIG_JSON)
.PHONY: firebase-android-config-json

terraform-state-rm: $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) state rm module.infra.google_firebase_database_instance.utrade
.PHONY: terraform-state-rm

terraform-state-list: $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) state list
.PHONY: terraform-state-list

BACKEND_TF = module.infra.google_cloud_run_service.application_backend

TF_STATE_ITEMS = \
	google_project.utrade \
	google_storage_bucket.bucket_tf_state \
	module.infra.data.archive_file.utrade_auth_func_src \
	module.infra.data.google_firebase_android_app.android_sha \
	module.infra.data.google_firebase_android_app_config.android_config \
	module.infra.data.google_firebase_apple_app_config.ios_config \
	module.infra.google_artifact_registry_repository.public_repo \
	module.infra.google_artifact_registry_repository.utrade \
	module.infra.google_artifact_registry_repository_iam_member.github_actions_private_repo_read_member \
	module.infra.google_artifact_registry_repository_iam_member.github_actions_private_repo_write_member \
	module.infra.google_artifact_registry_repository_iam_member.github_actions_public_repo_write_member \
	module.infra.google_artifact_registry_repository_iam_member.public_read \
	$(BACKEND_TF) \
	module.infra.google_cloudfunctions_function.utrade_auth_before_create \
	module.infra.google_cloudfunctions_function.utrade_auth_before_sign_in \
	module.infra.google_cloudfunctions_function_iam_member.auth_before_create \
	module.infra.google_cloudfunctions_function_iam_member.auth_before_sign_in \
	module.infra.google_firebase_android_app.android_app \
	module.infra.google_firebase_apple_app.ios_app \
	module.infra.google_firebase_database_instance.utrade \
	module.infra.google_firebase_project.utrade \
	module.infra.google_firebase_web_app.utrade \
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
	module.infra.google_secret_manager_secret.service_account_key \
	module.infra.google_secret_manager_secret_version.firebase_admin_secret_version \
	module.infra.google_service_account.firebase_admin \
	module.infra.google_service_account.github_actions \
	module.infra.google_service_account_key.firebase_admin_key \
	module.infra.google_service_account_key.github_actions_key \
	module.infra.google_storage_bucket.bucket_gcf_source \
	module.infra.google_storage_bucket_object.utrade_auth \
	module.infra.null_resource.docker_auth \
	module.infra.null_resource.docker_auth_public \
	module.infra.module.cdn.google_compute_backend_bucket.public_cdn \
	module.infra.module.cdn.google_compute_global_address.public_cdn \
	module.infra.module.cdn.google_compute_global_forwarding_rule.public_cdn \
	module.infra.module.cdn.google_compute_target_http_proxy.public_cdn \
	module.infra.module.cdn.google_compute_url_map.url_map \
	module.infra.module.cdn.google_storage_bucket.public_images \
	module.infra.module.cdn.google_storage_bucket_iam_binding.web_public_image \
	module.infra.module.cdn.google_storage_bucket_object.public_web_background_image \
	module.infra.google_apikeys_key.google_maps_android_api_key \
	module.infra.google_apikeys_key.google_maps_ios_api_key \
	module.infra.google_apikeys_key.web_google_maps_api_key[0] \
	module.infra.google_secret_manager_secret.firebase_config \
	module.infra.google_secret_manager_secret.google_idp_secret[0] \
	module.infra.google_secret_manager_secret.web_google_maps_api_key[0] \
	module.infra.google_secret_manager_secret_version.firebase_config_version \
	module.infra.google_secret_manager_secret_version.web_google_maps_api_key_version[0] \
	module.infra.module.secrets.google_identity_platform_default_supported_idp_config.google[0] \
	module.infra.module.secrets.google_secret_manager_secret_version.google_idp_secret_version[0]

$(TF_STATE_ITEMS:%=%-show): $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) state show $(@:%-show=%)
.PHONY: $(TF_STATE_ITEMS:%=%-show)

$(TF_STATE_ITEMS:%=%-taint): $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) taint $(@:%-taint=%)
.PHONY: $(TF_STATE_ITEMS:%=%-taint)

terraform-taint-backend: $(BACKEND_TF)-taint
.PHONY: terraform-taint-backend

terraform-state-show-all : $(TF_STATE_ITEMS:%=%-show)
.PHONY: terraform-state-show

terraform-state-show: $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)
	$(TERRAFORM) state show module.infra.google_firebase_database_instance.utrade
.PHONY: terraform-state-show

terraform-upgrade: $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) init -upgrade
.PHONY: terraform-upgrade

terraform-plan: $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) plan -out=$(ENV_TERRAFORM_ROOT_MODULE)/.planed_terraform
.PHONY: terraform-plan

terraform-unlock: $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) force-unlock $(LOCK_ID)
.PHONY: terraform-unlock

terraform-providers: $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) providers -v
.PHONY: terraform-providers

terraform-validate: $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) validate
.PHONY: terraform-validate

terraform-refresh: $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) refresh
.PHONY: terraform-refresh

terraform-apply-auto-approve: $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) apply -auto-approve $(ENV_TERRAFORM_ROOT_MODULE)/.planed_terraform
.PHONY: terraform-apply-auto-approve

terraform-output: $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) output -json
.PHONY: terraform-output

terraform-destroy: $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) destroy
.PHONY: terraform-destroy

terraform-state-backup: $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) state pull > $(CURDIR)/gcloud/backup.tfstate
.PHONY: terraform-state-backup
