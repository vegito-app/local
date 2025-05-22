
LATEST_BUILDER_IMAGE = $(PUBLIC_IMAGES_BASE):builder-latest

LOCAL_DOCKER_COMPOSE = docker compose -f $(CURDIR)/local/docker-compose.yml

local-application-install: application-frontend-build application-frontend-bundle backend-install 
.PHONY: local-application-install

local-application-backend-install: $(APPLICATION_BACKEND_INSTALL_BIN) $(FRONTEND_BUILD_DIR) $(UI_JAVASCRIPT_SOURCE_FILE)
	@$(APPLICATION_BACKEND_INSTALL_BIN)
.PHONY: local-application-backend-install

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

local-docker-compose-dev-image-pull:
	@$(LOCAL_DOCKER_COMPOSE) pull dev
.PHONY: local-docker-compose-dev-image-pull

local-docker-compose-dev-logs:
	@$(LOCAL_DOCKER_COMPOSE) logs dev
.PHONY: local-docker-compose-dev-logs

local-docker-compose-dev-logs-f:
	@$(LOCAL_DOCKER_COMPOSE) logs -f dev
.PHONY: local-docker-compose-dev-logs-f

LOCAL_DOCKER_COMPOSE_SERVICES = \
  android-studio \
  vault-dev \
  firebase-emulators \
  clarinet-devnet \
  application-backend \
  application-tests

local-docker-images-pull: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=docker-%-image-pull) local-docker-compose-dev-image-pull
.PHONY: local-docker-images-pull

local-docker-images-push: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=docker-%-image-push) local-builder-image-push
.PHONY: local-docker-images-push

$(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-image): docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print $(@:local-%-image=%)
	@$(DOCKER_BUILDX_BAKE) --load $(@:local-%-image=%)
.PHONY: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-image)

$(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-image-pull):
	@$(LOCAL_DOCKER_COMPOSE) pull $(@:local-%-image-pull=%)
.PHONY: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-image-pull)

$(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-image-push):
	@$(DOCKER_BUILDX_BAKE) --print $(@:local-%-image-push=%)
	@$(DOCKER_BUILDX_BAKE) --push $(@:local-%-image-push=%)
.PHONY: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-image-push)

$(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-image-ci): docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print $(@:local-%-image-ci=%-ci)
	@$(DOCKER_BUILDX_BAKE) --push $(@:local-%-image-ci=%-ci)
.PHONY: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-image-ci)

local-docker-compose-up: $(LOCAL_DOCKER_COMPOSE_SERVICES)
.PHONY: local-docker-compose-up

local-docker-compose-rm-all: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-docker-compose-rm)
.PHONY: local-docker-compose-rm-all

$(LOCAL_DOCKER_COMPOSE_SERVICES):
	@$(MAKE) $(@:%=local-%-docker-compose-up)
.PHONY: $(LOCAL_DOCKER_COMPOSE_SERVICES)

$(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-docker-compose-rm): 
	@$(MAKE) $(@:%-rm=%-stop)
	@$(LOCAL_DOCKER_COMPOSE) rm -f $(@:local-%-docker-compose-rm=%)
.PHONY: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-docker-compose-rm)

$(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-docker-compose-start):
	@-$(LOCAL_DOCKER_COMPOSE) start $(@:local-%-docker-compose-start=%) 2>/dev/null
.PHONY: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-docker-compose-start)

$(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-docker-compose-stop):
	@-$(LOCAL_DOCKER_COMPOSE) stop $(@:local-%-docker-compose-stop=%) 2>/dev/null
.PHONY: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-docker-compose-stop)

$(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-docker-compose-logs):
	@$(LOCAL_DOCKER_COMPOSE) logs $(@:local-%-docker-compose-logs=%)
.PHONY: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-docker-compose-logs)

$(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-docker-compose-logs-f):
	@$(LOCAL_DOCKER_COMPOSE) logs --follow $(@:local-%-docker-compose-logs-f=%)
.PHONY: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-docker-compose-logs-f)

$(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-docker-compose-sh):
	@$(LOCAL_DOCKER_COMPOSE) exec -it $(@:local-%-docker-compose-sh=%) bash
.PHONY: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-docker-compose-sh)

-include local/android-studio/android-studio.mk
-include local/clarinet/clarinet.mk
-include local/github/github.mk
-include local/firebase-emulators/firebase-emulators.mk
-include local/vault/vault.mk
