GOOGLE_CLOUD_PROJECT_ID ?= moov-438615
GOOGLE_CLOUD_PROJECT_NUM ?= 378762893981
GOOGLE_CLOUD_REGION ?= europe-west1

GOOGLE_CLOUD_CREDENTIALS_JSON_FILE ?= $(CURDIR)/infra/gcloud-credentials.json

google-application-credentials: google-application-credentials-token-exist
	bash -c 'echo -n $$GOOGLE_CLOUD_CREDENTIALS' | jq > $(GOOGLE_CLOUD_CREDENTIALS_JSON_FILE)
.PHONY: google-application-credentials

google-application-credentials-token-exist:
	@if [ ! -v GOOGLE_CLOUD_CREDENTIALS ] ; then \
		echo missing GOOGLE_CLOUD_CREDENTIALS environment variable. \
		exit -1 ; \
	fi
.PHONY: google-application-credentials-token-exist

$(GOOGLE_CLOUD_CREDENTIALS_JSON_FILE): 
	@$(MAKE) google-application-credentials

gcloud-auth-login:
	@gcloud auth login
	@gcloud config set project $(GOOGLE_CLOUD_PROJECT_ID)
.PHONY: gcloud-auth-login

gcloud-auth-default-application-credentials:
	@gcloud auth application-default login
	@gcloud config set project $(GOOGLE_CLOUD_PROJECT_ID)
.PHONY: gcloud-auth-default-application-credentials

gcloud-auth-docker:
	@gcloud auth configure-docker $(REGISTRY)
.PHONY: gcloud-auth-docker

gcloud-images-list:
	@gcloud container images list --repository=$(REPOSITORY)
.PHONY: gcloud-images-list

gcloud-images-list-tags:
	@gcloud container images list-tags $(IMAGES_BASE)
.PHONY: gcloud-images-list-tags

gcloud-images-list-tags-public:
	@gcloud container images list-tags $(PUBLIC_IMAGES_BASE)
.PHONY: gcloud-images-list-tags-public

gcloud-images-builder-untag-all:
	@gcloud container images list-tags $(IMAGES_BASE) --format='get(digest)' \
	| xargs -I {} gcloud container images untag $(IMAGES_BASE)@{}
.PHONY: gcloud-images-builder-untag-all

gcloud-images-builder-untag-all-public:
	@gcloud container images list-tags $(PUBLIC_IMAGES_BASE) --format='get(digest)' \
	| xargs -I {} gcloud container images untag $(PUBLIC_IMAGES_BASE)@{}
.PHONY: gcloud-images-builder-untag-all-public

gcloud-backend-image-delete:
	@gcloud container images delete --force-delete-tags $(APPLICATION_BACKEND_IMAGE)
.PHONY: gcloud-backend-image-delete

gcloud-builder-image-delete:
	@gcloud container images delete --force-delete-tags $(BUILDER_IMAGE)
.PHONY: gcloud-builder-image-delete

gcloud-auth-func-logs:
	@gcloud logging read "resource.type=cloud_function AND resource.labels.function_name=utrade-us-central1-identity-platform"
.PHONY: gcloud-auth-func-logs

gcloud-auth-func-deploy:
	@gcloud functions deploy my-pubsub-function \
	  --gen2 \
	  --region=$(GOOGLE_CLOUD_REGION) \
	  --runtime=go122 \
	  --source=$(CURDIR)/infra/gcloud/auth \
	  --entry-point=idp.go \
	  --trigger-http
.PHONY: gcloud-auth-func-deploy

GOOGLE_SERVICES_API = serviceusage cloudbilling

gcloud-services-apis-enable: $(GOOGLE_SERVICES_API:%=gcloud-services-enable-%-api)
.PHONY: gcloud-services-apis-enable

gcloud-services-apis-disable: $(GOOGLE_SERVICES_API:%=gcloud-services-disable-%-api)
.PHONY: gcloud-services-apis-disable

FIREBASE_ADMINSDK_SERVICEACCOUNT = \
  $(INFRA_ENV)-firebase-adminsdk@$(GOOGLE_CLOUD_PROJECT_ID).iam.gserviceaccount.com

