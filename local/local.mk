LATEST_BUILDER_IMAGE = $(PUBLIC_IMAGES_BASE):builder-latest

LOCAL_DOCKER_COMPOSE = docker compose -f $(CURDIR)/local/docker-compose.yml

local-install: application-frontend-build application-frontend-bundle backend-install 
.PHONY: local-install

local-run: $(APPLICATION_BACKEND_INSTALL_BIN) $(FRONTEND_BUILD_DIR) $(UI_JAVASCRIPT_SOURCE_FILE)
	@$(APPLICATION_BACKEND_INSTALL_BIN)
.PHONY: local-run

-include $(CURDIR)/local/firebase/firebase.mk
-include $(CURDIR)/local/android/android.mk

BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE=$(CURDIR)/local/.docker-buildx-cache/builder
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

local-dev-image-pull:
	@$(LOCAL_DOCKER_COMPOSE) pull dev
.PHONY: local-dev-image-pull

local-dev-logs:
	@$(LOCAL_DOCKER_COMPOSE) logs dev
.PHONY: local-dev-logs

local-dev-logsf:
	@$(LOCAL_DOCKER_COMPOSE) logs -f dev
.PHONY: local-dev-logsf
