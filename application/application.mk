LOCAL_APPLICATION_DIR ?= $(CURDIR)/application
APPLICATION_MOBILE_DIR = $(LOCAL_APPLICATION_DIR)/mobile

-include $(LOCAL_APPLICATION_DIR)/frontend/frontend.mk
-include $(LOCAL_APPLICATION_DIR)/backend/backend.mk
-include $(APPLICATION_MOBILE_DIR)/mobile.mk

local-application-docker-images: 
	@$(MAKE) -j local-application-docker-images-host-arch
.PHONY: local-application-docker-images

local-application-docker-images-pull: 
	@$(MAKE) -j local-application-docker-images-pull
.PHONY: local-application-docker-images-pull

local-application-docker-images-push: 
	@$(MAKE) -j local-application-docker-images-push
.PHONY: local-application-docker-images-push

local-application-docker-images-ci: 
	@$(MAKE) -j local-application-ci-images
.PHONY: local-application-docker-images-ci

APPLICATION_DOCKER_BUILDX_BAKE_IMAGES := \
  local-application-backend \
  local-application-mobile

$(APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:local-application-%=local-application-%-image): docker-buildx-setup
	$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:local-application-%-image=local-application-%)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --load $(@:local-application-%-image=local-application-%)
.PHONY: $(APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:local-application-%=local-application-%-image)

$(APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:local-application-%=local-application-%-image-push):
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:local-application-%-image-push=local-application-%)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push $(@:local-application-%-image-push=local-application-%)
.PHONY: $(APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:local-application-%=local-application-%-image-push)

local-application-ci-images: docker-buildx-setup
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print local-application-ci
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push local-application-ci
.PHONY: local-application-ci-images

local-application-docker-images-host-arch:
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print local-application
	@$(LOCAL_DOCKER_BUILDX_BAKE) --load local-application
.PHONY: local-application-docker-images-host-arch

$(APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:local-application-%=local-application-%-image-ci): docker-buildx-setup
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:local-application-%-image-ci=local-application-%-ci)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push $(@:local-application-%-image-ci=local-application-%-ci)
.PHONY: $(APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:local-application-%=local-application-%-image-ci)

APPLICATION_DOCKER_COMPOSE_SERVICES ?= \
  local-application-backend \
  local-application-mobile

$(APPLICATION_DOCKER_COMPOSE_SERVICES:local-application-%=local-application-%-image-pull):
	@$(LOCAL_DOCKER_COMPOSE) pull $(@:%-image-pull=%)
.PHONY: $(APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-application-%-image-pull)

local-application-docker-images-pull: $(APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-application-%-image-pull)
.PHONY: local-application-docker-images-pull
