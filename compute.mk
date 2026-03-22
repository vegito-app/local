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
