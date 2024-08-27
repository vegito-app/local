local-builder-image:
	@docker compose build dev
.PHONY: local-builder-image

local-builder-image-pull:
	@docker compose pull dev
.PHONY: local-builder-image-pull

local-image: $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS) $(GOOGLE_MAPS_API_KEY_FILE) frontend-node-modules
	@docker build \
	  --build-arg builder_image=$(BUILDER_IMAGE) \
	  --secret id=google_maps_api_key,src=$(GOOGLE_MAPS_API_KEY_FILE) \
	  -t $(BACKEND_IMAGE) .
.PHONY: local-image

local-image-run:
	@docker run --rm \
	  -p 8080:8080 \
	  -v $(GOOGLE_APPLICATION_CREDENTIALS):$(GOOGLE_APPLICATION_CREDENTIALS) \
	  -e GOOGLE_APPLICATION_CREDENTIALS \
	  $(BACKEND_IMAGE)
.PHONY: local-image-run

local-build: frontend-build frontend-bundle backend-install 
.PHONY: local-build

local-run: $(BACKEND_INSTALL_BIN) $(FRONTEND_BUILD_DIR) $(UI_JAVASCRIPT_SOURCE_FILE)
	@$(BACKEND_INSTALL_BIN)
.PHONY: local-run

include $(CURDIR)/local/firebase/firebase.mk
