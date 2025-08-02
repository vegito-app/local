GOOGLE_CLOUD_REGION ?= europe-west1
GOOGLE_CLOUD_DOCKER_REGISTRY ?= $(GOOGLE_CLOUD_REGION)-docker.pkg.dev
LOCAL_IMAGES_BASE ?= $(GOOGLE_CLOUD_PROJECT_ID)

PUBLIC_REPOSITORY ?= $(GOOGLE_CLOUD_DOCKER_REGISTRY)/$(GOOGLE_CLOUD_PROJECT_ID)/docker-repository-public
PUBLIC_IMAGES_BASE ?= $(PUBLIC_REPOSITORY)/$(LOCAL_IMAGES_BASE)

PRIVATE_REPOSITORY ?= $(GOOGLE_CLOUD_DOCKER_REGISTRY)/$(GOOGLE_CLOUD_PROJECT_ID)/docker-repository-private
PRIVATE_IMAGES_BASE ?= $(PRIVATE_REPOSITORY)/$(LOCAL_IMAGES_BASE)

LOCAL_DOCKER_BUILDX_BAKE ?= docker buildx bake \
	-f $(LOCAL_DIR)/docker/docker-bake.hcl \
	-f $(LOCAL_DIR)/docker-bake.hcl \
	$(LOCAL_DOCKER_BUILDX_BAKE_IMAGES:%=-f $(LOCAL_DIR)/%/docker-bake.hcl) \
	$(LOCAL_APPLICATION_IMAGES_WORKERS_DOCKER_BUILDX_BAKE_IMAGES:application-images-%=-f $(LOCAL_DIR)/application/images/%/docker-bake.hcl) \
	$(LOCAL_APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:application-%=-f $(LOCAL_DIR)/application/%/docker-bake.hcl) \
	-f $(LOCAL_DIR)/github/docker-bake.hcl

local-services-multi-arch-push-images: docker-buildx-setup local-builder-image-ci
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print local-services-multi-arch-push
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push local-services-multi-arch-push
.PHONY: local-services-multi-arch-push-images

docker-images-local-arch: local-builder-image
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print local-services-host-arch-load
	@$(LOCAL_DOCKER_BUILDX_BAKE) --load local-services-host-arch-load
.PHONY: docker-images-local-arch

docker-buildx-setup: 
	@-docker buildx create --name $(GOOGLE_CLOUD_PROJECT_ID)-builder 2>/dev/null 
	@-docker buildx use $(GOOGLE_CLOUD_PROJECT_ID)-builder 2>/dev/null 
.PHONY: docker-buildx-setup

docker-login: gcloud-auth-docker
	@docker login $(GOOGLE_CLOUD_DOCKER_REGISTRY)/$(GOOGLE_CLOUD_PROJECT_ID)
.PHONY: docker-login

docker-sock:
	@echo "Setting permissions for Docker socket..."
	sudo chmod o+rw /var/run/docker.sock
.PHONY: docker-sock

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

LOCAL_APPLICATION_DOCKER_BUILDX_BAKE_IMAGES = \
	application-backend \
#   application-mobile

LOCAL_DOCKER_BUILDX_BAKE_IMAGES ?= \
  android-studio \
  clarinet-devnet \
  application-tests \
  firebase-emulators \
  vault-dev 

# LOCAL_APPLICATION_IMAGES_WORKERS_DOCKER_BUILDX_BAKE_IMAGES = \
#   application-images-cleaner  \
#   application-images-moderator

$(LOCAL_APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:application-%=application-%-image): docker-buildx-setup
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:application-%-image=application-%)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --load $(@:application-%-image=application-%)
.PHONY: $(LOCAL_APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:application-%=application-%-image)

$(LOCAL_APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:application-%=application-%-image-push):
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:application-%-image-push=application-%)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push $(@:application-%-image-push=application-%)
.PHONY: $(LOCAL_APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:application-%=application-%-image-push)

$(LOCAL_APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:application-%=application-%-image-ci): docker-buildx-setup
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:application-%-image-ci=application-%-ci)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push $(@:application-%-image-ci=application-%-ci)
.PHONY: $(LOCAL_APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:application-%=application-%-image-ci)


# $(LOCAL_APPLICATION_IMAGES_WORKERS_DOCKER_BUILDX_BAKE_IMAGES:application-%=application-%-image): docker-buildx-setup
# 	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:application-%-image=application-%)
# 	@$(LOCAL_DOCKER_BUILDX_BAKE) --load $(@:application-%-image=application-%)
# .PHONY: $(LOCAL_APPLICATION_IMAGES_WORKERS_DOCKER_BUILDX_BAKE_IMAGES:application-%=application-%-image)

# $(LOCAL_APPLICATION_IMAGES_WORKERS_DOCKER_BUILDX_BAKE_IMAGES:application-%=application-%-image-push):
# 	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:application-%-image-push=application-%)
# 	@$(LOCAL_DOCKER_BUILDX_BAKE) --push $(@:application-%-image-push=application-%)
# .PHONY: $(LOCAL_APPLICATION_IMAGES_WORKERS_DOCKER_BUILDX_BAKE_IMAGES:application-%=application-%-image-push)

# $(LOCAL_APPLICATION_IMAGES_WORKERS_DOCKER_BUILDX_BAKE_IMAGES:application-%=application-%-image-ci): docker-buildx-setup
# 	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:application-%-image-ci=application-%-ci)
# 	@$(LOCAL_DOCKER_BUILDX_BAKE) --push $(@:application-%-image-ci=application-%-ci)
# .PHONY: $(LOCAL_APPLICATION_IMAGES_WORKERS_DOCKER_BUILDX_BAKE_IMAGES:application-%=application-%-image-ci)

$(LOCAL_DOCKER_BUILDX_BAKE_IMAGES:%=local-%-image): docker-buildx-setup
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:local-%-image=%)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --load $(@:local-%-image=%)
.PHONY: $(LOCAL_DOCKER_BUILDX_BAKE_IMAGES:%=local-%-image)

$(LOCAL_DOCKER_BUILDX_BAKE_IMAGES:%=local-%-image-push):
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:local-%-image-push=%)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push $(@:local-%-image-push=%)
.PHONY: $(LOCAL_DOCKER_BUILDX_BAKE_IMAGES:%=local-%-image-push)

$(LOCAL_DOCKER_BUILDX_BAKE_IMAGES:%=local-%-image-ci): docker-buildx-setup
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:local-%-image-ci=%-ci)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push $(@:local-%-image-ci=%-ci)
.PHONY: $(LOCAL_DOCKER_BUILDX_BAKE_IMAGES:%=local-%-image-ci)

