TERRAFORM_PROJECT ?= $(CURDIR)/infra/environments/$(INFRA_ENV)

TERRAFORM = \
	TF_VAR_application_backend_image=$(APPLICATION_BACKEND_IMAGE) \
	TF_VAR_google_idp_oauth_key_secret_id=$(GOOGLE_IDP_OAUTH_KEY) \
	TF_VAR_google_idp_oauth_client_id_secret_id=$(GOOGLE_IDP_OAUTH_CLIENT_ID) \
	TF_VAR_helm_vault_chart_version=$(HELM_VAULT_CHART_VERSION) \
		terraform -chdir=$(TERRAFORM_PROJECT)

terraform-init: $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) init --upgrade
.PHONY: terraform-init

terraform-import : $(GOOGLE_APPLICATION_CREDENTIALS)
	# $(TERRAFORM) import module.gcloud.google_identity_platform_default_supported_idp_config.google "projects/moov-438615/defaultSupportedIdpConfigs/google"
	# $(TERRAFORM) import module.kubernetes.google_kms_key_ring.vault "projects/moov-438615/locations/global/keyRings/vault-keyring"
	# $(TERRAFORM) import module.kubernetes.google_kms_crypto_key.vault "projects/moov-438615/locations/global/keyRings/vault-keyring/cryptoKeys/vault-key"
.PHONY: terraform-import 

# Use this target to help updating the bellow TF_STATE_ITEMS list manually.
terraform-state-list: $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) state list
.PHONY: terraform-state-list

