GOOGLE_APPLICATION_CREDENTIALS ?= $(GOOGLE_CLOUD_DIR)/gcloud-credentials.json

gcloud-application-credentials: $(GOOGLE_APPLICATION_CREDENTIALS)
	@echo "✅ Application credentials are ready at $<"
.PHONY: gcloud-application-credentials

# The project currently accepts this number of maximum keys in use per service account.
# If this limit is reach, creation of new credentials will fail living a message in the console like:
# 'ERROR: (gcloud.iam.service-accounts.keys.create) FAILED_PRECONDITION: Precondition check failed.'
# Each developer have the responsibility to rotate his developer's keys. Please check.
# Local developer current keys in use can be listed using 'make gcloud-user-iam-sa-keys-list'
# Old keys can be erased using 'make gcloud-user-iam-sa-keys-clean-oldest-3'
PRIVATE_KEYS_PER_SERVICE_ACCOUNT_PROJECT_LIMIT ?=  10

$(GOOGLE_APPLICATION_CREDENTIALS):
	@echo "🔐 Generating application credentials for service account $(GCLOUD_DEVELOPER_SERVICE_ACCOUNT)..."
	@$(GCLOUD) iam service-accounts keys create $(GOOGLE_APPLICATION_CREDENTIALS) \
	  --iam-account=$(GCLOUD_DEVELOPER_SERVICE_ACCOUNT)  \
	&& if [ !  -f $(GOOGLE_APPLICATION_CREDENTIALS) ] ; then \
	  echo Check if you do not have more than $(PRIVATE_KEYS_PER_SERVICE_ACCOUNT_PROJECT_LIMIT)	keys in use: ; \
	  echo \* 👉 check limit exceeded: \'make gcloud-user-iam-sa-keys-list\'. ; \
	  echo \* 🔧 Use \'make gcloud-user-iam-sa-keys-clean-oldest-3\' to deletes the 3 oldest keys. ; \
	  echo \* ☑️ Then, use \'make $@\' or \'make gcloud-auth-login\' to retry. ; \
	fi \
	|| rm $(GOOGLE_APPLICATION_CREDENTIALS)

gcloud-auth-login:
	@echo "🔐 Logging in to gcloud..."
	@$(GCLOUD) auth login --no-launch-browser
.PHONY: gcloud-auth-login

gcloud-auth-reset:
	@$(GCLOUD) auth revoke --all
.PHONY: gcloud-auth-reset

gcloud-auth-login-sa:
	@if [ ! -f $(GOOGLE_APPLICATION_CREDENTIALS) ]; then \
	  echo "🔐 No existing SA key found, logging in as user..."; \
	  gcloud auth login --project=$(GOOGLE_CLOUD_PROJECT_ID); \
	  echo "🔑 Creating key for $(GCLOUD_DEVELOPER_SERVICE_ACCOUNT)..."; \
	  gcloud iam service-accounts keys create $(GOOGLE_APPLICATION_CREDENTIALS) \
	    --iam-account=$(GCLOUD_DEVELOPER_SERVICE_ACCOUNT) \
	    --project=$(GOOGLE_CLOUD_PROJECT_ID); \
	fi
	@echo "✅ Activating service account credentials..."; \
	gcloud auth activate-service-account --key-file=$(GOOGLE_APPLICATION_CREDENTIALS)

# Use your root user email address permissions instead of your developer service account.
gcloud-auth-login-email: gcloud-auth-login gcloud-project-set
	@echo "✅ Successfully authenticated using email."
	@if [ ! -v USER_EMAIL ] ; then \
	  echo USER_EMAIL is not set for automatic account activation. ; \
	  echo Please activate the current user account usage manually: ; \
	  echo \* gcloud config set account \<user@address-email.com\> ; \
	else \
	  $(MAKE) gcloud-auth-config-set-account-user-email ; \
	fi
.PHONY: gcloud-auth-login-email

gcloud-auth-config-set-account-user-email:
	@if [ ! -v USER_EMAIL ] ; then \
	  echo Missing variabe USER_EMAIL. ; \
	  exit 1 ; \
	fi 
	@$(GCLOUD) config set account $(USER_EMAIL)
	@echo "Further gcloud commands are going to use your email as user with IAM role bindings if GOOGLE_APPLICATION_CREDENTIALS is empty."
.PHONY: gcloud-auth-config-set-account-user-email

gcloud-auth-serviceaccount-activate: $(GOOGLE_APPLICATION_CREDENTIALS)
	@echo "🔧 Activating local service account: $< ..."
	@$(GCLOUD) auth activate-service-account --key-file="$<"
.PHONY: gcloud-auth-serviceaccount-activate

# ADC (Application Default Credentials: https://cloud.google.com/docs/authentication/provide-credentials-adc?hl=en)
gcloud-auth-default-application-credentials:
	@echo "🔐 Setting up default application credentials and logging in..."
	@$(GCLOUD) config set project $(GOOGLE_CLOUD_PROJECT_ID)
	@echo "🔐 Logging in with application default credentials..."
	@$(GCLOUD) auth application-default login
	@echo "💰 Setting quota project for application default credentials..."
	@$(GCLOUD) auth application-default set-quota-project $(GOOGLE_CLOUD_PROJECT_ID)
.PHONY: gcloud-auth-default-application-credentials

ROOT_ADMIN_SERVICE_ACCOUNT = root-admin@$(GOOGLE_CLOUD_PROJECT_ID).iam.gserviceaccount.com

# set INFRA_ENV=prod in the environment to use root admin service account
gcloud-root-admin-credentials:
	INFRA_ENV=prod \
	GCLOUD_DEVELOPER_SERVICE_ACCOUNT=$(ROOT_ADMIN_SERVICE_ACCOUNT) \
	$(MAKE) gcloud-application-credentials
.PHONY: gcloud-root-admin-credentials

# set INFRA_ENV=prod in the environment to use root admin service account
gcloud-root-admin-credentials-revoke:
	@GCLOUD_DEVELOPER_SERVICE_ACCOUNT=$(ROOT_ADMIN_SERVICE_ACCOUNT) \
	$(MAKE) gcloud-user-iam-sa-keys-clean-all
.PHONY: gcloud-root-admin-credentials-revoke

gcloud-auth-docker:
	@echo "🐳 Authenticating Docker with Google Artifact Registry..."
	@$(GCLOUD) --quiet auth configure-docker $(GOOGLE_CLOUD_DOCKER_REGISTRY)
.PHONY: gcloud-auth-docker
