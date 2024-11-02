TERRAFORM_ROOT_MODULE ?= $(CURDIR)/infra/environments/$(INFRA_ENV)

# TF_VAR_google_credentials_file=$(GOOGLE_APPLICATION_CREDENTIALS) \
  
TERRAFORM = \
	TF_VAR_application_backend_image=$(APPLICATION_BACKEND_IMAGE) \
	TF_VAR_google_idp_oauth_key_secret_id=$(INFRA_GOOGLE_IDP_OAUTH_KEY) \
	TF_VAR_google_idp_oauth_client_id_secret_id=$(INFRA_GOOGLE_IDP_OAUTH_CLIENT_ID) \
		terraform -chdir=$(TERRAFORM_ROOT_MODULE)

terraform-init: $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) init --upgrade
.PHONY: terraform-init

# Use this target to help updating the bellow TF_STATE_ITEMS list manually.
terraform-state-list: $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) state list
.PHONY: terraform-state-list

# This list is used to provide generic terraform targets 
TF_STATE_ITEMS = \
  data.google_project.project \
  data.google_secret_manager_secret_version.google_idp_oauth_client_id \
  data.google_secret_manager_secret_version.google_idp_oauth_client_secret \
  google_identity_platform_default_supported_idp_config.google \
  google_project_service.google_services_default["cloudbilling.googleapis.com"] \
  google_project_service.google_services_default["cloudbuild.googleapis.com"] \
  google_project_service.google_services_default["cloudfunctions.googleapis.com"] \
  google_project_service.google_services_default["cloudresourcemanager.googleapis.com"] \
  google_project_service.google_services_default["compute.googleapis.com"] \
  google_project_service.google_services_default["iam.googleapis.com"] \
  google_project_service.google_services_default["secretmanager.googleapis.com"] \
  google_project_service.google_services_default["serviceusage.googleapis.com"] \
  google_service_account_iam_member.user_service_account_binding \
  google_storage_bucket.bucket_tf_state_eu_global \
  module.cdn.google_compute_backend_bucket.public_cdn \
  module.cdn.google_compute_global_address.public_cdn \
  module.cdn.google_compute_global_forwarding_rule.public_cdn \
  module.cdn.google_compute_target_http_proxy.public_cdn \
  module.cdn.google_compute_url_map.url_map \
  module.cdn.google_storage_bucket_iam_binding.web_public_image \
  module.cdn.google_storage_bucket_object.public_web_background_image \
  module.cdn.google_storage_bucket.public_images \
  module.gcloud.data.archive_file.auth_func_src \
  module.gcloud.data.google_firebase_android_app_config.android_config \
  module.gcloud.data.google_firebase_android_app.android_sha \
  module.gcloud.data.google_firebase_apple_app_config.ios_config \
  module.gcloud.data.google_firebase_web_app_config.web_app_config \
  module.gcloud.data.google_project.project \
  module.gcloud.google_apikeys_key.google_maps_android_api_key \
  module.gcloud.google_apikeys_key.google_maps_ios_api_key \
  module.gcloud.google_apikeys_key.web_google_maps_api_key \
  module.gcloud.google_artifact_registry_repository_iam_member.application_backend_repo_read_member \
  module.gcloud.google_artifact_registry_repository_iam_member.github_actions_private_repo_read_member \
  module.gcloud.google_artifact_registry_repository_iam_member.github_actions_private_repo_write_member \
  module.gcloud.google_artifact_registry_repository_iam_member.github_actions_public_repo_write_member \
  module.gcloud.google_artifact_registry_repository_iam_member.public_read \
  module.gcloud.google_artifact_registry_repository.private_docker_repository \
  module.gcloud.google_artifact_registry_repository.public_docker_repository \
  module.gcloud.google_cloud_run_service_iam_member.allow_unauthenticated \
  module.gcloud.google_cloud_run_service.application_backend \
  module.gcloud.google_cloudfunctions_function_iam_member.auth_before_create \
  module.gcloud.google_cloudfunctions_function_iam_member.auth_before_sign_in \
  module.gcloud.google_cloudfunctions_function.auth_before_create \
  module.gcloud.google_cloudfunctions_function.auth_before_sign_in \
  module.gcloud.google_firebase_android_app.android_app \
  module.gcloud.google_firebase_apple_app.ios_app \
  module.gcloud.google_firebase_database_instance.moov \
  module.gcloud.google_firebase_project.moov \
  module.gcloud.google_firebase_web_app.web_app \
  module.gcloud.google_firestore_database.production \
  module.gcloud.google_identity_platform_config.moov \
  module.gcloud.google_project_iam_custom_role.limited_service_user \
  module.gcloud.google_project_iam_member.firebase_admin_service_agent \
  module.gcloud.google_project_iam_member.firebase_token_creator \
  module.gcloud.google_project_service.application_backend_services["run.googleapis.com"] \
  module.gcloud.google_project_service.google_idp_services["identitytoolkit.googleapis.com"] \
  module.gcloud.google_project_service.google_maps_services["apikeys.googleapis.com"] \
  module.gcloud.google_project_service.google_services_firebase["firebase.googleapis.com"] \
  module.gcloud.google_project_service.google_services_firebase["firebasedatabase.googleapis.com"] \
  module.gcloud.google_project_service.google_services_firebase["firestore.googleapis.com"] \
  module.gcloud.google_project_service.google_services_maps["directions-backend.googleapis.com"] \
  module.gcloud.google_project_service.google_services_maps["geocoding-backend.googleapis.com"] \
  module.gcloud.google_project_service.google_services_maps["maps-backend.googleapis.com"] \
  module.gcloud.google_project_service.google_services_maps["maps-ios-backend.googleapis.com"] \
  module.gcloud.google_secret_manager_secret_iam_member.application_backend_firebase_adminsdk_secret_read \
  module.gcloud.google_secret_manager_secret_iam_member.application_backend_firebase_web_uiconfig_secret_read \
  module.gcloud.google_secret_manager_secret_iam_member.application_backend_wep_googlemaps_api_key_secret_read \
  module.gcloud.google_secret_manager_secret_iam_member.firebase_admin_service_account_secret_member \
  module.gcloud.google_secret_manager_secret_version.firebase_adminsdk_secret_version \
  module.gcloud.google_secret_manager_secret_version.firebase_config_web_version \
  module.gcloud.google_secret_manager_secret_version.web_google_maps_api_key_version \
  module.gcloud.google_secret_manager_secret.firebase_admin_service_account_secret \
  module.gcloud.google_secret_manager_secret.firebase_config_web \
  module.gcloud.google_secret_manager_secret.web_google_maps_api_key \
  module.gcloud.google_service_account_key.firebase_admin_service_account_key \
  module.gcloud.google_service_account_key.github_actions_key \
  module.gcloud.google_service_account.application_backend_cloud_run_sa \
  module.gcloud.google_service_account.firebase_admin_service_account \
  module.gcloud.google_service_account.github_actions \
  module.gcloud.google_storage_bucket_object.auth \
  module.gcloud.google_storage_bucket.bucket_gcf_source \
  module.gcloud.null_resource.docker_auth \
  module.gcloud.null_resource.docker_auth_public

