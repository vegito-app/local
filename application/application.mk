LOCAL_APPLICATION_DIR ?= $(CURDIR)/application
APPLICATION_MOBILE_DIR = $(LOCAL_APPLICATION_DIR)/mobile

-include $(LOCAL_APPLICATION_DIR)/frontend/frontend.mk
-include $(LOCAL_APPLICATION_DIR)/backend/backend.mk
-include $(APPLICATION_MOBILE_DIR)/mobile.mk

APPLICATION_DOCKER_BUILDX_BAKE_IMAGES := \
  local-application-backend \
  local-application-mobile

local-application-docker-images:
	@$(MAKE) -j $(APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:local-application-%=local-application-%-image)
.PHONY: local-application-docker-images

$(APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:local-application-%=local-application-%-image):
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:local-application-%-image=local-application-%)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --load $(@:local-application-%-image=local-application-%)
.PHONY: $(APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:local-application-%=local-application-%-image)

local-application-docker-images-ci:
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print local-application-ci
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push local-application-ci
.PHONY: local-application-docker-images-ci

$(APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:local-application-%=local-application-%-image-ci):
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:local-application-%-image-ci=local-application-%-ci)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push $(@:local-application-%-image-ci=local-application-%-ci)
.PHONY: $(APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:local-application-%=local-application-%-image-ci)

LOCAL_APPLICATION_DOCKER_COMPOSE_SERVICES ?= \
  backend \
  mobile

$(LOCAL_APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-application-%-image-pull):
	@echo Pulling the image for $(@:local-%-image-pull=local-%)
	@$(LOCAL_DOCKER_COMPOSE) pull $(@:local-%-image-pull=local-%)
.PHONY: $(LOCAL_APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-application-%-image-pull)

local-application-dockercompose-images-pull: $(LOCAL_APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-application-%-image-pull)
.PHONY: local-application-dockercompose-images-pull

local-application-docker-images-pull: 
	@$(MAKE) -j local-application-dockercompose-images-pull
.PHONY: local-application-docker-images-pull

$(LOCAL_APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-application-%-image-push):
	@$(LOCAL_DOCKER_COMPOSE) push $(@:local-%-image-push=%)
.PHONY: $(LOCAL_APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-application-%-image-push)

local-application-dockercompose-images-push: $(LOCAL_APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-application-%-image-push)
.PHONY: local-application-dockercompose-images-push

local-application-docker-images-push: 
	@$(MAKE) -j local-application-dockercompose-images-push
.PHONY: local-application-docker-images-push
