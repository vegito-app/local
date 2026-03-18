GOOGLE_CLOUD_DIR ?= $(CURDIR)
GOOGLE_CLOUD_PROJECT_ID ?= $(DEV_GOOGLE_CLOUD_PROJECT_ID)
GOOGLE_CLOUD_REGION ?= europe-west1
GOOGLE_CLOUD_DOCKER_REGISTRY ?= $(GOOGLE_CLOUD_REGION)-docker.pkg.dev

GCLOUD_PROJET_USER_ID ?= ${PROJECT_USER}
GCLOUD_DEVELOPER_SERVICE_ACCOUNT ?= $(GCLOUD_PROJET_USER_ID)-$(INFRA_ENV)@$(GOOGLE_CLOUD_PROJECT_ID).iam.gserviceaccount.com

VEGITO_PUBLIC_REPOSITORY ?= $(GOOGLE_CLOUD_DOCKER_REGISTRY)/$(GOOGLE_CLOUD_PROJECT_ID)/docker-repository-public
VEGITO_PRIVATE_REPOSITORY ?= $(GOOGLE_CLOUD_DOCKER_REGISTRY)/$(GOOGLE_CLOUD_PROJECT_ID)/docker-repository-private

GCLOUD := gcloud --project=$(GOOGLE_CLOUD_PROJECT_ID)
# The project currently accepts this number of maximum keys in use per service account.
# If this limit is reach, creation of new credentials will fail living a message in the console like:
# 'ERROR: (gcloud.iam.service-accounts.keys.create) FAILED_PRECONDITION: Precondition check failed.'
# Each developer have the responsibility to rotate his developer's keys. Please check.
# Local developer current keys in use can be listed using 'make gcloud-user-iam-sa-keys-list'
# Old keys can be erased using 'make gcloud-user-iam-sa-keys-clean-oldest-3'
PRIVATE_KEYS_PER_SERVICE_ACCOUNT_PROJECT_LIMIT ?=  10

GOOGLE_APPLICATION_CREDENTIALS ?= $(GOOGLE_CLOUD_DIR)/gcloud-credentials.json

gcloud-application-credentials: $(GOOGLE_APPLICATION_CREDENTIALS)
	@echo "✅ Application credentials are ready at $<"
.PHONY: gcloud-application-credentials

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

gcloud-project-set:
	@echo "🔧 Configuring current project to $(GOOGLE_CLOUD_PROJECT_ID)."
	@$(GCLOUD) config set project $(GOOGLE_CLOUD_PROJECT_ID)
.PHONY: gcloud-project-set

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

gcloud-info:
	@echo "ℹ️  Displaying gcloud info..."
	@$(GCLOUD) info
.PHONY: gcloud-info

gcloud-auth-docker:
	@echo "🐳 Authenticating Docker with Google Artifact Registry..."
	@$(GCLOUD) --quiet auth configure-docker $(GOOGLE_CLOUD_DOCKER_REGISTRY)
.PHONY: gcloud-auth-docker

gcloud-config-set-project:
	@echo "🔧 Setting gcloud config project to $(GOOGLE_CLOUD_PROJECT_ID)..."
	@$(GCLOUD) config set project $(GOOGLE_CLOUD_PROJECT_ID)
.PHONY:gcloud-config-set-project

GCLOUD_DOCKER_REPOSITORIES := $(VEGITO_PUBLIC_REPOSITORY) $(VEGITO_PRIVATE_REPOSITORY)

gcloud-images-list: $(GCLOUD_DOCKER_REPOSITORIES:%=gcloud-%-images-list)
.PHONY: gcloud-images-list

$(GCLOUD_DOCKER_REPOSITORIES:%=gcloud-%-images-list):
	@echo "📦 Listing all images in repository $(@:gcloud-%-images-list=%)..."
	@$(GCLOUD) container images list --repository=$(@:gcloud-%-images-list=%)
