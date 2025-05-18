DEV_DOCKER_COMPOSE_SERVICES += local-android-studio

ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE=$(CURDIR)/local/.containers/docker-buildx-cache/android-studio
$(ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE):;	@mkdir -p "$@"
ifneq ($(wildcard $(ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)/index.json),)
ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ = type=local,src=$(ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)
endif
ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE= type=local,dest=$(ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)
ANDROID_STUDIO_IMAGE = ${PUBLIC_IMAGES_BASE}:android-studio-latest

local-android-studio-docker-compose-up: local-android-studio-docker-compose-rm
	@VERSION=latest $(CURDIR)/local/android-studio/docker-compose-up.sh &
	@$(LOCAL_DOCKER_COMPOSE) logs android-studio
	@echo
	@echo Started Androïd studio display: 
	@echo Run "'make $(@:%-up=%-logs)'" to retrieve more logs
.PHONY: local-android-studio-docker-compose-up

local-android-studio-docker-compose-emulator-logs:
	$(LOCAL_DOCKER_COMPOSE) exec android-studio adb logcat -T 10
.PHONY: local-android-studio-docker-compose-emulator-logs