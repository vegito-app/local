GCLOUD_PROJECT_DOCKER_REGISTRY ?= $(GOOGLE_CLOUD_DOCKER_REGISTRY)/$(GOOGLE_CLOUD_PROJECT_ID)

# Use this target to configure the Docker pluggin of Vscode if credential-helper cannot help.
gcloud-docker-registry-temporary-token:
	@echo Getting $(GCLOUD) docker registry temporary access token:
	@echo  registry: $(GCLOUD_PROJECT_DOCKER_REGISTRY)
	@echo  username: oauth2accesstoken
	@echo  password: `$(GCLOUD) auth print-access-token`
.PHONY: gcloud-docker-registry-temporary-token

GCLOUD_DOCKER_REPOSITORIES ?= \
  docker-repository-cache \
  docker-repository-public \
  docker-repository-private

gcloud-images-list: $(GCLOUD_DOCKER_REPOSITORIES:%=gcloud-%-images-list)
.PHONY: gcloud-images-list
  
$(GCLOUD_DOCKER_REPOSITORIES:%=gcloud-%-images-list):
	@echo "📦 Listing all '$(GOOGLE_CLOUD_PROJECT_ID)' images in repository $(@:gcloud-%-images-list=%)..."
	@$(GCLOUD) container images list --repository=$(GCLOUD_PROJECT_DOCKER_REGISTRY)/$(@:gcloud-%-images-list=%)
.PHONY: $(GCLOUD_DOCKER_REPOSITORIES:%=gcloud-%-images-list)

gcloud-images-list-tags: $(GCLOUD_DOCKER_REPOSITORIES:%=gcloud-%-images-list-tags)
.PHONY: gcloud-images-list-tags

$(GCLOUD_DOCKER_REPOSITORIES:%=gcloud-%-images-list-tags):
	@echo "🏷️  Listing '$(GOOGLE_CLOUD_PROJECT_ID)' tags for image base $(@:gcloud-%-images-list-tags=%)..."
	@$(GCLOUD) container images list-tags $(GCLOUD_PROJECT_DOCKER_REGISTRY)/$(@:gcloud-%-images-list-tags=%)
.PHONY: $(GCLOUD_DOCKER_REPOSITORIES:%=gcloud-%-images-list-tags)

gcloud-images-delete-all-tags: $(GCLOUD_DOCKER_REPOSITORIES:%=gcloud-%-images-delete-all-tags)
.PHONY: gcloud-images-delete-all-tags

$(GCLOUD_DOCKER_REPOSITORIES:%=gcloud-%-images-delete-all-tags):
	@echo "🗑️  Deleting all '$(GOOGLE_CLOUD_PROJECT_ID)' images from repository $(@:gcloud-%-images-delete-all-tags=%)..."
	@$(GCLOUD) artifacts docker images list \
      --project=$(GOOGLE_CLOUD_PROJECT_ID) \
      --format='get(package)' \
      $(GCLOUD_PROJECT_DOCKER_REGISTRY)/$(@:gcloud-%-images-delete-all-tags=%) \
      | uniq \
      | xargs -I {} $(GCLOUD) artifacts docker images delete {} --delete-tags --quiet --project=$(GOOGLE_CLOUD_PROJECT_ID)
.PHONY: $(GCLOUD_DOCKER_REPOSITORIES:%=gcloud-%-images-delete-all-tags)

gcloud-docker-registry-cleanup: $(GCLOUD_DOCKER_REPOSITORIES:%=gcloud-docker-registry-cleanup-%)
.PHONY: gcloud-docker-registry-cleanup

$(GCLOUD_DOCKER_REPOSITORIES:%=gcloud-docker-registry-cleanup-%):
	@echo "🗑️  Deleting all '$(GOOGLE_CLOUD_PROJECT_ID)' images without 'latest' or 'current' tags from repository $(@:gcloud-docker-registry-cleanup-%=%)..."
	@PROJECT=$(GOOGLE_CLOUD_PROJECT_ID) \
	  REGION=$(GOOGLE_CLOUD_REGION) \
	  REPO=$(GCLOUD_PROJECT_DOCKER_REGISTRY)/$(@:gcloud-docker-registry-cleanup-%=%) \
	  $(VEGITO_GCLOUD_DIR)/docker-registry-cleanup.sh
.PHONY: $(GCLOUD_DOCKER_REPOSITORIES:%=gcloud-docker-registry-cleanup-%)