.PHONY: $(GCLOUD_DOCKER_REPOSITORIES:%=gcloud-%-images-list)

gcloud-images-list-tags: $(GCLOUD_DOCKER_REPOSITORIES:%=gcloud-%-images-list-tags)
.PHONY: gcloud-images-list-tags

$(GCLOUD_DOCKER_REPOSITORIES:%=gcloud-%-images-list-tags):
	@echo "🏷️  Listing tags for image base $(@:gcloud-%-images-list-tags=%)..."
	@$(GCLOUD) container images list-tags $(@:gcloud-%-images-list-tags=%)
.PHONY: $(GCLOUD_DOCKER_REPOSITORIES:%=gcloud-%-images-list-tags)

gcloud-images-delete-all-tags: $(GCLOUD_DOCKER_REPOSITORIES:%=gcloud-%-images-delete-all-tags)
.PHONY: gcloud-images-delete-all-tags

$(GCLOUD_DOCKER_REPOSITORIES:%=gcloud-%-images-delete-all-tags):
	@echo "🗑️  Deleting all images from repository $(@:gcloud-%-images-delete-all-tags=%)..."
	@$(GCLOUD) artifacts docker images list \
      --project=$(GOOGLE_CLOUD_PROJECT_ID) \
      --format='get(package)' \
      $(@:gcloud-%-images-delete-all-tags=%) \
      | uniq \
      | xargs -I {} $(GCLOUD) artifacts docker images delete {} --delete-tags --quiet --project=$(GOOGLE_CLOUD_PROJECT_ID)
.PHONY: $(GCLOUD_DOCKER_REPOSITORIES:%=gcloud-%-images-delete-all-tags)

gcloud-docker-registry-cleanup: $(GCLOUD_DOCKER_REPOSITORIES:%=gcloud-docker-registry-cleanup-%)
.PHONY: gcloud-docker-registry-cleanup

$(GCLOUD_DOCKER_REPOSITORIES:%=gcloud-docker-registry-cleanup-%):
	@echo "🗑️  Deleting all images without 'latest' or 'current' tags from repository $*..."
	@PROJECT=$(GOOGLE_CLOUD_PROJECT_ID) \
	  REGION=$(GOOGLE_CLOUD_REGION) \
	  REPO=$(@:gcloud-docker-registry-cleanup-%=%) \
	  $(GOOGLE_CLOUD_DIR)/docker-registry-cleanup.sh
.PHONY: $(GCLOUD_DOCKER_REPOSITORIES:%=gcloud-docker-registry-cleanup-%)

GOOGLE_SERVICES_API = serviceusage cloudbilling

gcloud-services-apis-enable: $(GOOGLE_SERVICES_API:%=gcloud-services-enable-%-api)
	@echo "✅ Enabled required Google Cloud APIs."
.PHONY: gcloud-services-apis-enable

gcloud-services-apis-disable: $(GOOGLE_SERVICES_API:%=gcloud-services-disable-%-api)
	@echo "🚫 Disabled specified Google Cloud APIs."
.PHONY: gcloud-services-apis-disable

FIREBASE_ADMINSDK_SERVICEACCOUNT = \
  $(INFRA_ENV)-firebase-adminsdk@$(GOOGLE_CLOUD_PROJECT_ID).iam.gserviceaccount.com

gcloud-firebase-adminsdk-service-account-roles-list:
	@echo "🔎 Listing IAM roles for Firebase Admin SDK service account $(FIREBASE_ADMINSDK_SERVICEACCOUNT)..."
	@$(GCLOUD) projects get-iam-policy $(GOOGLE_CLOUD_PROJECT_ID) \
	  --flatten="bindings[].members" \
	  --format='table(bindings.role)' \
	  --filter="bindings.members:$(FIREBASE_ADMINSDK_SERVICEACCOUNT)"
.PHONY: gcloud-firebase-adminsdk-service-account-roles-list

