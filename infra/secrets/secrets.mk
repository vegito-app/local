TERRAFORM_SECRETS_ROOT_MODULE ?= $(CURDIR)/infra/secrets

SECRETS_TERRAFORM = \
	TF_VAR_GOOGLE_IDP_OAUTH_SECRET=$(GOOGLE_IDP_OAUTH_SECRET) \
	TF_VAR_google_credentials_file=$(GOOGLE_CLOUD_CREDENTIALS_JSON_FILE) \
	TF_VAR_google_idp_oauth_key_secret_id=$(INFRA_GOOGLE_IDP_OAUTH_KEY) \
	TF_VAR_google_idp_oauth_client_id_secret_id=$(INFRA_GOOGLE_IDP_OAUTH_CLIENT_ID) \
	terraform -chdir=$(TERRAFORM_SECRETS_ROOT_MODULE)

terraform-secrets-init: $(GOOGLE_CLOUD_CREDENTIALS_JSON_FILE)
	@$(SECRETS_TERRAFORM) init --upgrade
.PHONY: terraform-secrets-init

terraform-secrets-migrate-state: $(GOOGLE_CLOUD_CREDENTIALS_JSON_FILE)
	@$(SECRETS_TERRAFORM) init --migrate-state
.PHONY: terraform-secrets-migrate-state

terraform-secrets-import: $(GOOGLE_CLOUD_CREDENTIALS_JSON_FILE)
# @$(SECRETS_TERRAFORM) import google_secret_manager_secret_version.google_idp_oauth_client_id_version projects/$(GOOGLE_CLOUD_PROJECT_NUMBER)/secrets/prod-google-idp-oauth-client-id/versions/1
# @$(SECRETS_TERRAFORM) import google_secret_manager_secret_version.google_idp_oauth_key_version projects/$(GOOGLE_CLOUD_PROJECT_NUMBER)/secrets/prod-google-idp-oauth-key/versions/1
# @$(SECRETS_TERRAFORM) import google_secret_manager_secret.google_idp_oauth_client_id projects/$(GOOGLE_CLOUD_PROJECT_NUMBER)/secrets/prod-google-idp-oauth-client-id
# @$(SECRETS_TERRAFORM) import google_secret_manager_secret.google_idp_oauth_key projects/$(GOOGLE_CLOUD_PROJECT_NUMBER)/secrets/prod-google-idp-oauth-key
.PHONY: terraform-secrets-import

terraform-secrets-state-rm: $(GOOGLE_CLOUD_CREDENTIALS_JSON_FILE)
	@$(SECRETS_TERRAFORM) state rm module.infra.google_firebase_database_instance.utrade
.PHONY: terraform-secrets-state-rm

terraform-secrets-state-list: $(GOOGLE_CLOUD_CREDENTIALS_JSON_FILE)
	@$(SECRETS_TERRAFORM) state list
.PHONY: terraform-secrets-state-list

SECRETS_TF_STATE_ITEMS =  \
	google_secret_manager_secret.google_idp_secret \
	google_identity_platform_default_supported_idp_config.google \
	google_secret_manager_secret_version.google_idp_secret_version

$(SECRETS_TF_STATE_ITEMS:%=%-show): $(GOOGLE_CLOUD_CREDENTIALS_JSON_FILE)
	@$(SECRETS_TERRAFORM) state show $(@:%-show=%)
.PHONY: $(SECRETS_TF_STATE_ITEMS:%=%-show)

$(SECRETS_TF_STATE_ITEMS:%=%-taint): $(GOOGLE_CLOUD_CREDENTIALS_JSON_FILE)
	@$(SECRETS_TERRAFORM) taint $(@:%-taint=%)
.PHONY: $(SECRETS_TF_STATE_ITEMS:%=%-taint)

terraform-secrets-state-show-all : $(SECRETS_TF_STATE_ITEMS:%=%-show)
.PHONY: terraform-secrets-state-show

terraform-secrets-upgrade: $(GOOGLE_CLOUD_CREDENTIALS_JSON_FILE)
	@$(SECRETS_TERRAFORM) init -upgrade
.PHONY: terraform-secrets-upgrade

terraform-secrets-reconfigure: $(GOOGLE_CLOUD_CREDENTIALS_JSON_FILE)
	@$(SECRETS_TERRAFORM) init -reconfigure
.PHONY: terraform-secrets-reconfigure

terraform-secrets-plan: $(GOOGLE_CLOUD_CREDENTIALS_JSON_FILE)
	$(SECRETS_TERRAFORM) plan -out=$(TERRAFORM_SECRETS_ROOT_MODULE)/.planed_terraform
.PHONY: terraform-secrets-plan

terraform-secrets-unlock: $(GOOGLE_CLOUD_CREDENTIALS_JSON_FILE)
	@$(SECRETS_TERRAFORM) force-unlock $(LOCK_ID)
.PHONY: terraform-secrets-unlock

terraform-secrets-providers: $(GOOGLE_CLOUD_CREDENTIALS_JSON_FILE)
	@$(SECRETS_TERRAFORM) providers -v
.PHONY: terraform-secrets-providers

terraform-secrets-validate: $(GOOGLE_CLOUD_CREDENTIALS_JSON_FILE)
	@$(SECRETS_TERRAFORM) validate
.PHONY: terraform-secrets-validate

terraform-secrets-refresh: $(GOOGLE_CLOUD_CREDENTIALS_JSON_FILE)
	@$(SECRETS_TERRAFORM) refresh
.PHONY: terraform-secrets-refresh

terraform-secrets-apply-auto-approve: $(GOOGLE_CLOUD_CREDENTIALS_JSON_FILE)
	@$(SECRETS_TERRAFORM) apply -auto-approve $(TERRAFORM_SECRETS_ROOT_MODULE)/.planed_terraform
.PHONY: terraform-secrets-apply-auto-approve

terraform-secrets-output: $(GOOGLE_CLOUD_CREDENTIALS_JSON_FILE)
	@$(SECRETS_TERRAFORM) output -json
.PHONY: terraform-secrets-output

terraform-secrets-destroy: $(GOOGLE_CLOUD_CREDENTIALS_JSON_FILE)
	@$(SECRETS_TERRAFORM) destroy
.PHONY: terraform-secrets-destroy

terraform-secrets-state-backup: $(GOOGLE_CLOUD_CREDENTIALS_JSON_FILE)
	@$(SECRETS_TERRAFORM) state pull > $(CURDIR)/infra/secrets/backup.tfstate
.PHONY: terraform-secrets-state-backup