# This list is used to provide generic terraform targets 
TF_STATE_ITEMS =
_= \
  data.google_project.project \
  data.google_service_account.production_root_admin_service_account \
  google_apikeys_key.developer_google_maps_api_key["davidberich@gmail.com"] \
  google_project_iam_member.application_backend_vault_access \
  google_project_iam_member.artifact_registry_reader["david-berichon-dev"] \
  google_project_iam_member.artifact_registry_reader["david-berichon-prod"] \
  google_project_iam_member.artifact_registry_reader["david-berichon-staging"] \
  google_project_iam_member.artifactregistry_reader \
  google_project_iam_member.developer_service_account_roles["0"] \
  google_project_iam_member.developer_service_account_roles["1"] \
  google_project_iam_member.developer_service_account_roles["2"] \
  google_project_iam_member.developer_service_account_roles["3"] \
  google_project_iam_member.developer_service_account_roles["4"] \
  google_project_iam_member.production_root_admin \
  google_project_service.google_services_default["cloudbilling.googleapis.com"] \
  google_project_service.google_services_default["cloudbuild.googleapis.com"] \
  google_project_service.google_services_default["cloudfunctions.googleapis.com"] \
  google_project_service.google_services_default["cloudkms.googleapis.com"] \
  google_project_service.google_services_default["cloudresourcemanager.googleapis.com"] \
  google_project_service.google_services_default["compute.googleapis.com"] \
  google_project_service.google_services_default["iam.googleapis.com"] \
  google_project_service.google_services_default["identitytoolkit.googleapis.com"] \
  google_project_service.google_services_default["secretmanager.googleapis.com"] \
  google_project_service.google_services_default["serviceusage.googleapis.com"] \
  google_secret_manager_secret.developer_maps_api_secret["davidberich@gmail.com"] \
  google_secret_manager_secret_iam_member.allow_service_account_access["david-berichon-dev"] \
  google_secret_manager_secret_iam_member.allow_service_account_access["david-berichon-prod"] \
  google_secret_manager_secret_iam_member.allow_service_account_access["david-berichon-staging"] \
  google_secret_manager_secret_version.developer_maps_api_secret_version["davidberich@gmail.com"] \
  google_service_account.developer_service_account["david-berichon-dev"] \
  google_service_account.developer_service_account["david-berichon-prod"] \
  google_service_account.developer_service_account["david-berichon-staging"] \
  google_service_account_iam_member.key_admin["david-berichon-dev"] \
  google_service_account_iam_member.key_admin["david-berichon-prod"] \
  google_service_account_iam_member.key_admin["david-berichon-staging"] \
  google_storage_bucket.bucket_tf_state_eu_global \
  google_storage_bucket_iam_member.bucket_iam_member["david-berichon-dev"] \
  google_storage_bucket_iam_member.bucket_iam_member["david-berichon-prod"] \
  google_storage_bucket_iam_member.bucket_iam_member["david-berichon-staging"] \
  google_storage_bucket_iam_member.bucket_locking_iam_member["david-berichon-dev"] \
  google_storage_bucket_iam_member.bucket_locking_iam_member["david-berichon-prod"] \
  google_storage_bucket_iam_member.bucket_locking_iam_member["david-berichon-staging"] \
  module.cdn.google_compute_backend_bucket.public_cdn \
  module.cdn.google_compute_global_address.public_cdn \
  module.cdn.google_compute_global_forwarding_rule.public_cdn \
  module.cdn.google_compute_target_http_proxy.public_cdn \
  module.cdn.google_compute_url_map.url_map \
  module.cdn.google_storage_bucket.public_images \
  module.cdn.google_storage_bucket_iam_binding.web_public_image \
  module.cdn.google_storage_bucket_object.public_web_background_image \
  module.dev_members.google_project_iam_binding.admin_user_roles["apikeys_admin"] \
  module.dev_members.google_project_iam_binding.admin_user_roles["artifactregistry_admin"] \
  module.dev_members.google_project_iam_binding.admin_user_roles["cloud_kms_admin"] \
  module.dev_members.google_project_iam_binding.admin_user_roles["cloudfunction_admin"] \
  module.dev_members.google_project_iam_binding.admin_user_roles["container_cluster_admin"] \
  module.dev_members.google_project_iam_binding.admin_user_roles["datastore_owner"] \
  module.dev_members.google_project_iam_binding.admin_user_roles["firebasedatabase_admin"] \
  module.dev_members.google_project_iam_binding.admin_user_roles["firebasedatabase_viewer"] \
  module.dev_members.google_project_iam_binding.admin_user_roles["iam_admin"] \
  module.dev_members.google_project_iam_binding.admin_user_roles["identitytoolkit_admin"] \
  module.dev_members.google_project_iam_binding.admin_user_roles["roles_admin"] \
  module.dev_members.google_project_iam_binding.admin_user_roles["secret_admin"] \
  module.dev_members.google_project_iam_binding.admin_user_roles["service_account_admin"] \
  module.dev_members.google_project_iam_binding.admin_user_roles["service_account_key_admin"] \
  module.dev_members.google_project_iam_binding.admin_user_roles["service_account_token_creator"] \
  module.dev_members.google_project_iam_binding.admin_user_roles["service_account_user_as_admin"] \
  module.dev_members.google_project_iam_binding.admin_user_roles["servuceussage_consumer"] \
  module.dev_members.google_project_iam_binding.admin_user_roles["storage_admin"] \
  module.dev_members.google_project_iam_binding.editor_user_roles["artifactregistry_writer"] \
  module.dev_members.google_project_iam_binding.editor_user_roles["datastore_viewer"] \
  module.dev_members.google_project_iam_binding.editor_user_roles["global_editor"] \
  module.dev_members.google_project_iam_binding.editor_user_roles["secret_accessor"] \
  module.dev_members.google_project_iam_binding.editor_user_roles["service_account_token_creator"] \
  module.dev_members.google_project_iam_binding.editor_user_roles["storage_objectviewer"] \
  module.dev_members.google_project_iam_binding.k8s_rbac_admin_user_roles \
  module.dev_members.google_project_iam_custom_role.k8s_rbac_role \
  module.gcloud.data.archive_file.auth_func_src \
  module.gcloud.data.google_firebase_android_app.android_sha \
  module.gcloud.data.google_firebase_android_app_config.android_config \
  module.gcloud.data.google_firebase_apple_app_config.ios_config \
  module.gcloud.data.google_firebase_web_app_config.web_app_config \
  module.gcloud.data.google_project.project \
  module.gcloud.data.google_secret_manager_secret_version.google_idp_oauth_client_id \
  module.gcloud.data.google_secret_manager_secret_version.google_idp_oauth_client_secret \
  module.gcloud.data.google_storage_bucket.tf_state_global \
  module.gcloud.google_apikeys_key.google_maps_android_api_key \
  module.gcloud.google_apikeys_key.google_maps_ios_api_key \
  module.gcloud.google_apikeys_key.web_google_maps_api_key \
  module.gcloud.google_artifact_registry_repository.private_docker_repository \
  module.gcloud.google_artifact_registry_repository.public_docker_repository \
  module.gcloud.google_artifact_registry_repository_iam_member.application_backend_repo_read_member \
  module.gcloud.google_artifact_registry_repository_iam_member.github_actions_private_repo_read_member \
  module.gcloud.google_artifact_registry_repository_iam_member.github_actions_private_repo_write_member \
  module.gcloud.google_artifact_registry_repository_iam_member.github_actions_public_repo_write_member \
  module.gcloud.google_artifact_registry_repository_iam_member.public_read \
  module.gcloud.google_cloud_run_service.application_backend \
  module.gcloud.google_cloud_run_service_iam_member.allow_unauthenticated \
  module.gcloud.google_cloudfunctions_function.auth_before_create \
  module.gcloud.google_cloudfunctions_function.auth_before_sign_in \
  module.gcloud.google_cloudfunctions_function_iam_member.auth_before_create \
  module.gcloud.google_cloudfunctions_function_iam_member.auth_before_sign_in \
  module.gcloud.google_firebase_android_app.android_app \
  module.gcloud.google_firebase_apple_app.ios_app \
  module.gcloud.google_firebase_database_instance.default \
  module.gcloud.google_firebase_project.default \
  module.gcloud.google_firebase_web_app.web_app \
  module.gcloud.google_firestore_database.default \
  module.gcloud.google_identity_platform_config.default \
  module.gcloud.google_identity_platform_default_supported_idp_config.google \
  module.gcloud.google_project_iam_binding.compute_service_artifactory_reader \
  module.gcloud.google_project_iam_binding.compute_service_artifactory_writer \
  module.gcloud.google_project_iam_binding.compute_service_log_writer \
  module.gcloud.google_project_iam_custom_role.limited_service_user \
  module.gcloud.google_project_iam_member.application_backend_vault_access \
  module.gcloud.google_project_iam_member.firebase_admin_service_agent \
  module.gcloud.google_project_iam_member.firebase_token_creator \
  module.gcloud.google_project_iam_member.github_action_project_editor \
  module.gcloud.google_project_iam_member.github_action_project_secret_admin \
  module.gcloud.google_project_iam_member.github_action_project_storage_admin \
  module.gcloud.google_project_service.application_backend_services["run.googleapis.com"] \
  module.gcloud.google_project_service.google_idp_services["identitytoolkit.googleapis.com"] \
  module.gcloud.google_project_service.google_maps_services["apikeys.googleapis.com"] \
  module.gcloud.google_project_service.google_services_firebase["firebase.googleapis.com"] \
  module.gcloud.google_project_service.google_services_firebase["firebasedatabase.googleapis.com"] \
  module.gcloud.google_project_service.google_services_firebase["firestore.googleapis.com"] \
  module.gcloud.google_project_service.google_services_maps["directions-backend.googleapis.com"] \
  module.gcloud.google_project_service.google_services_maps["geocoding-backend.googleapis.com"] \
  module.gcloud.google_project_service.google_services_maps["maps-backend.googleapis.com"] \
  module.gcloud.google_project_service.google_services_maps["maps-ios-backend.googleapis.com"] \
  module.gcloud.google_secret_manager_secret.firebase_admin_service_account_secret \
  module.gcloud.google_secret_manager_secret.firebase_config_web \
  module.gcloud.google_secret_manager_secret.web_google_maps_api_key \
  module.gcloud.google_secret_manager_secret_iam_member.application_backend_firebase_adminsdk_secret_read \
  module.gcloud.google_secret_manager_secret_iam_member.application_backend_firebase_web_uiconfig_secret_read \
  module.gcloud.google_secret_manager_secret_iam_member.application_backend_wep_googlemaps_api_key_secret_read \
  module.gcloud.google_secret_manager_secret_iam_member.firebase_admin_service_account_secret_member \
  module.gcloud.google_secret_manager_secret_version.firebase_adminsdk_secret_version \
  module.gcloud.google_secret_manager_secret_version.firebase_config_web_version \
  module.gcloud.google_secret_manager_secret_version.web_google_maps_api_key_version \
  module.gcloud.google_service_account.application_backend_cloud_run_sa \
  module.gcloud.google_service_account.firebase_admin_service_account \
  module.gcloud.google_service_account.github_actions \
  module.gcloud.google_service_account_key.firebase_admin_service_account_key \
  module.gcloud.google_service_account_key.github_actions_key \
  module.gcloud.google_storage_bucket.bucket_gcf_source \
  module.gcloud.google_storage_bucket_iam_binding.bucket_iam_binding \
  module.gcloud.google_storage_bucket_iam_member.github_actions_global_tf_state_strorage_admin \
  module.gcloud.google_storage_bucket_iam_member.github_actions_public_strorage_object_user \
  module.gcloud.google_storage_bucket_object.auth \
  module.gcloud.null_resource.docker_auth \
  module.gcloud.null_resource.docker_auth_public \
  module.kubernetes.data.google_client_config.default \
  module.kubernetes.data.google_service_account_access_token.vault_gcs_token \
  module.kubernetes.data.google_service_account_id_token.vault_gcp_token \
  module.kubernetes.google_container_cluster.vault_cluster \
  module.kubernetes.google_container_node_pool.vault_cluster_nodes \
  module.kubernetes.google_kms_crypto_key.vault \
  module.kubernetes.google_kms_crypto_key_iam_member.vault_sa_key_encrypter["roles/cloudkms.cryptoKeyEncrypterDecrypter"] \
  module.kubernetes.google_kms_crypto_key_iam_member.vault_sa_key_encrypter["roles/cloudkms.signerVerifier"] \
  module.kubernetes.google_kms_key_ring.vault \
  module.kubernetes.google_kms_key_ring_iam_binding.vault_iam_kms_binding \
  module.kubernetes.google_project_iam_member.cloud_service_member["roles/compute.admin"] \
  module.kubernetes.google_project_iam_member.cloud_service_member["roles/compute.instanceAdmin.v1"] \
  module.kubernetes.google_project_iam_member.cloud_service_member["roles/compute.networkAdmin"] \
  module.kubernetes.google_project_iam_member.vault_sa_role["roles/cloudkms.cryptoKeyEncrypterDecrypter"] \
  module.kubernetes.google_project_iam_member.vault_sa_role["roles/cloudkms.signerVerifier"] \
  module.kubernetes.google_project_iam_member.vault_sa_role["roles/cloudkms.viewer"] \
  module.kubernetes.google_project_iam_member.vault_sa_role["roles/iam.serviceAccountViewer"] \
  module.kubernetes.google_project_iam_member.vault_sa_role["roles/storage.admin"] \
  module.kubernetes.google_project_iam_member.vault_tf_apply_bindings["roles/iam.serviceAccountTokenCreator"] \
  module.kubernetes.google_project_iam_member.vault_tf_apply_bindings["roles/iam.serviceAccountUser"] \
  module.kubernetes.google_project_iam_member.vault_tf_apply_bindings["roles/iam.serviceAccountViewer"] \
  module.kubernetes.google_project_iam_member.vault_tf_apply_bindings["roles/iam.workloadIdentityUser"] \
  module.kubernetes.google_project_iam_member.vault_tf_apply_bindings["roles/resourcemanager.projectIamAdmin"] \
  module.kubernetes.google_project_iam_member.vault_tf_apply_bindings["roles/storage.admin"] \
  module.kubernetes.google_project_iam_member.vault_tf_apply_bindings["roles/storage.objectUser"] \
  module.kubernetes.google_project_iam_member.vault_tf_apply_bindings["roles/viewer"] \
  module.kubernetes.google_project_service.google_k8s_cluster_services["container.googleapis.com"] \
  module.kubernetes.google_project_service.google_k8s_cluster_services["iamcredentials.googleapis.com"] \
  module.kubernetes.google_service_account.cluster_node_sa \
  module.kubernetes.google_service_account.vault_sa \
  module.kubernetes.google_service_account.vault_tf_apply_sa \
  module.kubernetes.google_service_account_iam_binding.name \
  module.kubernetes.google_service_account_iam_member.vault_tf_apply_token_creator["roles/iam.serviceAccountTokenCreator"] \
  module.kubernetes.google_service_account_iam_member.vault_tf_apply_token_creator["roles/iam.serviceAccountUser"] \
  module.kubernetes.google_service_account_iam_member.vault_tf_apply_token_creator["roles/iam.serviceAccountViewer"] \
  module.kubernetes.google_service_account_iam_member.vault_tf_apply_token_creator["roles/iam.workloadIdentityUser"] \
  module.kubernetes.google_service_account_key.vault_sa_key \
  module.kubernetes.google_service_account_key.vault_tf_apply_sa_key \
  module.kubernetes.helm_release.consul \
  module.kubernetes.helm_release.vault \
  module.kubernetes.kubernetes_config_map.vault_tf_code \
  module.kubernetes.kubernetes_job.vault_init_job \
  module.kubernetes.kubernetes_namespace.vault \
  module.kubernetes.kubernetes_secret.vault_init_script \
  module.kubernetes.kubernetes_secret.vault_service_account \
  module.kubernetes.kubernetes_secret.vault_tf_apply_gcp_id_token \
  module.kubernetes.kubernetes_secret.vault_tf_apply_gcs_token \
  module.kubernetes.kubernetes_secret.vault_tf_apply_sa_secret \
  module.kubernetes.kubernetes_service_account.vault_tf_apply \
  module.production_members.google_project_iam_binding.admin_user_roles["apikeys_admin"] \
  module.production_members.google_project_iam_binding.admin_user_roles["artifactregistry_admin"] \
  module.production_members.google_project_iam_binding.admin_user_roles["cloud_kms_admin"] \
  module.production_members.google_project_iam_binding.admin_user_roles["cloudfunction_admin"] \
  module.production_members.google_project_iam_binding.admin_user_roles["container_cluster_admin"] \
  module.production_members.google_project_iam_binding.admin_user_roles["datastore_owner"] \
  module.production_members.google_project_iam_binding.admin_user_roles["firebasedatabase_admin"] \
  module.production_members.google_project_iam_binding.admin_user_roles["firebasedatabase_viewer"] \
  module.production_members.google_project_iam_binding.admin_user_roles["iam_admin"] \
  module.production_members.google_project_iam_binding.admin_user_roles["identitytoolkit_admin"] \
  module.production_members.google_project_iam_binding.admin_user_roles["roles_admin"] \
  module.production_members.google_project_iam_binding.admin_user_roles["secret_admin"] \
  module.production_members.google_project_iam_binding.admin_user_roles["service_account_admin"] \
  module.production_members.google_project_iam_binding.admin_user_roles["service_account_key_admin"] \
  module.production_members.google_project_iam_binding.admin_user_roles["service_account_token_creator"] \
  module.production_members.google_project_iam_binding.admin_user_roles["service_account_user_as_admin"] \
  module.production_members.google_project_iam_binding.admin_user_roles["servuceussage_consumer"] \
  module.production_members.google_project_iam_binding.admin_user_roles["storage_admin"] \
  module.production_members.google_project_iam_binding.editor_user_roles["artifactregistry_writer"] \
  module.production_members.google_project_iam_binding.editor_user_roles["datastore_viewer"] \
  module.production_members.google_project_iam_binding.editor_user_roles["global_editor"] \
  module.production_members.google_project_iam_binding.editor_user_roles["secret_accessor"] \
  module.production_members.google_project_iam_binding.editor_user_roles["service_account_token_creator"] \
  module.production_members.google_project_iam_binding.editor_user_roles["storage_objectviewer"] \
  module.production_members.google_project_iam_binding.k8s_rbac_admin_user_roles \
  module.production_members.google_project_iam_custom_role.k8s_rbac_role \
  module.staging_members.google_project_iam_binding.admin_user_roles["apikeys_admin"] \
  module.staging_members.google_project_iam_binding.admin_user_roles["artifactregistry_admin"] \
  module.staging_members.google_project_iam_binding.admin_user_roles["cloud_kms_admin"] \
  module.staging_members.google_project_iam_binding.admin_user_roles["cloudfunction_admin"] \
  module.staging_members.google_project_iam_binding.admin_user_roles["container_cluster_admin"] \
  module.staging_members.google_project_iam_binding.admin_user_roles["datastore_owner"] \
  module.staging_members.google_project_iam_binding.admin_user_roles["firebasedatabase_admin"] \
  module.staging_members.google_project_iam_binding.admin_user_roles["firebasedatabase_viewer"] \
  module.staging_members.google_project_iam_binding.admin_user_roles["iam_admin"] \
  module.staging_members.google_project_iam_binding.admin_user_roles["identitytoolkit_admin"] \
  module.staging_members.google_project_iam_binding.admin_user_roles["roles_admin"] \
  module.staging_members.google_project_iam_binding.admin_user_roles["secret_admin"] \
  module.staging_members.google_project_iam_binding.admin_user_roles["service_account_admin"] \
  module.staging_members.google_project_iam_binding.admin_user_roles["service_account_key_admin"] \
  module.staging_members.google_project_iam_binding.admin_user_roles["service_account_token_creator"] \
  module.staging_members.google_project_iam_binding.admin_user_roles["service_account_user_as_admin"] \
  module.staging_members.google_project_iam_binding.admin_user_roles["servuceussage_consumer"] \
  module.staging_members.google_project_iam_binding.admin_user_roles["storage_admin"] \
  module.staging_members.google_project_iam_binding.editor_user_roles["artifactregistry_writer"] \
  module.staging_members.google_project_iam_binding.editor_user_roles["datastore_viewer"] \
  module.staging_members.google_project_iam_binding.editor_user_roles["global_editor"] \
  module.staging_members.google_project_iam_binding.editor_user_roles["secret_accessor"] \
  module.staging_members.google_project_iam_binding.editor_user_roles["service_account_token_creator"] \
  module.staging_members.google_project_iam_binding.editor_user_roles["storage_objectviewer"] \
  module.staging_members.google_project_iam_binding.k8s_rbac_admin_user_roles \
  module.staging_members.google_project_iam_custom_role.k8s_rbac_role

