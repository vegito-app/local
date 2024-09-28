-include infra/gcloud/gcloud.mk
-include infra/github/github.mk

TF_VAR_FIREBASE_API_KEY=$(UTRADE_FIREBASE_API_KEY)
TF_VAR_FIREBASE_AUTH_DOMAIN=$(UTRADE_FIREBASE_AUTH_DOMAIN)
TF_VAR_FIREBASE_DATABASE_URL=$(UTRADE_FIREBASE_DATABASE_URL)
TF_VAR_FIREBASE_PROJECT_ID=$(UTRADE_FIREBASE_PROJECT_ID)
TF_VAR_FIREBASE_STORAGE_BUCKET=$(UTRADE_FIREBASE_STORAGE_BUCKET)
TF_VAR_FIREBASE_MESSAGING_SENDER_ID=$(UTRADE_FIREBASE_MESSAGING_SENDER_ID)
TF_VAR_FIREBASE_APP_ID=$(UTRADE_FIREBASE_APP_ID)

export

TERRAFORM = \
	TF_VAR_firebase_adminsdk_credentials=$$FIREBASE_ADMINSDK_CREDENTIALS \
	TF_VAR_google_cloud_idp_google_web_auth_secret=$(GOOGLE_CLOUD_WEB_IDP_GOOGLE_OAUTH_SECRET) \
	TF_VAR_application_image=$(BACKEND_IMAGE) \
	TF_VAR_create_secret=true \
	terraform -chdir=./infra

terraform-init: $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) init --upgrade
.PHONY: terraform-init

terraform-import: $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)
	# $(TERRAFORM) import module.infra.module.secrets.google_identity_platform_default_supported_idp_config.google[0] projects/$(PROJECT_ID)/defaultSupportedIdpConfigs/google.com
	# @$(TERRAFORM) import module.infra.google_identity_platform_config.utrade $(PROJECT_ID)
	# @$(TERRAFORM) import module.infra.google_secret_manager_secret.firebase_adminsdk_service_account projects/402960374845/secrets/firebase-adminsdk-serviceaccount
	# @$(TERRAFORM) import module.infra.google_firebase_database_instance.utrade $(PROJECT_ID)/$(REGION)/$(PROJECT_ID)-default-rtdb
	# @$(TERRAFORM) import module.infra.google_firebase_database_instance.utrade projects/$(PROJECT_ID)/locations/$(REGION)/instances/$(PROJECT_ID)-default-rtdb
	# @$(TERRAFORM) import google_service_account.firebase_admin projects/$(PROJECT_ID)/firebase-adminsdk-vxdj8@$(PROJECT_ID).iam.gserviceaccount.com
	# @$(TERRAFORM) import module.infra.google_cloudfunctions_function.utrade_auth_before_sign_in projects/utrade-taxi-run-0/locations/us-central1/functions/utrade-us-central1-identity-platform
	# @$(TERRAFORM) import module.infra.module.secrets.google_secret_manager_secret_version.google_idp_secret_version[0] projects/402960374845/secrets/idp_google_secret_id/versions/1
.PHONY: terraform-import

terraform-state-rm: $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) state rm module.infra.google_firebase_database_instance.utrade
.PHONY: terraform-state-rm

terraform-state-list: $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) state list
.PHONY: terraform-state-list

TF_STATE_ITEMS = \
  google_project.utrade \
  google_storage_bucket.bucket_tf_state \
  module.infra.data.archive_file.utrade_auth_func_src \
  module.infra.google_artifact_registry_repository.utrade \
  module.infra.google_cloud_run_service.utrade \
  module.infra.google_cloud_run_service_iam_member.allow_unauthenticated \
  module.infra.google_cloudfunctions_function.utrade_auth_before_create \
  module.infra.google_cloudfunctions_function.utrade_auth_before_sign_in \
  module.infra.google_cloudfunctions_function_iam_member.auth_before_create \
  module.infra.google_cloudfunctions_function_iam_member.auth_before_sign_in \
  module.infra.google_firebase_android_app.utrade \
  module.infra.google_firebase_apple_app.utrade \
  module.infra.google_firebase_database_instance.utrade \
  module.infra.google_firebase_project.utrade \
  module.infra.google_firebase_web_app.utrade \
  module.infra.google_identity_platform_config.utrade \
  module.infra.google_project_iam_custom_role.limited_service_user \
  module.infra.google_project_iam_member.firebase_admin_service_agent \
  module.infra.google_project_iam_member.firebase_token_creator \
  module.infra.google_project_service.utrade["cloudbilling.googleapis.com"] \
  module.infra.google_project_service.utrade["cloudbuild.googleapis.com"] \
  module.infra.google_project_service.utrade["cloudfunctions.googleapis.com"] \
  module.infra.google_project_service.utrade["cloudresourcemanager.googleapis.com"] \
  module.infra.google_project_service.utrade["compute.googleapis.com"] \
  module.infra.google_project_service.utrade["firebase.googleapis.com"] \
  module.infra.google_project_service.utrade["firebasedatabase.googleapis.com"] \
  module.infra.google_project_service.utrade["firestore.googleapis.com"] \
  module.infra.google_project_service.utrade["identitytoolkit.googleapis.com"] \
  module.infra.google_project_service.utrade["secretmanager.googleapis.com"] \
  module.infra.google_project_service.utrade["serviceusage.googleapis.com"] \
  module.infra.google_secret_manager_secret.service_account_key \
  module.infra.google_secret_manager_secret_version.firebase_admin_v1 \
  module.infra.google_service_account.firebase_admin \
  module.infra.google_service_account_key.firebase_admin_key \
  module.infra.google_storage_bucket.bucket_gcf_source \
  module.infra.google_storage_bucket_object.utrade_auth \
  module.infra.null_resource.docker_auth \
  module.secrets.google_identity_platform_default_supported_idp_config.google[0] \
  module.secrets.google_secret_manager_secret.firebase_config \
  module.secrets.google_secret_manager_secret.google_idp_secret[0] \
  module.secrets.google_secret_manager_secret.googlemaps_api_key \
  module.secrets.google_secret_manager_secret_version.firebase_config_version \
  module.secrets.google_secret_manager_secret_version.google_idp_secret_version[0] \
  module.secrets.google_secret_manager_secret_version.googlemaps_api_key_version \
  module.infra.module.cdn.google_compute_backend_bucket.public_cdn \
  module.infra.module.cdn.google_compute_global_address.public_cdn \
  module.infra.module.cdn.google_compute_global_forwarding_rule.public_cdn \
  module.infra.module.cdn.google_compute_target_http_proxy.public_cdn \
  module.infra.module.cdn.google_compute_url_map.url_map \
  module.infra.module.cdn.google_storage_bucket.public_images \
  module.infra.module.cdn.google_storage_bucket_iam_binding.web_public_image \
  module.infra.module.cdn.google_storage_bucket_object.public_web_background_image

$(TF_STATE_ITEMS:%=%-show): $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) state show $(@:%-show=%)
.PHONY: $(TF_STATE_ITEMS:%=%-show)

terraform-state-show-all : $(TF_STATE_ITEMS:%=%-show)
.PHONY: terraform-state-show

terraform-state-show: $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)
	$(TERRAFORM) state show module.infra.google_firebase_database_instance.utrade
.PHONY: terraform-state-show

terraform-upgrade: $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) init -upgrade
.PHONY: terraform-upgrade

terraform-plan: $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) plan
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
	@$(TERRAFORM) apply -auto-approve
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