$(GOOGLE_SERVICES_API:%=gcloud-services-enable-%-api):
	@$(GCLOUD) services enable $(@:gcloud-services-enable-%-api=%).googleapis.com --project=$(GOOGLE_CLOUD_PROJECT_ID)
.PHONY: $(GOOGLE_SERVICES_API:%=gcloud-services-enable-%-api)

$(GOOGLE_SERVICES_API:%=gcloud-services-disable-%-api):
	@$(GCLOUD) services disable $(@:gcloud-services-disable-%-api=%).googleapis.com --project=$(GOOGLE_CLOUD_PROJECT_ID)
.PHONY: $(GOOGLE_SERVICES_API:%=gcloud-services-disable-%-api)

gcloud-apikeys-list:
	@$(GCLOUD) alpha services api-keys list
.PHONY: gcloud-apikeys-list

gcloud-roles-list:
	@$(GCLOUD) iam roles list
.PHONY: gcloud-roles-list

gcloud-serviceaccounts-list:
	@$(GCLOUD) iam service-accounts list
.PHONY: gcloud-serviceaccounts-list

gcloud-services-list-enabled:
	@$(GCLOUD) services list --enabled
.PHONY: gcloud-services-list-enabled

# Use this target to configure the Docker pluggin of Vscode if credential-helper cannot help.
gcloud-docker-registry-temporary-token:
	@echo Getting $(GCLOUD) docker registry temporary access token:
	@echo  registry: $(GOOGLE_CLOUD_DOCKER_REGISTRY)
	@echo  username: oauth2accesstoken
	@echo  password: `$(GCLOUD) auth print-access-token`
.PHONY: gcloud-docker-registry-temporary-token

PRODUCTION_ONLY_SERVICE_ACCOUNTS = 	\
	firebase-adminsdk-mvk7v@$(GOOGLE_CLOUD_PROJECT_ID).iam.gserviceaccount.com \
	$(ROOT_ADMIN_SERVICE_ACCOUNT) \
	vault-node-sa@$(GOOGLE_CLOUD_PROJECT_ID).iam.gserviceaccount.com \
	vault-sa@$(GOOGLE_CLOUD_PROJECT_ID).iam.gserviceaccount.com \
	vault-tf-apply@$(GOOGLE_CLOUD_PROJECT_ID).iam.gserviceaccount.com  

GCLOUD_SERVICE_ACCOUNTS = \
	$(PRODUCTION_ONLY_SERVICE_ACCOUNTS) \
	$(GOOGLE_CLOUD_PROJECT_ID)@appspot.gserviceaccount.com \
	github-actions-main@$(GOOGLE_CLOUD_PROJECT_ID).iam.gserviceaccount.com \
	production-application-backend@$(GOOGLE_CLOUD_PROJECT_ID).iam.gserviceaccount.com \
	firebase-admin-sa@$(GOOGLE_CLOUD_PROJECT_ID).iam.gserviceaccount.com \
	$(GCLOUD_DEVELOPER_SERVICE_ACCOUNT)

$(GCLOUD_SERVICE_ACCOUNTS:%=gcloud-%-serviceaccount-bindings-roles):
	@echo Print bindings members roles for $(@:gcloud-%-serviceaccount-bindings-roles=%):
	@$(GCLOUD) projects get-iam-policy $(GOOGLE_CLOUD_PROJECT_ID) \
	  --flatten="bindings[].members" --format='table(bindings.role)' \
	  --filter="bindings.members:serviceaccount:$(@:gcloud-%-serviceaccount-bindings-roles=%)"
.PHONY: $(GCLOUD_SERVICE_ACCOUNTS:%=gcloud-%-serviceaccount-bindings-roles)

gcloud-serviceaccount-roles: $(GCLOUD_SERVICE_ACCOUNTS:%=gcloud-%-serviceaccount-bindings-roles)
.PHONY: gcloud-serviceaccount-roles

