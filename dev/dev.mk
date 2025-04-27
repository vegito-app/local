-include dev/docker/docker.mk
-include dev/go.mk
-include dev/nodejs.mk

LATEST_BUILDER_IMAGE = $(PUBLIC_IMAGES_BASE):builder-latest

DOCKER_COMPOSE = docker compose -f $(CURDIR)/dev/docker-compose.yml

dev-install: application-frontend-build application-frontend-bundle backend-install 
.PHONY: install

dev-local: $(APPLICATION_BACKEND_INSTALL_BIN) $(FRONTEND_BUILD_DIR) $(UI_JAVASCRIPT_SOURCE_FILE)
	@$(APPLICATION_BACKEND_INSTALL_BIN)
.PHONY: dev-local

BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE=$(CURDIR)/dev/.containers/docker-buildx-cache/dev-builder
$(BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE):;	@mkdir -p "$@"
ifneq ($(wildcard $(BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)/index.json),)
BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ = type=local,src=$(BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)
endif
BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE= type=local,dest=$(BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)

dev-builder-image: $(BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE) docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print builder
	@$(DOCKER_BUILDX_BAKE) --load builder
.PHONY: dev-builder-image

dev-builder-image-push: docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print builder
	@$(DOCKER_BUILDX_BAKE) --push builder
.PHONY: dev-builder-image-push

dev-builder-image-ci: docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print builder-ci
	@$(DOCKER_BUILDX_BAKE) --push builder-ci
.PHONY: dev-builder-image-ci

dev-image-pull:
	@$(DOCKER_COMPOSE) pull dev
.PHONY: dev-image-pull

dev-logs:
	@$(DOCKER_COMPOSE) logs dev
.PHONY: dev-logs

dev-logsf:
	@$(DOCKER_COMPOSE) logs -f dev
.PHONY: dev-logsf

-include dev/android-studio/android-studio.mk
-include dev/clarinet/clarinet.mk
-include dev/github/github.mk
-include dev/firebase-emulators/firebase-emulators.mk
-include dev/vault/vault.mk

DEV_SERVICES = \
  dev-firebase-emulators \
  dev-clarinet-devnet \
  dev-vault-dev \
  dev-android-studio \
  dev-application-backend

$(DEV_SERVICES:dev-%=%): 
	@$(MAKE) $(@:%=%-docker-compose-up)
.PHONY: $(DEV_SERVICES:%=dev-%)

dev:$(DEV_SERVICES:dev-%=%)
.PHONY: dev