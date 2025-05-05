GOOGLE_CLOUD_REGION = europe-west1

PROD_GOOGLE_CLOUD_PROJECT_ID = moov-438615
PROD_GOOGLE_CLOUD_PROJECT_NUMBER = 378762893981

STAGING_GOOGLE_CLOUD_PROJECT_ID = moov-staging-440506
STAGING_GOOGLE_CLOUD_PROJECT_NUMBER = 326118600145

DEV_GOOGLE_CLOUD_PROJECT_ID = moov-dev-439608
DEV_GOOGLE_CLOUD_PROJECT_NUMBER = 203475703228

ifeq ($(INFRA_ENV),prod)
GOOGLE_CLOUD_PROJECT_ID = $(PROD_GOOGLE_CLOUD_PROJECT_ID)
GOOGLE_CLOUD_PROJECT_NUMBER = $(PROD_GOOGLE_CLOUD_PROJECT_NUMBER)
else ifeq ($(INFRA_ENV),staging)
GOOGLE_CLOUD_PROJECT_ID =  $(STAGING_GOOGLE_CLOUD_PROJECT_ID)
GOOGLE_CLOUD_PROJECT_NUMBER = $(STAGING_GOOGLE_CLOUD_PROJECT_NUMBER)
else ifeq ($(INFRA_ENV),dev)
GOOGLE_CLOUD_PROJECT_ID = $(DEV_GOOGLE_CLOUD_PROJECT_ID)
GOOGLE_CLOUD_PROJECT_NUMBER = $(DEV_GOOGLE_CLOUD_PROJECT_NUMBER)
else
  $(error Invalid INFRA_ENV: $(INFRA_ENV))
endif

GCLOUD := gcloud --project=$(GOOGLE_CLOUD_PROJECT_ID)

GCLOUD_PROJET_USER_ID ?= ${PROJECT_USER}

GCLOUD_DEVELOPER_SERVICE_ACCOUNT = $(GCLOUD_PROJET_USER_ID)-$(INFRA_ENV)@$(GOOGLE_CLOUD_PROJECT_ID).iam.gserviceaccount.com

ifeq ($(GOOGLE_APPLICATION_CREDENTIALS),)
GOOGLE_APPLICATION_CREDENTIALS = $(CURDIR)/infra/environments/$(INFRA_ENV)/gcloud-credentials.json
endif

export GOOGLE_APPLICATION_CREDENTIALS

gcloud-auth-default-application-credentials:
	@echo "🔐 Setting up default application credentials and logging in..."
	@$(GCLOUD) config set project $(GOOGLE_CLOUD_PROJECT_ID)
	@echo "🔐 Logging in with application default credentials..."
	@$(GCLOUD) auth application-default login
	@echo "🔐 Setting quota project for application default credentials..."
	@$(GCLOUD) auth application-default set-quota-project $(GOOGLE_CLOUD_PROJECT_ID)
.PHONY: gcloud-auth-default-application-credentials

$(GOOGLE_APPLICATION_CREDENTIALS):
	$(GCLOUD) iam service-accounts keys create \
	  $(GOOGLE_APPLICATION_CREDENTIALS) \
	  --iam-account=$(GCLOUD_DEVELOPER_SERVICE_ACCOUNT)

gcloud-info:
	@echo "ℹ️  Displaying gcloud info..."
	@$(GCLOUD) info
.PHONY: gcloud-info

gcloud-auth-login:
	@echo "🔐 Logging in to gcloud and activating service account..."
	@$(GCLOUD) auth login
	@$(GCLOUD) config set project $(GOOGLE_CLOUD_PROJECT_ID)
	@echo "🔐 Activating service account via GOOGLE_APPLICATION_CREDENTIALS..."
	@$(GCLOUD) auth activate-service-account --key-file="$(GOOGLE_APPLICATION_CREDENTIALS)"
.PHONY: gcloud-auth-login

gcloud-auth-docker:
	@echo "🐳 Authenticating Docker with Google Artifact Registry..."
	@$(GCLOUD) --quiet auth configure-docker $(REGISTRY)
.PHONY: gcloud-auth-docker