$(TF_STATE_ITEMS:%=%-show): $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) state show $(@:%-show=%)
.PHONY: $(TF_STATE_ITEMS:%=%-show)

$(TF_STATE_ITEMS:%=%-rm): $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) state rm $(@:%-rm=%)
.PHONY: $(TF_STATE_ITEMS:%=%-rm)

$(TF_STATE_ITEMS:%=%-taint): $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) taint $(@:%-taint=%)
.PHONY: $(TF_STATE_ITEMS:%=%-taint)

terraform-taint-backend: module.gcloud.google_cloud_run_service.application_backend-taint
.PHONY: terraform-taint-backend

terraform-state-show-all : $(TF_STATE_ITEMS:%=%-show)
.PHONY: terraform-state-show

terraform-upgrade: $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) init -upgrade
.PHONY: terraform-upgrade

terraform-reconfigure: $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) init -reconfigure
.PHONY: terraform-reconfigure

terraform-plan: $(GOOGLE_APPLICATION_CREDENTIALS)
	$(TERRAFORM) plan -out=$(TERRAFORM_ROOT_MODULE)/.planed_terraform
.PHONY: terraform-plan

terraform-unlock: $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) force-unlock $(LOCK_ID)
.PHONY: terraform-unlock

terraform-providers: $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) providers -v
.PHONY: terraform-providers

terraform-validate: $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) validate
.PHONY: terraform-validate

terraform-refresh: $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) refresh
.PHONY: terraform-refresh

terraform-migrate-state: $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) init --migrate-state
.PHONY: terraform-migrate-state

terraform-apply-auto-approve: $(GOOGLE_APPLICATION_CREDENTIALS)
	$(TERRAFORM) apply -auto-approve $(TERRAFORM_ROOT_MODULE)/.planed_terraform
.PHONY: terraform-apply-auto-approve

terraform-output-json: $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) output -json
.PHONY: terraform-output-json

terraform-destroy: $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) destroy
.PHONY: terraform-destroy

terraform-state-backup: $(GOOGLE_APPLICATION_CREDENTIALS)
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