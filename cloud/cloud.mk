GOOGLE_CLOUD_APPLICATION_CREDENTIALS := $(CURDIR)/cloud/google-cloud-credentials

google-application-credentials:
	@bash -c 'echo -n $$GOOGLE_CLOUD_CREDENTIALS' | jq > $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)
.PHONY: google-application-credentials

GOOGLE_CLOUD_CREDENTIALS ?= $(UTRADE_GOOGLE_CLOUD_CREDENTIALS)

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

gcloud-images-builder-untag-all:
	@gcloud container images list-tags $(IMAGES_BASE) --format='get(digest)' \
	| xargs -I {} gcloud container images untag $(IMAGES_BASE)@{}
.PHONY: gcloud-images-builder-untag-all

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
	  --source=$(CURDIR)/cloud/infra/go/auth \
	  --entry-point=idp.go \
	  --trigger-http
.PHONY: gcloud-auth-func-deploy

GOOGLE_SERVICES_API = serviceusage cloudbilling

gcloud-services-apis-enable: $(GOOGLE_SERVICES_API:%=gcloud-services-enable-%-api)
.PHONY: gcloud-services-apis-enable

gcloud-services-apis-disable: $(GOOGLE_SERVICES_API:%=gcloud-services-disable-%-api)
.PHONY: gcloud-services-apis-disable

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

TERRAFORM = \
	GOOGLE_APPLICATION_CREDENTIALS=$(GOOGLE_CLOUD_APPLICATION_CREDENTIALS) \
	TF_VAR_google_cloud_idp_google_web_auth_secret=$(UTRADE_GOOGLE_CLOUD_WEB_IDP_GOOGLE_OAUTH_SECRET) \
	TF_VAR_application_image=$(BACKEND_IMAGE) \
	TF_VAR_create_secret=true \
	terraform -chdir=./cloud

terraform-init: $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) init --upgrade
.PHONY: terraform-init

terraform-import: $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) import module.secrets.google_identity_platform_default_supported_idp_config.google projects/$(PROJECT_ID)/defaultSupportedIdpConfigs/google.com
	@$(TERRAFORM) import module.infra.google_identity_platform_config.utrade $(PROJECT_ID)
	@$(TERRAFORM) import module.infra.google_firebase_database_instance.utrade $(PROJECT_ID)/$(REGION)/$(PROJECT_ID)-default-rtdb
.PHONY: terraform-import

terraform-upgrade: $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) init -upgrade
.PHONY: terraform-upgrade

terraform-plan: $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) plan
.PHONY: terraform-plan

terraform-providers: $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) providers -v
.PHONY: terraform-providers

terraform-validate: $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) validate
.PHONY: terraform-validate

terraform-refresh: $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) refresh
.PHONY: terraform-refresh

terraform-apply-auto-approve: $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) apply -auto-approve
.PHONY: terraform-apply-auto-approve

terraform-destroy: $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) destroy
.PHONY: terraform-destroy

terraform-state-backup: $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) state pull > $(CURDIR)/cloud/backup.tfstate
.PHONY: terraform-state-backup

