LOCAL_ANDROID_STUDIO_DIR ?= $(LOCAL_ANDROID_DIR)/studio

LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE ?= $(LOCAL_ANDROID_STUDIO_DIR)/.containers/docker-buildx-cache/android-studio
$(LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE):;	@mkdir -p "$@"
ifneq ($(wildcard $(LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)/index.json),)
LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ = type=local,src=$(LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)
endif
LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_CACHE_WRITE= type=local,mode=max,dest=$(LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)
LOCAL_ANDROID_STUDIO_IMAGE_LATEST ?= $(VEGITO_LOCAL_PUBLIC_IMAGES_BASE):android-studio-latest

local-android-studio-container-up: local-android-studio-container-rm
	VERSION=latest $(LOCAL_ANDROID_STUDIO_DIR)/docker-compose-up.sh &
	@$(LOCAL_DOCKER_COMPOSE) logs android-studio
	@echo
	@echo Started Androïd studio display: 
	@echo Run "'make $(@:%-up=%-logs)'" to retrieve more logs
.PHONY: local-android-studio-container-up

LOCAL_ANDROID_STUDIO = $(LOCAL_DOCKER_COMPOSE) exec android-studio

LOCAL_ANDROID_STUDIO_ANDROID_AVD_NAME ?= Pixel_8_Intel
LOCAL_ANDROID_STUDIO_ANDROID_GPU_MODE ?= swiftshader_indirect