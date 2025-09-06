LOCAL_ANDROID_DIR ?= $(LOCAL_DIR)/android

-include $(LOCAL_ANDROID_DIR)/emulator/emulator.mk
-include $(LOCAL_ANDROID_DIR)/flutter/flutter.mk
-include $(LOCAL_ANDROID_DIR)/appium/appium.mk
-include $(LOCAL_ANDROID_DIR)/studio/studio.mk

LOCAL_ANDROID_DOCKER_BAKE_GROUPS ?= \
  runners \
  builders \
  services

local-android-docker-images: 
	@$(MAKE) -j $(LOCAL_ANDROID_DOCKER_BAKE_GROUPS:%=local-android-%-group)
.PHONY: local-android-docker-images

$(LOCAL_ANDROID_DOCKER_BAKE_GROUPS:%=local-android-%-group): 
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:%-group=%)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --load $(@:%-group=%)
.PHONY: $(LOCAL_ANDROID_DOCKER_BAKE_GROUPS:%=local-android-%-group)

local-android-docker-images-ci: $(LOCAL_ANDROID_DOCKER_BAKE_GROUPS:%=local-android-%-group-ci)
.PHONY: local-android-docker-images-ci

$(LOCAL_ANDROID_DOCKER_BAKE_GROUPS:%=local-android-%-group-ci):
	@echo Build configuration for $(@:%-group-ci=%-ci)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:%-group-ci=%-ci)
	@echo Building and pushing the image for $(@:%-group-ci=%-ci)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push $(@:%-group-ci=%-ci)
.PHONY: $(LOCAL_ANDROID_DOCKER_BAKE_GROUPS:%=local-android-%-group-ci)

LOCAL_ANDROID_DOCKER_BUILDX_BAKE_IMAGES ?= \
  appium \
  emulator \
  flutter \
  studio

$(LOCAL_ANDROID_DOCKER_BUILDX_BAKE_IMAGES:%=local-android-%-image):
	@echo Build configuration for $(@:%-image=%)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:%-image=%)
	@echo Building and loading the image for $(@:%-image=%)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --load $(@:%-image=%)
.PHONY: $(LOCAL_ANDROID_DOCKER_BUILDX_BAKE_IMAGES:%=local-android-%-image)

$(LOCAL_ANDROID_DOCKER_BUILDX_BAKE_IMAGES:%=local-android-%-image-ci):
	@echo Build configuration for $(@:%-image-ci=%-ci)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:%-image-ci=%-ci)
	@echo Building and pushing the image for $(@:%-image-ci=%-ci)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push $(@:%-image-ci=%-ci)
.PHONY: $(LOCAL_ANDROID_DOCKER_BUILDX_BAKE_IMAGES:%=local-android-%-image-ci)

LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES ?= \
  studio \
  appium

$(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=local-android-%-image-pull):
	@echo Pulling the image for $(@:local-%-image-pull=%)
	@$(LOCAL_DOCKER_COMPOSE) pull $(@:local-%-image-pull=%)
.PHONY: $(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=local-android-%-image-pull)

local-android-dockercompose-images-pull: $(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=local-android-%-image-pull)
.PHONY: local-android-dockercompose-images-pull

local-android-docker-images-pull: 
	@$(MAKE) -j local-android-dockercompose-images-pull
.PHONY: local-android-docker-images-pull

$(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=local-android-%-image-push):
	@$(LOCAL_DOCKER_COMPOSE) push $(@:local-%-image-push=%)
.PHONY: $(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=local-android-%-image-push)

local-android-dockercompose-images-push: $(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=local-android-%-image-push)
.PHONY: local-android-dockercompose-images-push

local-android-docker-images-push: 
	@$(MAKE) -j local-android-dockercompose-images-push
.PHONY: local-android-docker-images-push

local-android-appium-emulator-avd-wipe-data:
	@$(LOCAL_ANDROID_STUDIO) bash -c ' \
		emulator -avd $(LOCAL_ANDROID_STUDIO_ANDROID_AVD_NAME) -no-snapshot-save -wipe-data \
		--gpu $(LOCAL_ANDROID_STUDIO_ANDROID_GPU_MODE) ; \
	'
.PHONY: local-android-appium-emulator-avd-wipe-data
