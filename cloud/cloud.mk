GOOGLE_CLOUD_APPLICATION_CREDENTIALS := $(CURDIR)/cloud/google-cloud-credentials

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
	  --source=$(CURDIR)/cloud/infra/auth \
	  --entry-point=idp.go \
	  --trigger-http
.PHONY: gcloud-auth-func-deploy

GOOGLE_SERVICES_API = serviceusage cloudbilling

gcloud-services-apis-enable: $(GOOGLE_SERVICES_API:%=gcloud-services-enable-%-api)
.PHONY: gcloud-services-apis-enable

gcloud-services-apis-disable: $(GOOGLE_SERVICES_API:%=gcloud-services-disable-%-api)
.PHONY: gcloud-services-apis-disable

FIREBASE_ADMINSDK_SERVICEACCOUNT = firebase-adminsdk-vxdj8@utrade-taxi-run-0.iam.gserviceaccount.com

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

TERRAFORM = \
	TF_VAR_firebase_adminsdk_credentials=$$FIREBASE_ADMINSDK_CREDENTIALS \
	TF_VAR_google_cloud_idp_google_web_auth_secret=$(GOOGLE_CLOUD_WEB_IDP_GOOGLE_OAUTH_SECRET) \
	TF_VAR_application_image=$(BACKEND_IMAGE) \
	TF_VAR_create_secret=true \
	terraform -chdir=./cloud

terraform-init: $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) init --upgrade
.PHONY: terraform-init

terraform-import: $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)
	# @$(TERRAFORM) import module.secrets.google_identity_platform_default_supported_idp_config.google projects/$(PROJECT_ID)/defaultSupportedIdpConfigs/google.com
	# @$(TERRAFORM) import module.infra.google_identity_platform_config.utrade $(PROJECT_ID)
	# @$(TERRAFORM) import module.infra.google_secret_manager_secret.firebase_adminsdk_service_account projects/402960374845/secrets/firebase-adminsdk-serviceaccount
	# @$(TERRAFORM) import module.infra.google_firebase_database_instance.utrade $(PROJECT_ID)/$(REGION)/$(PROJECT_ID)-default-rtdb
	# @$(TERRAFORM) import module.infra.google_firebase_database_instance.utrade projects/$(PROJECT_ID)/locations/$(REGION)/instances/$(PROJECT_ID)-default-rtdb
	# @$(TERRAFORM) import google_service_account.firebase_admin projects/$(PROJECT_ID)/firebase-adminsdk-vxdj8@$(PROJECT_ID).iam.gserviceaccount.com
	# @$(TERRAFORM) import module.infra.google_cloudfunctions_function.utrade_auth_before_sign_in projects/utrade-taxi-run-0/locations/us-central1/functions/utrade-us-central1-identity-platform
	@$(TERRAFORM) import module.secrets.google_secret_manager_secret_version.google_idp_secret_version[0] projects/402960374845/secrets/idp_google_secret_id/versions/1
.PHONY: terraform-import

terraform-state-rm: $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) state rm module.infra.google_firebase_database_instance.utrade
.PHONY: terraform-state-rm

terraform-state-list: $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) state list
.PHONY: terraform-state-list

TF_STATE_ITEMS = google_project.utrade \
  google_storage_bucket.bucket_tf_state \
  module.infra.data.archive_file.utrade_auth_func_src \
  module.infra.google_artifact_registry_repository.utrade \
  module.infra.google_cloud_run_service.utrade \
  module.infra.google_cloud_run_service_iam_member.allow_unauthenticated \
  module.infra.google_cloudfunctions_function.utrade_auth_before_create \
  module.infra.google_cloudfunctions_function.utrade_auth_before_sign_in \
  module.infra.google_cloudfunctions_function_iam_member.auth_before_create \
  module.infra.google_cloudfunctions_function_iam_member.auth_before_sign_in \
  module.infra.google_firebase_android_app.utrade \
  module.infra.google_firebase_apple_app.utrade \
  module.infra.google_firebase_database_instance.utrade \
  module.infra.google_firebase_project.utrade \
  module.infra.google_firebase_web_app.utrade \
  module.infra.google_identity_platform_config.utrade \
  module.infra.google_project_iam_custom_role.limited_service_user \
  module.infra.google_project_iam_member.firebase_admin_service_agent \
  module.infra.google_project_iam_member.firebase_token_creator \
  module.infra.google_project_service.utrade["cloudbilling.googleapis.com"] \
  module.infra.google_project_service.utrade["cloudbuild.googleapis.com"] \
  module.infra.google_project_service.utrade["cloudfunctions.googleapis.com"] \
  module.infra.google_project_service.utrade["cloudresourcemanager.googleapis.com"] \
  module.infra.google_project_service.utrade["firebase.googleapis.com"] \
  module.infra.google_project_service.utrade["firebasedatabase.googleapis.com"] \
  module.infra.google_project_service.utrade["firestore.googleapis.com"] \
  module.infra.google_project_service.utrade["identitytoolkit.googleapis.com"] \
  module.infra.google_project_service.utrade["secretmanager.googleapis.com"] \
  module.infra.google_project_service.utrade["serviceusage.googleapis.com"] \
  module.infra.google_service_account.firebase_admin \
  module.infra.google_storage_bucket.bucket_gcf_source \
  module.infra.google_storage_bucket_object.utrade_auth \
  module.infra.null_resource.docker_auth \
  module.secrets.google_identity_platform_default_supported_idp_config.google[0]

$(TF_STATE_ITEMS:%=%-show): $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) state show $(@:%-show=%)
.PHONY: $(TF_STATE_ITEMS:%=%-show)

terraform-state-show-all : $(TF_STATE_ITEMS:%=%-show)
.PHONY: terraform-state-show

terraform-state-show: $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)
	$(TERRAFORM) state show module.infra.google_firebase_database_instance.utrade
.PHONY: terraform-state-show

terraform-upgrade: $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) init -upgrade
.PHONY: terraform-upgrade

terraform-plan: $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) plan
.PHONY: terraform-plan

terraform-unlock: $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) force-unlock $(LOCK_ID)
.PHONY: terraform-unlock

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

cloud-infra-auth-npm-install:
	@cd cloud/infra/auth && npm install
.PHONY: cloud-infra-auth-npm-install