gcloud-firebase-adminsdk-serviceaccount-roles-list:
	@gcloud projects get-iam-policy $(GOOGLE_CLOUD_PROJECT_ID) \
	  --flatten="bindings[].members" \
	  --format='table(bindings.role)' \
	  --filter="bindings.members:$(FIREBASE_ADMINSDK_SERVICEACCOUNT)"
.PHONY: gcloud-firebase-adminsdk-serviceaccount-roles-list

$(GOOGLE_SERVICES_API:%=gcloud-services-enable-%-api):
	@gcloud services enable $(@:gcloud-services-enable-%-api=%).googleapis.com --project=$(GOOGLE_CLOUD_PROJECT_ID)
.PHONY: $(GOOGLE_SERVICES_API:%=gcloud-services-enable-%-api)

$(GOOGLE_SERVICES_API:%=gcloud-services-disable-%-api):
	@gcloud services disable $(@:gcloud-services-disable-%-api=%).googleapis.com --project=$(GOOGLE_CLOUD_PROJECT_ID)
.PHONY: $(GOOGLE_SERVICES_API:%=gcloud-services-disable-%-api)

ADMIN_DEVELOPPER_MEMBERS := \
  admin-developper-$(GOOGLE_CLOUD_PROJECT_ID) \
  root-admin

$(ADMIN_DEVELOPPER_MEMBERS:%=gcloud-%-storage-admin):
	@gcloud projects add-iam-policy-binding $(GOOGLE_CLOUD_PROJECT_ID) \
	  --member serviceAccount:$(@:gcloud-%-storage-admin=%)@$(GOOGLE_CLOUD_PROJECT_ID).iam.gserviceaccount.com \
	  --role roles/storage.admin
.PHONY: $(ADMIN_DEVELOPPER_MEMBERS:%=gcloud-%-storage-admin)

gcloud-storage-admins: $(ADMIN_DEVELOPPER_MEMBERS:%=gcloud-%-storage-admin)
.PHONY: gcloud-storage-admins

gcloud-infra-auth-npm-install:
	@cd infra/gcloud/auth && npm install
.PHONY: gcloud-infra-auth-npm-install

gcloud-apikeys-list:
	@gcloud alpha services api-keys list
.PHONY: gcloud-apikeys-list

# Use this target to configure the Docker pluggin of Vscode if credential-helper cannot help.
gcloud-docker-registry-temporary-token:
	@echo Getting gcloud docker registry temporary access token:
	@echo  registry: $(REGISTRY)
	@echo  username: oauth2accesstoken
	@echo  password: `gcloud auth print-access-token`
.PHONY: gcloud-docker-registry-temporary-token

PROJECT_SERVICE_ACCOUNTS = \
	prod-firebase-admin-sa \
	production-application-backend \
	github-actions-main

$(PROJECT_SERVICE_ACCOUNTS:%=gcloud-%-service-account-bindings-roles):
	@echo Print bindings members roles for $(@:gcloud-%-service-account-bindings-roles=%)@$(GOOGLE_CLOUD_PROJECT_ID).iam.gserviceaccount.com:
	@gcloud projects get-iam-policy $(GOOGLE_CLOUD_PROJECT_ID) \
	  --flatten="bindings[].members" --format='table(bindings.role)' \
	  --filter="bindings.members:serviceAccount:$(@:gcloud-%-service-account-bindings-roles=%)@$(GOOGLE_CLOUD_PROJECT_ID).iam.gserviceaccount.com"
.PHONY: $(PROJECT_SERVICE_ACCOUNTS:%=gcloud-%-service-account-bindings-roles)

gcloud-service-accounts-bindings-roles: $(PROJECT_SERVICE_ACCOUNTS:%=gcloud-%-service-account-bindings-roles)
.PHONY: gcloud-service-accounts-bindings-roles

gcloud-secret-read-firebase-ui-config:
gcloud-secret-read-firebase-ui-config:

FIREBASE_UI_CONFIG_SECRET := projects/${GOOGLE_CLOUD_PROJECT_NUM}/secrets/prod-firebase-config-secret/versions/2

gcloud-secret-read-firebase-ui-config:
	gcloud secrets versions access latest --secret="$(FIREBASE_UI_CONFIG_SECRET)"
.PHONY: gcloud-secret-read-firebase-ui-config

-include gcloud/terraform.mk
