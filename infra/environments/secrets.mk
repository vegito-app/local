TERRAFORM_SECRETS_ROOT_MODULE = $(CURDIR)/infra/environments/$(INFRA_ENV)/secrets

GOOGLE_IDP_OAUTH_KEY=google-idp-oauth-key
GOOGLE_IDP_OAUTH_CLIENT_ID=google-idp-oauth-client-id

SECRETS_TERRAFORM = \
	TF_VAR_google_credentials_file=$(GOOGLE_APPLICATION_CREDENTIALS) \
	TF_VAR_google_idp_oauth_key_secret_id=$(GOOGLE_IDP_OAUTH_KEY) \
	TF_VAR_google_idp_oauth_client_id_secret_id=$(GOOGLE_IDP_OAUTH_CLIENT_ID) \
	terraform -chdir=$(TERRAFORM_SECRETS_ROOT_MODULE)

terraform-secrets-init: $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(SECRETS_TERRAFORM) init --upgrade
.PHONY: terraform-secrets-init

terraform-secrets-migrate-state: $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(SECRETS_TERRAFORM) init --migrate-state
.PHONY: terraform-secrets-migrate-state

terraform-secrets-state-rm: $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(SECRETS_TERRAFORM) state rm module.infra.google_firebase_database_instance.utrade
.PHONY: terraform-secrets-state-rm

terraform-secrets-state-list: $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(SECRETS_TERRAFORM) state list
.PHONY: terraform-secrets-state-list

SECRETS_TF_STATE_ITEMS =  \
	google_secret_manager_secret.google_idp_secret \
	google_secret_manager_secret_version.google_idp_secret_version

$(SECRETS_TF_STATE_ITEMS:%=%-show): $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(SECRETS_TERRAFORM) state show $(@:%-show=%)
.PHONY: $(SECRETS_TF_STATE_ITEMS:%=%-show)

$(SECRETS_TF_STATE_ITEMS:%=%-taint): $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(SECRETS_TERRAFORM) taint $(@:%-taint=%)
.PHONY: $(SECRETS_TF_STATE_ITEMS:%=%-taint)

terraform-secrets-state-show-all : $(SECRETS_TF_STATE_ITEMS:%=%-show)
.PHONY: terraform-secrets-state-show-all

terraform-secrets-upgrade: $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(SECRETS_TERRAFORM) init -upgrade
.PHONY: terraform-secrets-upgrade

terraform-secrets-reconfigure: $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(SECRETS_TERRAFORM) init -reconfigure
.PHONY: terraform-secrets-reconfigure

terraform-secrets-plan: $(GOOGLE_APPLICATION_CREDENTIALS)
	$(SECRETS_TERRAFORM) plan -out=$(TERRAFORM_SECRETS_ROOT_MODULE)/.planed_terraform
.PHONY: terraform-secrets-plan

terraform-secrets-unlock: $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(SECRETS_TERRAFORM) force-unlock $(LOCK_ID)
.PHONY: terraform-secrets-unlock

terraform-secrets-providers: $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(SECRETS_TERRAFORM) providers -v
.PHONY: terraform-secrets-providers

terraform-secrets-validate: $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(SECRETS_TERRAFORM) validate
.PHONY: terraform-secrets-validate

terraform-secrets-refresh: $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(SECRETS_TERRAFORM) refresh
.PHONY: terraform-secrets-refresh

terraform-secrets-apply-auto-approve: $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(SECRETS_TERRAFORM) apply -auto-approve $(TERRAFORM_SECRETS_ROOT_MODULE)/.planed_terraform
.PHONY: terraform-secrets-apply-auto-approve

terraform-secrets-output: $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(SECRETS_TERRAFORM) output -json
.PHONY: terraform-secrets-output

terraform-secrets-destroy: $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(SECRETS_TERRAFORM) destroy
.PHONY: terraform-secrets-destroy

terraform-secrets-state-backup: $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(SECRETS_TERRAFORM) state pull > $(CURDIR)/infra/secrets/backup.tfstate
.PHONY: terraform-secrets-state-backup