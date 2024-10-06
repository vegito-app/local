GOOGLE_CLOUD_APPLICATION_CREDENTIALS ?= $(PWD)/infra/gcloud-credentials

google-application-credentials:
	@bash -c 'echo -n $$GOOGLE_CLOUD_CREDENTIALS' | jq > $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)
.PHONY: google-application-credentials

$(GOOGLE_CLOUD_APPLICATION_CREDENTIALS): 
	@$(MAKE) google-application-credentials

gcloud-auth-login:
	@gcloud auth login
	@gcloud config set project $(PROJECT_ID)
.PHONY: gcloud-auth-login

gcloud-auth-default-application-credentials:
	@gcloud auth application-default login
	@gcloud config set project $(PROJECT_ID)
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
	@gcloud container images delete --force-delete-tags $(BACKEND_IMAGE)
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
	  --region=$(REGION) \
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
  firebase-adminsdk-vxdj8@utrade-taxi-run-0.iam.gserviceaccount.com

gcloud-firebase-adminsdk-serviceaccount-roles-list:
	@gcloud projects get-iam-policy $(PROJECT_ID) \
	  --flatten="bindings[].members" \
	  --format='table(bindings.role)' \
	  --filter="bindings.members:$(FIREBASE_ADMINSDK_SERVICEACCOUNT)"
.PHONY: gcloud-firebase-adminsdk-serviceaccount-roles-list

$(GOOGLE_SERVICES_API:%=gcloud-services-enable-%-api):
	@gcloud services enable $(@:gcloud-services-enable-%-api=%).googleapis.com --project=$(PROJECT_ID)
.PHONY: $(GOOGLE_SERVICES_API:%=gcloud-services-enable-%-api)

$(GOOGLE_SERVICES_API:%=gcloud-services-disable-%-api):
	@gcloud services disable $(@:gcloud-services-disable-%-api=%).googleapis.com --project=$(PROJECT_ID)
.PHONY: $(GOOGLE_SERVICES_API:%=gcloud-services-disable-%-api)

ADMIN_DEVELOPPER_MEMBERS := \
  admin-developper-utrade

$(ADMIN_DEVELOPPER_MEMBERS:%=gcloud-%-storage-admin):
	@gcloud projects add-iam-policy-binding $(PROJECT_ID) \
	  --member serviceAccount:$(@:gcloud-%-storage-admin=%)@$(PROJECT_ID).iam.gserviceaccount.com \
	  --role roles/storage.admin
.PHONY: $(ADMIN_DEVELOPPER_MEMBERS:%=gcloud-%-storage-admin)

gcloud-storage-admins: $(ADMIN_DEVELOPPER_MEMBERS:%=gcloud-%-storage-admin)
.PHONY: gcloud-storage-admins

gcloud-infra-auth-npm-install:
	@cd infra/gcloud/auth && npm install
.PHONY: gcloud-infra-auth-npm-install

# Use this target to configure the Docker pluggin of Vscode if credential-helper cannot help.
gcloud-docker-registry-temporary-token:
	@echo Getting gcloud docker registry temporary access token:
	@echo  registry: $(REGISTRY)
	@echo  username: oauth2accesstoken
	@echo  password: `gcloud auth print-access-token`
.PHONY: gcloud-docker-registry-temporary-token

-include gcloud/terraform.mk