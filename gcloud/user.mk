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