$(TF_STATE_ITEMS:%=%-show): $(GOOGLE_APPLICATION_CREDENTIALS)
	$(TERRAFORM) state show $(@:%-show=%)
.PHONY: $(TF_STATE_ITEMS:%=%-show)

$(TF_STATE_ITEMS:%=%-rm): $(GOOGLE_APPLICATION_CREDENTIALS)
	$(TERRAFORM) state rm $(@:%-rm=%)
.PHONY: $(TF_STATE_ITEMS:%=%-rm)

$(TF_STATE_ITEMS:%=%-apply): $(GOOGLE_APPLICATION_CREDENTIALS)
	@echo $(TERRAFORM) apply -target=$(@:%-apply=%)
.PHONY: $(TF_STATE_ITEMS:%=%-apply)

$(TF_STATE_ITEMS:%=%-destroy): $(GOOGLE_APPLICATION_CREDENTIALS)
	@echo $(TERRAFORM) destroy -target=$(@:%-destroy=%)
.PHONY: $(TF_STATE_ITEMS:%=%-destroy)

$(TF_STATE_ITEMS:%=%-taint): $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) taint $(@:%-taint=%)
.PHONY: $(TF_STATE_ITEMS:%=%-taint)

$(TF_STATE_ITEMS:%=%-untaint): $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) untaint $(@:%-untaint=%)
.PHONY: $(TF_STATE_ITEMS:%=%-untaint)