gcloud-serviceaccount-iam-policy: $(GCLOUD_SERVICE_ACCOUNTS:%=gcloud-%-serviceaccount-iam-policy)
.PHONY: gcloud-serviceaccount-iam-policy

$(GCLOUD_SERVICE_ACCOUNTS:%=gcloud-%-serviceaccount-iam-policy):
	@echo 📋 listing service-account iam policies of $(@:%=gcloud-%-serviceaccount-iam-policy)
	@-$(GCLOUD) iam service-accounts get-iam-policy $(@:gcloud-%-serviceaccount-iam-policy=%)
.PHONY: $(GCLOUD_SERVICE_ACCOUNTS:%=gcloud-%-serviceaccount-iam-policy)

gcloud-serviceaccount-keys-list: $(GCLOUD_SERVICE_ACCOUNTS:%=gcloud-%-serviceaccount-keys-list)
.PHONY: gcloud-serviceaccount-keys-list

$(GCLOUD_SERVICE_ACCOUNTS:%=gcloud-%-serviceaccount-keys-list):
	@echo 📋 listing keys of service account $(@:gcloud-%-serviceaccount-keys-list=%)
	@-$(GCLOUD) iam service-accounts keys list --iam-account $(@:gcloud-%-serviceaccount-keys-list=%)
.PHONY: $(GCLOUD_SERVICE_ACCOUNTS:%=gcloud-%-serviceaccount-keys-list)

$(GCLOUD_SERVICE_ACCOUNTS:%=gcloud-%-serviceaccount-keys-rm):
	@echo 📋 removing keys of service account $(@:gcloud-%-serviceaccount-keys-rm=%)
	@-$(GCLOUD) iam service-accounts keys delete $$KEY \
			--iam-account=$(@:gcloud-%-serviceaccount-keys-rm=%) \
			--quiet;
.PHONY: $(GCLOUD_SERVICE_ACCOUNTS:%=gcloud-%-serviceaccount-keys-rm)

gcloud-user-iam-sa-keys-list: gcloud-$(GCLOUD_DEVELOPER_SERVICE_ACCOUNT)-serviceaccount-keys-list
.PHONY: gcloud-user-iam-sa-keys-list

gcloud-user-iam-sa-keys-clean-oldest-3:
	@echo "🔐 Récupération des clés pour $(GCLOUD_DEVELOPER_SERVICE_ACCOUNT)..."
	@KEYS=$$($(GCLOUD) iam service-accounts keys list \
		--iam-account=$(GCLOUD_DEVELOPER_SERVICE_ACCOUNT) \
		--format="value(name)" --sort-by=validAfterTime | head -n 3) \
	&& for KEY in $$KEYS; do \
		echo "🗑️ Suppression de la clé $$KEY..."; \
		$(GCLOUD) iam service-accounts keys delete $$KEY \
			--project=$(GOOGLE_CLOUD_PROJECT_ID) \
			--iam-account=$(GCLOUD_DEVELOPER_SERVICE_ACCOUNT) \
			--quiet; \
	done
.PHONY: gcloud-user-iam-sa-keys-clean-oldest-3

gcloud-user-iam-sa-keys-clean-all:
	@echo "🔐 Récupération des clés pour $(GCLOUD_DEVELOPER_SERVICE_ACCOUNT)..."
	@KEYS=$$($(GCLOUD) iam service-accounts keys list \
		--iam-account=$(GCLOUD_DEVELOPER_SERVICE_ACCOUNT) \
		--format="value(name)"); \
	for KEY in $$KEYS; do \
		echo "🗑️ Suppression de la clé $$KEY..."; \
		$(GCLOUD) iam service-accounts keys delete $$KEY \
			--iam-account=$(GCLOUD_DEVELOPER_SERVICE_ACCOUNT) \
			--quiet; \
	done
.PHONY: gcloud-user-iam-sa-keys-clean-all

GCLOUD_USERS_EMAILS := \
  davidberich@gmail.com

