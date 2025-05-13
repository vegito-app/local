VAULT_TERRAFORM_PROJECT = $(CURDIR)/infra/environments/$(INFRA_ENV)/vault

PROD_VAULT_HELM_VAULT_TOKEN = $(CURDIR)/.vault_$(INFRA_ENV)_token

# Use following targets to prepare before local connection 
# to production cluster using kubctl port-forward:
# - make production-vault-kubernetes-cluster-get-credentials
# - make production-vault-kubectl-port-forward
PROD_VAULT_TERRAFORM = \
	TF_VAR_vault_addr=http://localhost:8210 \
	 terraform -chdir=$(VAULT_TERRAFORM_PROJECT)

	# VAULT_TOKEN=$(shell cat $(PROD_VAULT_HELM_VAULT_TOKEN)) \

# TF_REATTACH_PROVIDERS={"hashicorp/vault":{"Protocol":"grpc","ProtocolVersion":5,"Pid":29973,"Test":true,"Addr":{"Network":"unix","String":"/tmp/plugin646721991"}}}

$(PROD_VAULT_HELM_VAULT_TOKEN): 
	@$(MAKE) production-vault-login

production-vault-terraform-state-list: $(GOOGLE_APPLICATION_CREDENTIALS)
	@echo "📦 Listing Vault Terraform state items..."
	@$(PROD_VAULT_TERRAFORM) state list
.PHONY: production-vault-terraform-state-list

production-vault-terraform-init: $(GOOGLE_APPLICATION_CREDENTIALS)
	@echo "🛠️ Initializing Vault Terraform..."
	@$(PROD_VAULT_TERRAFORM) init -lockfile=readonly
.PHONY: production-vault-terraform-init

production-vault-terraform-upgrade: $(GOOGLE_APPLICATION_CREDENTIALS)
	@echo "📈 Upgrading Vault Terraform..."
	@$(PROD_VAULT_TERRAFORM) init -upgrade
.PHONY: production-vault-terraform-upgrade

production-vault-terraform-reconfigure: $(GOOGLE_APPLICATION_CREDENTIALS)
	@echo "🧯 Reconfiguring Vault Terraform..."
	@$(PROD_VAULT_TERRAFORM) init -reconfigure
.PHONY: production-vault-terraform-reconfigure

production-vault-terraform-plan: $(GOOGLE_APPLICATION_CREDENTIALS)
	@echo "🧾 Planning Vault Terraform changes..."
	@$(PROD_VAULT_TERRAFORM) plan -out=$(VAULT_TERRAFORM_PROJECT)/.planed_terraform
.PHONY: production-vault-terraform-plan

production-vault-terraform-unlock: $(GOOGLE_APPLICATION_CREDENTIALS)
	@echo "🔐 Unlocking Vault Terraform state..."
	@$(PROD_VAULT_TERRAFORM) force-unlock $(LOCK_ID)
.PHONY: production-vault-terraform-unlock

production-vault-terraform-providers: $(GOOGLE_APPLICATION_CREDENTIALS)
	@echo "📦 Listing Vault Terraform providers..."
	@$(PROD_VAULT_TERRAFORM) providers -v
.PHONY: production-vault-terraform-providers

production-vault-terraform-validate: $(GOOGLE_APPLICATION_CREDENTIALS)
	@echo "🧪 Validating Vault Terraform configuration..."
	@$(PROD_VAULT_TERRAFORM) validate
.PHONY: production-vault-terraform-validate

production-vault-terraform-refresh: $(GOOGLE_APPLICATION_CREDENTIALS)
	@echo "🔄 Refreshing Vault Terraform state..."
	@$(PROD_VAULT_TERRAFORM) refresh
.PHONY: production-vault-terraform-refresh

production-vault-terraform-migrate-state: $(GOOGLE_APPLICATION_CREDENTIALS)
	@echo "🧳 Migrating Vault Terraform state..."
	@$(PROD_VAULT_TERRAFORM) init --migrate-state
.PHONY: production-vault-terraform-migrate-state

production-vault-login:
	@echo "🪪 Retrieve a short live authentication token to Vault production cluster from local console..."
	@$(VAULT_TERRAFORM_PROJECT)/vault-login-local.sh \
	|| bash -c "\
  echo Vault login failed with \'INFRA_ENV=$(INFRA_ENV)\'. ; \
  echo Please check or use \'export INFRA_ENV=prod\'. ; \
  exit -1"
.PHONY: production-vault-login

production-vault-terraform-apply-auto-approve: $(GOOGLE_APPLICATION_CREDENTIALS) $(PROD_VAULT_HELM_VAULT_TOKEN)
	@echo "🚀 Applying Vault Terraform changes with auto-approve..."
	@$(PROD_VAULT_TERRAFORM) apply -auto-approve
.PHONY: production-vault-terraform-apply-auto-approve

production-vault-terraform-output-json: $(GOOGLE_APPLICATION_CREDENTIALS)
	@echo "📤 Outputting Vault Terraform state in JSON..."
	@$(PROD_VAULT_TERRAFORM) output -json
.PHONY: production-vault-terraform-output-json

production-vault-terraform-destroy: $(GOOGLE_APPLICATION_CREDENTIALS)
	@echo "🔥 Destroying Vault Terraform-managed infrastructure..."
	@$(PROD_VAULT_TERRAFORM) destroy
.PHONY: production-vault-terraform-destroy

production-vault-terraform-state-backup: $(GOOGLE_APPLICATION_CREDENTIALS)
	@echo "💾 Backing up Vault Terraform state..."
	@$(PROD_VAULT_TERRAFORM) state pull > $(VAULT_TERRAFORM_PROJECT)/backup.tfstate
.PHONY: ptod-vault-terraform-state-backup