terraform-taint-backend: module.gcloud.google_cloud_run_service.application_backend-taint
.PHONY: terraform-taint-backend

terraform-state-show-all : $(TF_STATE_ITEMS:%=%-show)
.PHONY: terraform-state-show-all

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
	@$(TERRAFORM) init -upgrade
.PHONY: terraform-upgrade

terraform-reconfigure: $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) init -reconfigure
.PHONY: terraform-reconfigure

terraform-plan: $(GOOGLE_APPLICATION_CREDENTIALS)
	$(TERRAFORM) plan -out=$(TERRAFORM_PROJECT)/.planed_terraform
.PHONY: terraform-plan

terraform-unlock: $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) force-unlock $(LOCK_ID)
.PHONY: terraform-unlock

terraform-providers: $(GOOGLE_APPLICATION_CREDENTIALS)
	$(TERRAFORM) providers -v
.PHONY: terraform-providers

terraform-validate: $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) validate
.PHONY: terraform-validate

terraform-refresh: $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) refresh
.PHONY: terraform-refresh

terraform-migrate-state: $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) init --migrate-state
.PHONY: terraform-migrate-state

terraform-apply-auto-approve: $(GOOGLE_APPLICATION_CREDENTIALS)
	$(TERRAFORM) apply -auto-approve # $(TERRAFORM_PROJECT)/.planed_terraform
