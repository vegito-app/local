TERRAFORM_PROJECT ?= $(CURDIR)/infra/environments/$(INFRA_ENV)

TERRAFORM = cd $(TERRAFORM_PROJECT) && \
	TF_VAR_application_backend_image=$(APPLICATION_BACKEND_IMAGE) \
	TF_VAR_google_idp_oauth_key_secret_id=$(GOOGLE_IDP_OAUTH_KEY) \
	TF_VAR_google_idp_oauth_client_id_secret_id=$(GOOGLE_IDP_OAUTH_CLIENT_ID) \
	TF_VAR_helm_vault_chart_version=$(HELM_VAULT_CHART_VERSION) \
		terraform

terraform-init: $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) init --upgrade
.PHONY: terraform-init

terraform-import : $(GOOGLE_APPLICATION_CREDENTIALS)
	# $(TERRAFORM) import module.gcloud.google_identity_platform_default_supported_idp_config.google "projects/moov-438615/defaultSupportedIdpConfigs/google"
	# $(TERRAFORM) import module.kubernetes.google_kms_key_ring.vault "projects/moov-438615/locations/global/keyRings/vault-keyring"
	# $(TERRAFORM) import module.kubernetes.google_kms_crypto_key.vault "projects/moov-438615/locations/global/keyRings/vault-keyring/cryptoKeys/vault-key"
	# $(TERRAFORM) import google_apikeys_key.user_google_maps_api_key[\"davidberich@gmail.com\"] projects/$(DEV_GOOGLE_CLOUD_PROJECT_ID)/locations/global/keys/david-berichon-googlemaps-web-api-key
.PHONY: terraform-import 

# Use this target to help updating the bellow TF_STATE_ITEMS list manually.
terraform-state-list: $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) state list
.PHONY: terraform-state-list

# This list is used to provide generic terraform targets 
TF_STATE_ITEMS = \
module.staging_root_admin_members.google_project_iam_member.roles["1"]  \
module.staging_root_admin_members.google_project_iam_member.roles["0"]  \
module.staging_users.google_service_account.user_service_account["davidberich@gmail.com"] \
  module.dev_members.google_project_iam_custom_role.k8s_rbac_role \
  module.gcloud.data.archive_file.auth_func_src \
  module.gcloud.data.google_firebase_android_app.android_sha \
  module.gcloud.data.google_firebase_android_app_config.android_config \
  module.gcloud.data.google_firebase_apple_app_config.ios_config \
  module.gcloud.data.google_firebase_web_app_config.web_app_config \
  module.gcloud.data.google_project.project \
  data.google_service_account.dev_user_service_account["davidberich@gmail.com"] \
  module.prod_users.google_service_account.user_service_account["davidberich@gmail.com"] \
  module.dev_users.google_service_account_iam_member.key_admin["davidberich@gmail.com"]

$(TF_STATE_ITEMS:%=%-show): $(GOOGLE_APPLICATION_CREDENTIALS)
	$(TERRAFORM) state show '$(@:%-show=%)'
.PHONY: $(TF_STATE_ITEMS:%=%-show)

$(TF_STATE_ITEMS:%=%-rm): $(GOOGLE_APPLICATION_CREDENTIALS)
	$(TERRAFORM) state rm '$(@:%-rm=%)'
.PHONY: $(TF_STATE_ITEMS:%=%-rm)

$(TF_STATE_ITEMS:%=%-apply): $(GOOGLE_APPLICATION_CREDENTIALS)
	$(TERRAFORM) apply -target='$(@:%-apply=%)'
.PHONY: $(TF_STATE_ITEMS:%=%-apply)

$(TF_STATE_ITEMS:%=%-destroy): $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) destroy -target='$(@:%-destroy=%)'
.PHONY: $(TF_STATE_ITEMS:%=%-destroy)

$(TF_STATE_ITEMS:%=%-taint): $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) taint '$(@:%-taint=%)'
.PHONY: $(TF_STATE_ITEMS:%=%-taint)

