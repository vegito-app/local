
ANDROID_STUDIO_IMAGE =  $(PUBLIC_IMAGES_BASE):$(VERSION)-android-studio

local-docker-compose-android-studio-build-no-pull:
	@docker build --pull=false \
	  -f $(CURDIR)/local/android/Dockerfile \
	  --build-arg builder_image=$(LATEST_BUILDER_IMAGE) \
	  -t $(ANDROID_STUDIO_IMAGE) \
	  .
.PHONY: local-docker-compose-android-studio-build-no-pull

LOCAL_DOCKER_COMPOSE = docker compose -f $(CURDIR)/local/docker-compose.yml

local-docker-compose-android-studio-up: local-docker-compose-android-studio-build-no-pull local-docker-compose-android-studio-rm
	$(CURDIR)/local/android/android-docker-start.sh &
	$(LOCAL_DOCKER_COMPOSE) logs android-studio
	echo
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

local-docker-compose-android-studio-bash:
	@$(LOCAL_DOCKER_COMPOSE) exec -it android-studio bash
.PHONY: local-docker-compose-android-studio-bash
