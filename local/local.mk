
LOCAL_DOCKER_COMPOSE = docker compose -f $(CURDIR)/local/docker-compose.yml

local-install: application-frontend-build application-frontend-bundle backend-install 
.PHONY: local-install

local-run: $(BACKEND_INSTALL_BIN) $(FRONTEND_BUILD_DIR) $(UI_JAVASCRIPT_SOURCE_FILE)
	@$(BACKEND_INSTALL_BIN)
.PHONY: local-run

-include $(CURDIR)/local/firebase/firebase.mk
-include $(CURDIR)/local/android/android.mk

local-builder-image: docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print builder
	@$(DOCKER_BUILDX_BAKE) --load builder
.PHONY: local-builder-image

local-builder-image-push: docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print builder
	@$(DOCKER_BUILDX_BAKE) --load --push builder
.PHONY: local-builder-image-push

local-builder-image-ci: docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print builder-ci
	@$(DOCKER_BUILDX_BAKE) --load builder-ci
.PHONY: local-builder-image-ci