$(TF_STATE_ITEMS:%=%-untaint): $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) untaint '$(@:%-untaint=%)'
.PHONY: $(TF_STATE_ITEMS:%=%-untaint)

terraform-taint-backend: module.gcloud.google_cloud_run_service.application_backend-taint
.PHONY: terraform-taint-backend

terraform-state-show-all : $(TF_STATE_ITEMS:%=%-show)
.PHONY: terraform-state-show-all

TERRAFORM_PROJECTS := \
	infra/environments/prod \
	infra/environments/prod/vault \
	infra/environments/staging \
	infra/environments/dev 

$(TERRAFORM_PROJECTS:%=terraform-%-project-upgrade):
	cd $(@:terraform-%-project-upgrade=%) && rm -rf .terraform .terraform.lock.hcl
	@TERRAFORM_PROJECT=$(CURDIR)/$(@:terraform-%-project-upgrade=%) $(MAKE) terraform-upgrade
.PHONY: $(TERRAFORM_PROJECTS:%=terraform-%-project-upgrade)

terraform-upgrade-all: $(TERRAFORM_PROJECTS:%=terraform-%-project-upgrade)
.PHONY: terraform-upgrade-all

terraform-upgrade: $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) init -upgrade
.PHONY: terraform-upgrade

terraform-reconfigure: $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) init -reconfigure
.PHONY: terraform-reconfigure

terraform-plan: $(GOOGLE_APPLICATION_CREDENTIALS)
	$(TERRAFORM) plan -out=$(TERRAFORM_PROJECT)/.planed_terraform
.PHONY: terraform-plan

terraform-unlock: $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) force-unlock $(LOCK_ID)
.PHONY: terraform-unlock

terraform-providers: $(GOOGLE_APPLICATION_CREDENTIALS)
	$(TERRAFORM) providers -v
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
	$(TERRAFORM) apply -auto-approve # $(TERRAFORM_PROJECT)/.planed_terraform
.PHONY: terraform-apply-auto-approve

terraform-output-json: $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) output -json
.PHONY: terraform-output-json

terraform-destroy: $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) destroy
.PHONY: terraform-destroy

terraform-state-backup: $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) state pull > $(TERRAFORM_PROJECT)/backup.tfstate
.PHONY: terraform-state-backup

terraform-output-github-actions-private-key:
	@$(TERRAFORM) output -json | jq '.github_actions_private_key.value' | sed 's/\"//g' | base64 --decode 
.PHONY: terraform-output-github-actions-private-key

$(APPLICATION_MOBILE_FIREBASE_ANDROID_CONFIG_JSON): terraform-output-firebase-android-config-json

$(INFRA_FIREBASE_ANDROID_CONFIG_JSON): terraform-output-firebase-android-config-json

terraform-output-firebase-android-config-json:
	@echo Creating Android configuration for "'$(INFRA_ENV)'": "'$(INFRA_FIREBASE_ANDROID_CONFIG_JSON)'"
	@$(TERRAFORM) output firebase_android_config_json | sed -e '1d' -e '$$d' -e '/^$$/d' > $(INFRA_FIREBASE_ANDROID_CONFIG_JSON)
.PHONY: terraform-output-firebase-android-config-json

$(INFRA_FIREBASE_IOS_CONFIG_PLIST): terraform-output-firebase-ios-config-plist

terraform-output-firebase-ios-config-plist: 
	@echo Creating iOS configuration for "'$(INFRA_ENV)'": "'$(INFRA_FIREBASE_IOS_CONFIG_PLIST)'"
	@$(TERRAFORM) output firebase_ios_config_plist | sed -e '1d' -e '$$d' -e '/^$$/d' > $(INFRA_FIREBASE_IOS_CONFIG_PLIST)
.PHONY: terraform-output-firebase-ios-config-plist

terraform-console:
	$(TERRAFORM) console
.PHONY: terraform-console