gcloud-config-set-project:
	@echo "🔧 Setting gcloud config project to $(GOOGLE_CLOUD_PROJECT_ID)..."
	@$(GCLOUD) config set project $(GOOGLE_CLOUD_PROJECT_ID)
.PHONY:gcloud-config-set-project

gcloud-images-list:
	@echo "📦 Listing all images in repository $(REPOSITORY)..."
	$(GCLOUD) container images list --repository=$(REPOSITORY)
.PHONY: gcloud-images-list

gcloud-images-list-public:
	@echo "📦 Listing all images in public repository $(PUBLIC_REPOSITORY)..."
	$(GCLOUD) container images list --repository=$(PUBLIC_REPOSITORY)
.PHONY: gcloud-images-list-public

gcloud-images-list-tags:
	@echo "🏷️  Listing tags for image base $(IMAGES_BASE)..."
	@$(GCLOUD) container images list-tags $(IMAGES_BASE)
.PHONY: gcloud-images-list-tags

gcloud-images-list-tags-public:
	@echo "🏷️  Listing tags for public image base $(PUBLIC_IMAGES_BASE)..."
	@$(GCLOUD) container images list-tags $(PUBLIC_IMAGES_BASE)
.PHONY: gcloud-images-list-tags-public

gcloud-images-delete-all:
	@echo "🗑️  Deleting all images from repository $(IMAGES_BASE)..."
	$(GCLOUD) artifacts docker images list \
    --project=$(GOOGLE_CLOUD_PROJECT_ID) \
    --format='get(package)' \
    $(IMAGES_BASE) \
    | uniq \
    | xargs -I {} gcloud artifacts docker images delete {} --delete-tags --quiet --project=$(GOOGLE_CLOUD_PROJECT_ID)
.PHONY: gcloud-images-delete-all

gcloud-images-delete-all-public:
	@echo "🗑️  Deleting all images from public repository $(PUBLIC_IMAGES_BASE)..."
	@$(GCLOUD) artifacts docker images list \
    --project=$(GOOGLE_CLOUD_PROJECT_ID) \
    --format='get(package)' \
    $(PUBLIC_IMAGES_BASE) \
    | uniq \
    | xargs -I {} gcloud artifacts docker images delete {} --delete-tags --quiet --project=$(GOOGLE_CLOUD_PROJECT_ID)
.PHONY: gcloud-images-delete-all-public

gcloud-backend-image-delete:
	@echo "🗑️  Deleting backend image $(APPLICATION_BACKEND_IMAGE)..."
	@$(GCLOUD) container images delete --force-delete-tags $(APPLICATION_BACKEND_IMAGE)
.PHONY: gcloud-backend-image-delete

gcloud-builder-image-delete:
	@echo "🗑️  Deleting builder image $(BUILDER_IMAGE)..."
	@$(GCLOUD) container images delete --force-delete-tags $(BUILDER_IMAGE)
.PHONY: gcloud-builder-image-delete

gcloud-auth-func-logs:
	@echo "📜 Reading logs for Cloud Function: utrade-us-central1-identity-platform..."
	@$(GCLOUD) logging read "resource.type=cloud_function AND resource.labels.function_name=utrade-us-central1-identity-platform"
.PHONY: gcloud-auth-func-logs

gcloud-auth-func-deploy:
	@echo "🚀 Deploying Cloud Function: my-pubsub-function to region $(GOOGLE_CLOUD_REGION)..."
	@$(GCLOUD) functions deploy my-pubsub-function \
	  --gen2 \
	  --region=$(GOOGLE_CLOUD_REGION) \
	  --runtime=go122 \
	  --source=$(CURDIR)/infra/gcloud/auth \
	  --entry-point=idp.go \
	  --trigger-http
.PHONY: gcloud-auth-func-deploy

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

ADMIN_DEVELOPPER_MEMBERS := \
  admin-developper-$(GOOGLE_CLOUD_PROJECT_ID) \
  root-admin

$(ADMIN_DEVELOPPER_MEMBERS:%=gcloud-%-storage-admin):
	@$(GCLOUD) projects add-iam-policy-binding $(GOOGLE_CLOUD_PROJECT_ID) \
	  --member serviceaccount:$(@:gcloud-%-storage-admin=%)@$(GOOGLE_CLOUD_PROJECT_ID).iam.gserviceaccount.com \
	  --role roles/storage.admin
