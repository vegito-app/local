ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE=$(CURDIR)/dev/.containers/docker-buildx-cache/android-studio
$(ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE):;	@mkdir -p "$@"
ifneq ($(wildcard $(ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)/index.json),)
ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ = type=local,src=$(ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)
endif
ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE= type=local,dest=$(ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)
ANDROID_STUDIO_IMAGE = ${PUBLIC_IMAGES_BASE}:android-studio-latest

android-studio-image: docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print android-studio
	@$(DOCKER_BUILDX_BAKE) --load android-studio
.PHONY: android-studio-image

android-studio-image-push: docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print android-studio
	@$(DOCKER_BUILDX_BAKE) --push android-studio
.PHONY: android-studio-image-push

android-studio-image-ci: docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print android-studio
	@$(DOCKER_BUILDX_BAKE) --push android-studio-ci
.PHONY: android-studio-image-ci

android-studio-docker-compose-up: android-studio-docker-compose-rm
	@VERSION=latest $(CURDIR)/dev/android-studio/docker-compose-up.sh &
	@$(DOCKER_COMPOSE) logs android-studio
	@echo
	@echo Started Androïd studio display: 
	@echo Run "'make $(@:%-up=%-logs)'" to retrieve more logs
.PHONY: android-studio-docker-compose-up
