TERRAFORM_PROJECT ?= $(CURDIR)/infra/environments/$(INFRA_ENV)

TERRAFORM = \
	TF_VAR_application_backend_image=$(APPLICATION_BACKEND_IMAGE) \
	TF_VAR_google_idp_oauth_key_secret_id=$(GOOGLE_IDP_OAUTH_KEY) \
	TF_VAR_google_idp_oauth_client_id_secret_id=$(GOOGLE_IDP_OAUTH_CLIENT_ID) \
	TF_VAR_helm_vault_chart_version=$(HELM_VAULT_CHART_VERSION) \
		terraform -chdir=$(TERRAFORM_PROJECT) 
        # -var-file=$(TERRAFORM_PROJECT)/terraform.tfvars \

terraform-init: $(GOOGLE_APPLICATION_CREDENTIALS)
	@echo "🛠️ Initializing Terraform..."
	@$(TERRAFORM) init --upgrade
.PHONY: terraform-init

# Use this target to help updating the bellow TF_STATE_ITEMS list manually.
terraform-state-list: $(GOOGLE_APPLICATION_CREDENTIALS)
	@echo "📦 Listing Terraform state items..."
	@$(TERRAFORM) state list
.PHONY: terraform-state-list

terraform-state-backup: $(GOOGLE_APPLICATION_CREDENTIALS)
	@echo "📦 Backing up Terraform state..."
	@$(TERRAFORM) state pull > $(TERRAFORM_PROJECT)/backup.tfstate
.PHONY: terraform-state-backup

-include infra/terraform_items.mk

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
	@echo "📈 Upgrading Terraform..."
	@$(TERRAFORM) init -upgrade
.PHONY: terraform-upgrade

terraform-reconfigure: $(GOOGLE_APPLICATION_CREDENTIALS)
	@echo "🧯 Reconfiguring Terraform..."
	@$(TERRAFORM) init -reconfigure
.PHONY: terraform-reconfigure

terraform-plan: $(GOOGLE_APPLICATION_CREDENTIALS)
	@echo "🧾 Planning Terraform changes..."
	@$(TERRAFORM) plan -out=$(TERRAFORM_PROJECT)/.planed_terraform
.PHONY: terraform-plan

terraform-unlock: $(GOOGLE_APPLICATION_CREDENTIALS)
	@echo "🔐 Unlocking Terraform state..."
	@$(TERRAFORM) force-unlock $(LOCK_ID)
.PHONY: terraform-unlock

terraform-providers: $(GOOGLE_APPLICATION_CREDENTIALS)
	@echo "📦 Listing Terraform providers..."
	@$(TERRAFORM) providers -v
.PHONY: terraform-providers

terraform-validate: $(GOOGLE_APPLICATION_CREDENTIALS)
	@echo "🧪 Validating Terraform configuration..."
	@$(TERRAFORM) validate
.PHONY: terraform-validate

terraform-refresh: $(GOOGLE_APPLICATION_CREDENTIALS)
	@echo "🔄 Refreshing Terraform state..."
	@$(TERRAFORM) refresh
.PHONY: terraform-refresh

terraform-migrate-state: $(GOOGLE_APPLICATION_CREDENTIALS)
	@echo "🧳 Migrating Terraform state..."
	@$(TERRAFORM) init --migrate-state
.PHONY: terraform-migrate-state

terraform-apply-auto-approve: $(GOOGLE_APPLICATION_CREDENTIALS)
	@echo "🚀 Applying Terraform changes with auto-approve..."
	@$(TERRAFORM) apply -auto-approve # $(TERRAFORM_PROJECT)/.planed_terraform
.PHONY: terraform-apply-auto-approve

terraform-output-json: $(GOOGLE_APPLICATION_CREDENTIALS)
	@echo "📤 Outputting Terraform state in JSON..."
	@$(TERRAFORM) output -json
.PHONY: terraform-output-json

terraform-destroy: $(GOOGLE_APPLICATION_CREDENTIALS)
	@echo "🔥 Destroying Terraform-managed infrastructure..."
	@$(TERRAFORM) destroy
.PHONY: terraform-destroy

terraform-output-github-actions-private-key:
	@echo "🔐 Outputting GitHub Actions private key..."
	@$(TERRAFORM) output -json | jq '.github_actions_private_key.value' | sed 's/\"//g' | base64 --decode 
.PHONY: terraform-output-github-actions-private-key

$(APPLICATION_MOBILE_FIREBASE_ANDROID_CONFIG_JSON): terraform-output-firebase-android-config-json

$(INFRA_FIREBASE_ANDROID_CONFIG_JSON): terraform-output-firebase-android-config-json

terraform-output-firebase-android-config-json:
	@echo "📲 Creating Android configuration for '$(INFRA_ENV)': '$(INFRA_FIREBASE_ANDROID_CONFIG_JSON)'"
	@$(TERRAFORM) output firebase_android_config_json | sed -e '1d' -e '$$d' -e '/^$$/d' > $(INFRA_FIREBASE_ANDROID_CONFIG_JSON)
.PHONY: terraform-output-firebase-android-config-json

$(INFRA_FIREBASE_IOS_CONFIG_PLIST): terraform-output-firebase-ios-config-plist

terraform-output-firebase-ios-config-plist: 
	@echo "📱 Creating iOS configuration for '$(INFRA_ENV)': '$(INFRA_FIREBASE_IOS_CONFIG_PLIST)'"
	@$(TERRAFORM) output firebase_ios_config_plist | sed -e '1d' -e '$$d' -e '/^$$/d' > $(INFRA_FIREBASE_IOS_CONFIG_PLIST)
.PHONY: terraform-output-firebase-ios-config-plist

terraform-console:
	@echo "🧮 Starting Terraform console..."
	$(TERRAFORM) console
.PHONY: terraform-console
