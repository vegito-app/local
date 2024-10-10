
LOCAL_DOCKER_COMPOSE = docker compose -f $(CURDIR)/local/docker-compose.yml

local-install: application-frontend-build application-frontend-bundle backend-install 
.PHONY: local-install

local-run: $(BACKEND_INSTALL_BIN) $(FRONTEND_BUILD_DIR) $(UI_JAVASCRIPT_SOURCE_FILE)
	@$(BACKEND_INSTALL_BIN)
.PHONY: local-run

-include $(CURDIR)/local/firebase/firebase.mk
-include $(CURDIR)/local/android/android.mk

local-multi-arch-builder-image: docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print builder
	@$(DOCKER_BUILDX_BAKE) --push builder
.PHONY: local-multi-arch-builder-image

local-builder-image: docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print builder-local
	@$(DOCKER_BUILDX_BAKE) --load builder-local
.PHONY: local-builder-image
