GOOGLE_CLOUD_REGION ?= europe-west1
REGISTRY ?= $(GOOGLE_CLOUD_REGION)-docker.pkg.dev
LOCAL_IMAGES_BASE ?= $(GOOGLE_CLOUD_PROJECT_ID)

PUBLIC_REPOSITORY ?= $(REGISTRY)/$(GOOGLE_CLOUD_PROJECT_ID)/docker-repository-public
PUBLIC_IMAGES_BASE ?= $(PUBLIC_REPOSITORY)/$(LOCAL_IMAGES_BASE)

PRIVATE_REPOSITORY ?= $(REGISTRY)/$(GOOGLE_CLOUD_PROJECT_ID)/docker-repository-private
PRIVATE_IMAGES_BASE ?= $(PRIVATE_REPOSITORY)/$(LOCAL_IMAGES_BASE)

LOCAL_APPLICATION_IMAGES_WORKERS_DOCKER_BUILDX_BAKE_IMAGES = \
  application-images-cleaner  \
  application-images-moderator

LOCAL_DOCKER_BUILDX_BAKE_IMAGES ?= \
  android-studio \
  clarinet-devnet \
  application-tests \
  firebase-emulators \
  vault-dev 

LOCAL_DOCKER_BUILDX_BAKE ?= docker buildx bake \
	-f $(LOCAL_DIR)/docker/docker-bake.hcl \
	-f $(LOCAL_DIR)/docker-bake.hcl \
	$(LOCAL_DOCKER_BUILDX_BAKE_IMAGES:%=-f $(LOCAL_DIR)/%/docker-bake.hcl) \
	$(LOCAL_APPLICATION_IMAGES_WORKERS_DOCKER_BUILDX_BAKE_IMAGES:application-images-%=-f $(LOCAL_DIR)/application/images/%/docker-bake.hcl) \
	$(LOCAL_APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:application-%=-f $(LOCAL_DIR)/application/%/docker-bake.hcl) \
	-f $(LOCAL_DIR)/github/docker-bake.hcl

local-services-push-multi-arch-images: docker-buildx-setup local-builder-image-ci
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print services-push-multi-arch
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push services-push-multi-arch
.PHONY: local-services-push-multi-arch-images

docker-images-local-arch: local-builder-image
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print services-load-local-arch
	@$(LOCAL_DOCKER_BUILDX_BAKE) --load services-load-local-arch
.PHONY: docker-images-local-arch

docker-buildx-setup: 
	@-docker buildx create --name $(GOOGLE_CLOUD_PROJECT_ID)-builder 2>/dev/null 
	@-docker buildx use $(GOOGLE_CLOUD_PROJECT_ID)-builder 2>/dev/null 
.PHONY: docker-buildx-setup

docker-login: gcloud-auth-docker
	@docker login $(REGISTRY)/$(GOOGLE_CLOUD_PROJECT_ID)
.PHONY: docker-login

docker-sock:
	@echo "Setting permissions for Docker socket..."
	sudo chmod o+rw /var/run/docker.sock
.PHONY: docker-sock

$(LOCAL_DOCKER_BUILDX_BAKE_IMAGES:%=local-%-image): docker-buildx-setup
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:local-%-image=%)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --load $(@:local-%-image=%)
.PHONY: $(LOCAL_DOCKER_BUILDX_BAKE_IMAGES:%=local-%-image)

$(LOCAL_DOCKER_BUILDX_BAKE_IMAGES:%=local-%-image-push):
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:local-%-image-push=%)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push $(@:local-%-image-push=%)
.PHONY: $(LOCAL_DOCKER_BUILDX_BAKE_IMAGES:%=local-%-image-push)

# $(LOCAL_DOCKER_BUILDX_BAKE_IMAGES:%=local-%-image-pull):
# 	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:local-%-image-pull=%)
# 	@$(LOCAL_DOCKER_BUILDX_BAKE) --pull $(@:local-%-image-pull=%)
# .PHONY: $(LOCAL_DOCKER_BUILDX_BAKE_IMAGES:%=local-%-image-pull)

$(LOCAL_DOCKER_BUILDX_BAKE_IMAGES:%=local-%-image-ci): docker-buildx-setup
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:local-%-image-ci=%-ci)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push $(@:local-%-image-ci=%-ci)
.PHONY: $(LOCAL_DOCKER_BUILDX_BAKE_IMAGES:%=local-%-image-ci)

local-builder-image: $(LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_CACHE) docker-buildx-setup
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print builder
	@$(LOCAL_DOCKER_BUILDX_BAKE) --load builder
.PHONY: local-builder-image

local-builder-image-push: docker-buildx-setup
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print builder
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push builder
.PHONY: local-builder-image-push

local-builder-image-ci: docker-buildx-setup
	env | grep -i local_images_base
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print builder-ci
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push builder-ci
.PHONY: local-builder-image-ci