$(GCLOUD_USERS_EMAILS:%=gcloud-user-%-roles):
	@echo iam member '$(@:gcloud-user-%-roles=%)' roles:
	@$(GCLOUD) projects get-iam-policy $(GOOGLE_CLOUD_PROJECT_ID) \
	  --flatten="bindings[].members" \
	  --format='table(bindings.role)' \
	  --filter="bindings.members:$(@:gcloud-user-%-roles=%)"
.PHONY: $(GCLOUD_USERS_EMAILS:%=gcloud-user-%-roles)

gcloud-users-roles: $(GCLOUD_USERS_EMAILS:%=gcloud-user-%-roles)
.PHONY: gcloud-users-roles

gcloud-user-sa-permission-list:
	@$(GCLOUD) projects get-iam-policy "$(GOOGLE_CLOUD_PROJECT_ID)" \
	  --format=json \
	  | jq --arg ACCOUNT "$(GCLOUD_DEVELOPER_SERVICE_ACCOUNT)" ' \
	  	.bindings[] \
	  	| select(.members[]? == $(GCLOUD_DEVELOPER_SERVICE_ACCOUNT)) \
	  	| .role' \
	  | xargs -I{} gcloud iam roles describe {} \
	  	--project="$(GOOGLE_CLOUD_PROJECT_ID)" \
	  	--format="value(includedPermissions)" \
  	  | wc -l
.PHONY: gcloud-user-sa-permission-list

# Upadte this list with '$(GCLOUD) secrets list' values
GCLOUD_SECRETS := \
  firebase-adminsdk-service-account-key \
  firebase-config-web \
  google-idp-oauth-client-id \
  google-idp-oauth-key \
  google-maps-api-key \
  stripe-key

$(GCLOUD_SECRETS:%=gcloud-secret-%-show):
	@a=$$($(GCLOUD) secrets versions access latest \
	  --secret=$(@:gcloud-secret-%-show=%)) \
	&& echo $$a | jq 2>/dev/null \
	|| echo $$a
.PHONY: $(GCLOUD_SECRETS:%=gcloud-secret-%-show)

gcloud-compute-disk-list:
	@echo Disk used:
	@$(GCLOUD) compute disks list \
	  --filter="zone:($(GOOGLE_CLOUD_REGION)-*)" \
	  --format="table(name,sizeGb,type,zone)"
.PHONY: gcloud-compute-disk-list

gcloud-compute-list-available-machine-type:
	@echo GCP compute available machine types:
	@$(GCLOUD) compute machine-types list \
	  --filter="zone:($(GOOGLE_CLOUD_REGION)-*)" \
	  --project $(GOOGLE_CLOUD_PROJECT_ID)
.PHONY: gcloud-compute-list-available-machine-type

gcloud-compute-quotas:
	@echo GCP compute quotas:
	@$(GCLOUD) compute regions describe $(GOOGLE_CLOUD_REGION) --format="flattened(quotas)
.PHONY: gcloud-compute-quotas

gcloud-user-compute-instance-suspend:
	@echo "⏸️  Suspending compute instance dev-$(PROJECT_USER)..."
	@$(GCLOUD) compute instances suspend dev-$(PROJECT_USER) --zone=$(GOOGLE_CLOUD_REGION)-b
.PHONY: gcloud-user-suspend

gcloud-user-compute-instance-start:
	@echo "▶️  Starting compute instance dev-$(PROJECT_USER)..."
	@$(GCLOUD) compute instances start dev-$(PROJECT_USER) --zone=$(GOOGLE_CLOUD_REGION)-b
.PHONY: gcloud-user-start

gcloud-user-compute-instance-status:
	@echo "ℹ️  Status of compute instance dev-$(PROJECT_USER)..."
	@$(GCLOUD) compute instances describe dev-$(PROJECT_USER) --zone=$(GOOGLE_CLOUD_REGION)-b --format='get(status)'
.PHONY: gcloud-user-status