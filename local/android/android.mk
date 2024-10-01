
ANDROID_STUDIO_IMAGE =  $(PUBLIC_IMAGES_BASE):android-studio-$(VERSION)

local-android-studio-image: docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print android-studio-local
	@$(DOCKER_BUILDX_BAKE) --load android-studio-local
.PHONY: local-android-studio-image

local-android-studio-image-push: docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print android-studio
	@$(DOCKER_BUILDX_BAKE) --push android-studio
.PHONY: local-android-studio-image-push

local-docker-compose-android-studio-up: local-docker-compose-android-studio-rm
	@$(CURDIR)/local/android/studio-docker-start.sh &
	@$(LOCAL_DOCKER_COMPOSE) logs android-studio
	@echo
	@echo Started Androïd studio display: 
	@echo Run "'make $(@:%-up=%-logs)'" to retrieve more logs
.PHONY: local-docker-compose-android-studio

local-docker-compose-android-studio-stop:
	@-$(LOCAL_DOCKER_COMPOSE) stop android-studio 2>/dev/null
.PHONY: local-docker-compose-android-studio-stop

local-docker-compose-android-studio-rm: local-docker-compose-android-studio-stop
	@$(LOCAL_DOCKER_COMPOSE) rm -f android-studio
.PHONY: local-docker-compose-android-studio-rm

local-docker-compose-android-studio-logs:
	@$(LOCAL_DOCKER_COMPOSE) logs --follow android-studio
.PHONY: local-docker-compose-android-studio-logs

local-docker-compose-android-studio-sh:
	@$(LOCAL_DOCKER_COMPOSE) exec -it android-studio bash
.PHONY: local-docker-compose-android-studio-sh