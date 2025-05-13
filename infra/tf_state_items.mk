
# This list is not exhaustive by design. Used as a debug tool... if needed.
# 
# ⚠️ 
# For calling the targets below which are containing '"' you need either 
# to escape them with a backslash like:
#  
# make module.module_abcd.resource_xyz.collection[\"example\"]-show
# make module.module_abcd.resource_xyz.collection[\"example\"]-rm
# make module.module_abcd.resource_xyz.collection[\"example\"]-apply
# ...
# 
# or use single quotes like:
# make 'module.module_abcd.resource_xyz.collection["example"]-taint'
# make 'module.module_abcd.resource_xyz.collection["example"]-untaint'
# make 'module.module_abcd.resource_xyz.collection["example"]-destroy'
TF_STATE_ITEMS = \
module.gcloud.google_apikeys_key.google_maps_android_api_key \
module.gcloud.google_apikeys_key.google_maps_ios_api_key \
module.application.google_artifact_registry_repository_iam_member.application_backend_repo_read_member \
module.gcloud.google_artifact_registry_repository_iam_member.github_actions_private_repo_read_member \
module.gcloud.google_artifact_registry_repository_iam_member.github_actions_private_repo_write_member \
module.gcloud.google_cloud_run_service.application_backend \
module.gcloud.google_cloud_run_service_iam_member.allow_unauthenticated \
module.gcloud.google_cloudfunctions_function.auth_before_create \
module.gcloud.google_cloudfunctions_function.auth_before_sign_in \
module.gcloud.google_cloudfunctions_function_iam_member.auth_before_create \
module.gcloud.google_project_iam_member.firebase_token_creator \
module.gcloud.google_project_iam_member.github_action_project_storage_admin \
module.gcloud.google_secret_manager_secret.firebase_admin_service_account_secret \emaps_api_key_secret_read \
module.application.google_secret_manager_secret_iam_member.firebase_admin_service_account_secret_member \
module.application.google_secret_manager_secret_version.firebase_adminsdk_secret_version \
module.gcloud.google_secret_manager_secret_version.firebase_config_web_version \
module.gcloud.google_secret_manager_secret_version.web_google_maps_api_key_version

$(TF_STATE_ITEMS:%=%-show): $(GOOGLE_APPLICATION_CREDENTIALS)
	@echo "🔍 Showing Terraform state for $(@:%-show=%)..."
	@$(TERRAFORM) state show '$(@:%-show=%)'
.PHONY: $(TF_STATE_ITEMS:%=%-show)

$(TF_STATE_ITEMS:%=%-rm): $(GOOGLE_APPLICATION_CREDENTIALS)
	@echo "🧹 Removing Terraform state for $(@:%-rm=%)..."
	@$(TERRAFORM) state rm '$(@:%-rm=%)'
.PHONY: $(TF_STATE_ITEMS:%=%-rm)

$(TF_STATE_ITEMS:%=%-apply): $(GOOGLE_APPLICATION_CREDENTIALS)
	@echo "🎯 Applying Terraform target $(@:%-apply=%)..."
	$(TERRAFORM) apply -target='$(@:%-apply=%)'
.PHONY: $(TF_STATE_ITEMS:%=%-apply)

$(TF_STATE_ITEMS:%=%-destroy): $(GOOGLE_APPLICATION_CREDENTIALS)
	@echo "🔥 Destroying Terraform target $(@:%-destroy=%). Use the command below by hand:"
	@echo $(TERRAFORM) destroy -target='$(@:%-destroy=%)'
.PHONY: $(TF_STATE_ITEMS:%=%-destroy)

$(TF_STATE_ITEMS:%=%-taint): $(GOOGLE_APPLICATION_CREDENTIALS)
	@echo "⚠️  Tainting Terraform target $(@:%-taint=%)..."
	@$(TERRAFORM) taint '$(@:%-taint=%)'
.PHONY: $(TF_STATE_ITEMS:%=%-taint)

$(TF_STATE_ITEMS:%=%-untaint): $(GOOGLE_APPLICATION_CREDENTIALS)
	@echo "✅ Untainting Terraform target $(@:%-untaint=%)..."
	@$(TERRAFORM) untaint '$(@:%-untaint=%)'
.PHONY: $(TF_STATE_ITEMS:%=%-untaint)

terraform-state-items-show-all: $(TF_STATE_ITEMS:%=%-show)
.PHONY: terraform-state-items-show-all

# terraform-state-rm-all: $(TF_STATE_ITEMS:%=%-rm)
# .PHONY: terraform-state-rm-all
