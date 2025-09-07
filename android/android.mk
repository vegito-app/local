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
	$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:%-image=%)
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

$(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=local-android-%-container-rm): 
	@$(MAKE) $(@:%-rm=%-stop)
	@$(LOCAL_DOCKER_COMPOSE) rm -f $(@:local-%-container-rm=%)
.PHONY: $(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=local-android-%-container-rm)

$(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=local-android-%-container-start):
	@-$(LOCAL_DOCKER_COMPOSE) start $(@:local-%-container-start=%) 2>/dev/null
.PHONY: $(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=local-android-%-container-start)

$(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=local-android-%-container-stop):
	@-$(LOCAL_DOCKER_COMPOSE) stop $(@:local-%-container-stop=%) 2>/dev/null
.PHONY: $(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=local-android-%-container-stop)

$(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=local-android-%-container-logs):
	@$(LOCAL_DOCKER_COMPOSE) logs $(@:local-%-container-logs=%)
.PHONY: $(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=local-android-%-container-logs)

$(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=local-android-%-container-logs-f):
	@$(LOCAL_DOCKER_COMPOSE) logs --follow $(@:local-%-container-logs-f=%)
.PHONY: $(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=local-android-%-container-logs-f)

$(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=local-android-%-container-sh):
	@$(LOCAL_DOCKER_COMPOSE) exec -it $(@:local-%-container-sh=%) bash
.PHONY: $(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=local-android-%-container-sh)

$(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=local-android-%-image-pull):
	@echo Pulling the image for $(@:local-%-image-pull=%)
	@$(LOCAL_DOCKER_COMPOSE) pull $(@:local-%-image-pull=%)
.PHONY: $(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=local-android-%-image-pull)

local-android-docker-images-pull: $(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=local-android-%-image-pull)
.PHONY: local-android-docker-images-pull

local-android-docker-images-pull-parallel: 
	@echo Pulling all android images in parallel...
	@$(MAKE) -j local-android-docker-images-pull
.PHONY: local-android-docker-images-pull-parallel

$(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=local-android-%-image-push):
	@echo Pushing the image for $(@:local-%-image-push=%)
	@$(LOCAL_DOCKER_COMPOSE) push $(@:local-%-image-push=%)
.PHONY: $(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=local-android-%-image-push)

local-android-docker-images-push: $(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=local-android-%-image-push)
.PHONY: local-android-docker-images-push

local-android-docker-images-push-parallel: 
	@echo Pushing all android images in parallel...
	@$(MAKE) -j local-android-docker-images-push
.PHONY: local-android-docker-images-push-parallel

local-android-appium-emulator-avd-wipe-data:
	@$(LOCAL_ANDROID_STUDIO) bash -c ' \
		emulator -avd $(LOCAL_ANDROID_STUDIO_ANDROID_AVD_NAME) -no-snapshot-save -wipe-data \
		--gpu $(LOCAL_ANDROID_STUDIO_ANDROID_GPU_MODE) ; \
	'
.PHONY: local-android-appium-emulator-avd-wipe-data
