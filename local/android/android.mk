
ANDROID_STUDIO_IMAGE ?= $(PUBLIC_IMAGES_BASE):android-studio-$(VERSION)

ANDROID_STUDIO_IMAGE ?= $(PUBLIC_IMAGES_BASE):builder-$(VERSION)
ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE=$(CURDIR)/local/android/.docker-buildx-cache/studio
$(ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE):;	@mkdir -p "$@"
ifneq ($(wildcard $(ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)/index.json),)
ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ = type=local,src=$(ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)
endif
ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE= type=local,dest=$(ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)

local-android-studio-image: docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print android-studio
	@$(DOCKER_BUILDX_BAKE) --load android-studio
.PHONY: local-android-studio-image

local-android-studio-image-push: docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print android-studio
	@$(DOCKER_BUILDX_BAKE) --push android-studio
.PHONY: local-android-studio-image-push

local-android-studio-image-ci: docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print android-studio
	@$(DOCKER_BUILDX_BAKE) android-studio-ci
.PHONY: local-android-studio-image

local-android-studio-docker-compose-up: local-android-studio-docker-compose-rm
	@$(CURDIR)/local/android/studio-docker-start.sh &
	@$(LOCAL_DOCKER_COMPOSE) logs android-studio
	@echo
	@echo Started Androïd studio display: 
	@echo Run "'make $(@:%-up=%-logs)'" to retrieve more logs
.PHONY: local-android-studio-docker-compose

local-android-studio-docker-compose-stop:
	@-$(LOCAL_DOCKER_COMPOSE) stop android-studio 2>/dev/null
.PHONY: local-android-studio-docker-compose-stop

local-android-studio-docker-compose-rm: local-android-studio-docker-compose-stop
	@$(LOCAL_DOCKER_COMPOSE) rm -f android-studio
.PHONY: local-android-studio-docker-compose-rm

local-android-studio-docker-compose-logs:
	@$(LOCAL_DOCKER_COMPOSE) logs --follow android-studio
.PHONY: local-android-studio-docker-compose-logs

local-android-studio-docker-compose-sh:
	@$(LOCAL_DOCKER_COMPOSE) exec -it android-studio bash
.PHONY: local-android-studio-docker-compose-sh