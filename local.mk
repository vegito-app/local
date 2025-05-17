
LATEST_BUILDER_IMAGE = $(PUBLIC_IMAGES_BASE):builder-latest

DOCKER_COMPOSE = docker compose -f $(CURDIR)/local/docker-compose.yml

local-install: application-frontend-build application-frontend-bundle backend-install 
.PHONY: install

local-dev: $(APPLICATION_BACKEND_INSTALL_BIN) $(FRONTEND_BUILD_DIR) $(UI_JAVASCRIPT_SOURCE_FILE)
	@$(APPLICATION_BACKEND_INSTALL_BIN)
.PHONY: local-dev

BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE=$(CURDIR)/local/.containers/docker-buildx-cache/local-builder
$(BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE):;	@mkdir -p "$@"
ifneq ($(wildcard $(BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)/index.json),)
BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ = type=local,src=$(BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)
endif
BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE= type=local,dest=$(BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)

local-builder-image: $(BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE) docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print builder
	@$(DOCKER_BUILDX_BAKE) --load builder
.PHONY: local-builder-image

local-builder-image-push: docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print builder
	@$(DOCKER_BUILDX_BAKE) --push builder
.PHONY: local-builder-image-push

local-builder-image-ci: docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print builder-ci
	@$(DOCKER_BUILDX_BAKE) --push builder-ci
.PHONY: local-builder-image-ci

local-image-pull:
	@$(DOCKER_COMPOSE) pull dev
.PHONY: local-image-pull

local-logs:
	@$(DOCKER_COMPOSE) logs dev
.PHONY: local-logs

local-logsf:
	@$(DOCKER_COMPOSE) logs -f dev
.PHONY: local-logsf

LOCAL_DOCKER_COMPOSE_SERVICES = \
  android-studio \
  application-backend \
  vault \
  firebase-emulators \
  clarinet-devnet

local-docker-compose: $(LOCAL_DOCKER_COMPOSE_SERVICES)
.PHONY: local-docker-compose

local-docker-compose-rm: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=%-docker-compose-rm)
.PHONY: local-docker-compose-rm

$(LOCAL_DOCKER_COMPOSE_SERVICES):
	@$(MAKE) $(@:%=%-docker-compose-up)
.PHONY: $(LOCAL_DOCKER_COMPOSE_SERVICES)

$(LOCAL_DOCKER_COMPOSE_SERVICES:%=%-docker-compose-rm): 
	@$(MAKE) $(@:%-rm=%-stop)
	@$(DOCKER_COMPOSE) rm -f $(@:%-docker-compose-rm=%)
.PHONY: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=%-docker-compose-rm))

$(LOCAL_DOCKER_COMPOSE_SERVICES:%=%-image): docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print $(@:%-image=%)
	@$(DOCKER_BUILDX_BAKE) --load $(@:%-image=%)
.PHONY: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=%-image)

$(LOCAL_DOCKER_COMPOSE_SERVICES:%=%-image-push): docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print $(@:%-image-push=%)
	@$(DOCKER_BUILDX_BAKE) --push $(@:%-image-push=%)
.PHONY: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=%-image-push)

$(LOCAL_DOCKER_COMPOSE_SERVICES:%=%-image-ci): docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print $(@:%-image-ci=%-ci)
	@$(DOCKER_BUILDX_BAKE) --push $(@:%-image-ci=%-ci)
.PHONY: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=%-image-ci)

$(LOCAL_DOCKER_COMPOSE_SERVICES:%=%-docker-compose-start):
	@-$(DOCKER_COMPOSE) start $(@:%-docker-compose-start=%) 2>/dev/null
.PHONY: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=%-docker-compose-start)

$(LOCAL_DOCKER_COMPOSE_SERVICES:%=%-docker-compose-stop):
	@-$(DOCKER_COMPOSE) stop $(@:%-docker-compose-stop=%) 2>/dev/null
.PHONY: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=%-docker-compose-stop)

$(LOCAL_DOCKER_COMPOSE_SERVICES:%=%-docker-compose-logs):
	@$(DOCKER_COMPOSE) logs --follow $(@:%-docker-compose-logs=%)
.PHONY: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=%-docker-compose-logs)

$(LOCAL_DOCKER_COMPOSE_SERVICES:%=%-docker-compose-sh):
	@$(DOCKER_COMPOSE) exec -it $(@:%-docker-compose-sh=%) bash
.PHONY: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=%-docker-compose-sh)

-include local/android-studio/android-studio.mk
-include local/clarinet/clarinet.mk
-include local/github/github.mk
-include local/firebase-emulators/firebase-emulators.mk
-include local/vault/vault.mk
