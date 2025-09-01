LOCAL_ANDROID_DIR ?= $(LOCAL_DIR)/android
-include $(LOCAL_ANDROID_DIR)/studio/studio.mk

local-android-images: \
local-android-builder-host-arch-load \
local-android-services-host-arch-load 
.PHONY: local-android-images

local-android-docker-images-pull: 
	@$(MAKE) -j local-android-docker-images-pull
.PHONY: local-android-docker-images-pull

local-android-docker-images-push: 
	@$(MAKE) -j local-android-docker-images-push
.PHONY: local-android-docker-images-push

local-android-docker-images-ci: \
local-android-builder-multi-arch-push \
local-android-services-multi-arch-push 
.PHONY: local-android-docker-images-ci

LOCAL_ANDROID_DOCKER_BUILDX_BAKE_IMAGES ?= \
  local-android-appium \
  local-android-emulator \
  local-android-flutter \
  local-android-studio

LOCAL_ANDROID_DOCKER_BAKE_GROUPS ?= \
  builder \
  services

local-android-docker-images-pull:
	@$(MAKE) -j $(LOCAL_ANDROID_DOCKER_BUILDX_BAKE_IMAGES:%=local-%-image-pull)
.PHONY: local-android-docker-images-pull

# $(LOCAL_ANDROID_DOCKER_BUILDX_BAKE_IMAGES:local-%=local-%-image-pull):
# 	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:local-android-%-image-pull=local-android-%)
# 	@$(LOCAL_DOCKER_BUILDX_BAKE) --pull $(@:local-android-%-image-pull=local-android-%)
# .PHONY: $(LOCAL_ANDROID_DOCKER_BUILDX_BAKE_IMAGES:local-%=local-%-image-pull)

$(LOCAL_ANDROID_DOCKER_BUILDX_BAKE_IMAGES:local-android-%=local-android-%-image): docker-buildx-setup
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:local-android-%-image=local-android-%)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --load $(@:local-android-%-image=local-android-%)
.PHONY: $(LOCAL_ANDROID_DOCKER_BUILDX_BAKE_IMAGES:local-android-%=local-android-%-image)

$(LOCAL_ANDROID_DOCKER_BUILDX_BAKE_IMAGES:local-android-%=local-android-%-image-push):
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:local-android-%-image-push=local-android-%)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push $(@:local-android-%-image-push=local-android-%)
.PHONY: $(LOCAL_ANDROID_DOCKER_BUILDX_BAKE_IMAGES:local-android-%=local-android-%-image-push)

$(LOCAL_ANDROID_DOCKER_BAKE_GROUPS:%=local-android-%-multi-arch-push):
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $@
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push $@
.PHONY: $(LOCAL_ANDROID_DOCKER_BAKE_GROUPS:%=local-android-%-multi-arch-push)

$(LOCAL_ANDROID_DOCKER_BAKE_GROUPS:%=local-android-%-host-arch-load): local-android-emulator-image-push
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $@
	@$(LOCAL_DOCKER_BUILDX_BAKE) --load $@
.PHONY: $(LOCAL_ANDROID_DOCKER_BAKE_GROUPS:%=local-android-%-host-arch-load)

$(LOCAL_ANDROID_DOCKER_BUILDX_BAKE_IMAGES:local-android-%=local-android-%-image-ci): docker-buildx-setup
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:local-android-%-image-ci=local-android-%-ci)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push $(@:local-android-%-image-ci=local-android-%-ci)
.PHONY: $(LOCAL_ANDROID_DOCKER_BUILDX_BAKE_IMAGES:local-android-%=local-android-%-image-ci)

LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES ?= \
  local-android-backend \
  local-android-mobile

$(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:local-android-%=local-android-%-image-pull):
	@$(LOCAL_DOCKER_COMPOSE) pull $(@:%-image-pull=%)
.PHONY: $(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=local-android-%-image-pull)

local-android-docker-images-pull: $(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=local-android-%-image-pull)
.PHONY: local-android-docker-images-pull