.PHONY: terraform-apply-auto-approve

terraform-output-json: $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) output -json
.PHONY: terraform-output-json

terraform-destroy: $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) destroy
.PHONY: terraform-destroy

terraform-state-backup: $(GOOGLE_APPLICATION_CREDENTIALS)
	@$(TERRAFORM) state pull > $(TERRAFORM_PROJECT)/backup.tfstate
.PHONY: terraform-state-backup

terraform-output-github-actions-private-key:
	@$(TERRAFORM) output -json | jq '.github_actions_private_key.value' | sed 's/\"//g' | base64 --decode 
.PHONY: terraform-output-github-actions-private-key

$(APPLICATION_MOBILE_FIREBASE_ANDROID_CONFIG_JSON): terraform-output-firebase-android-config-json

$(INFRA_FIREBASE_ANDROID_CONFIG_JSON): terraform-output-firebase-android-config-json

terraform-output-firebase-android-config-json:
	@echo Creating Android configuration for "'$(INFRA_ENV)'": "'$(INFRA_FIREBASE_ANDROID_CONFIG_JSON)'"
	@$(TERRAFORM) output firebase_android_config_json | sed -e '1d' -e '$$d' -e '/^$$/d' > $(INFRA_FIREBASE_ANDROID_CONFIG_JSON)
.PHONY: terraform-output-firebase-android-config-json

$(INFRA_FIREBASE_IOS_CONFIG_PLIST): terraform-output-firebase-ios-config-plist

terraform-output-firebase-ios-config-plist: 
	@echo Creating iOS configuration for "'$(INFRA_ENV)'": "'$(INFRA_FIREBASE_IOS_CONFIG_PLIST)'"
	@$(TERRAFORM) output firebase_ios_config_plist | sed -e '1d' -e '$$d' -e '/^$$/d' > $(INFRA_FIREBASE_IOS_CONFIG_PLIST)
.PHONY: terraform-output-firebase-ios-config-plist

terraform-console:
	$(TERRAFORM) console
.PHONY: terraform-console