.PHONY: $(ADMIN_DEVELOPPER_MEMBERS:%=gcloud-%-storage-admin)

gcloud-storage-admins: $(ADMIN_DEVELOPPER_MEMBERS:%=gcloud-%-storage-admin)
.PHONY: gcloud-storage-admins

gcloud-apikeys-list:
	@$(GCLOUD) alpha services api-keys list
.PHONY: gcloud-apikeys-list

gcloud-roles-list:
	@$(GCLOUD) iam roles list
.PHONY: gcloud-roles-list

gcloud-serviceaccounts-list:
	@$(GCLOUD) iam service-accounts list
.PHONY: gcloud-serviceaccounts-list

gcloud-services-list:
	@$(GCLOUD) services list --enabled
.PHONY: gcloud-services-list

# Use this target to configure the Docker pluggin of Vscode if credential-helper cannot help.
gcloud-docker-registry-temporary-token:
	@echo Getting $(GCLOUD) docker registry temporary access token:
	@echo  registry: $(REGISTRY)
	@echo  username: oauth2accesstoken
	@echo  password: `$(GCLOUD) auth print-access-token`
.PHONY: gcloud-docker-registry-temporary-token

GCLOUD_SERVICE_ACCOUNTS = \
	$(GOOGLE_CLOUD_PROJECT_ID)@appspot.gserviceaccount.com \
	$(GOOGLE_CLOUD_PROJECT_ID)-compute@developer.gserviceaccount.com \
	github-actions-main@$(GOOGLE_CLOUD_PROJECT_ID).iam.gserviceaccount.com \
	production-application-backend@$(GOOGLE_CLOUD_PROJECT_ID).iam.gserviceaccount.com \
	firebase-admin-sa@$(GOOGLE_CLOUD_PROJECT_ID).iam.gserviceaccount.com \
	firebase-adminsdk-mvk7v@$(GOOGLE_CLOUD_PROJECT_ID).iam.gserviceaccount.com \
	${PROJECT_USER}-$(INFRA_ENV)@$(GOOGLE_CLOUD_PROJECT_ID).iam.gserviceaccount.com \
	root-admin@$(GOOGLE_CLOUD_PROJECT_ID).iam.gserviceaccount.com \
	vault-node-sa@$(GOOGLE_CLOUD_PROJECT_ID).iam.gserviceaccount.com \
	vault-sa@$(GOOGLE_CLOUD_PROJECT_ID).iam.gserviceaccount.com \
	vault-tf-apply@$(GOOGLE_CLOUD_PROJECT_ID).iam.gserviceaccount.com  

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
	@$(GCLOUD) iam service-accounts get-iam-policy $(@:gcloud-%-serviceaccount-iam-policy=%)
.PHONY: $(GCLOUD_SERVICE_ACCOUNTS:%=gcloud-%-serviceaccount-iam-policy)

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

# Upadte this list with '$(GCLOUD) secrets list' values
GCLOUD_SECRETS := \
  firebase-adminsdk-service-account-key \
  firebase-config-web \
  google-idp-oauth-client-id \
  google-idp-oauth-key \
  google-maps-api-key

$(GCLOUD_SECRETS:%=gcloud-secret-%-show):
	@a=$$($(GCLOUD) secrets versions access latest --secret=$(@:gcloud-secret-%-show=%)) \
	&& echo $$a | jq 2>/dev/null \
	|| echo $$a
.PHONY: $(GCLOUD_SECRETS:%=gcloud-secret-%-show)

gcloud-compute-disk-list:
	@echo Disk used:
	@$(GCLOUD) compute disks list --filter="zone:($(GOOGLE_CLOUD_REGION)-*)" --format="table(name,sizeGb,type,zone)"
.PHONY: gcloud-compute-disk-list

gcloud-compute-list-available-machine-type:
	@echo GCP compute available machine types:
	@$(GCLOUD) compute machine-types list --filter="zone:($(GOOGLE_CLOUD_REGION)-*)" --project $(GOOGLE_CLOUD_PROJECT_ID)
.PHONY: gcloud-compute-list-available-machine-type
