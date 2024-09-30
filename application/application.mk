GOOGLE_MAPS_API_KEY_FILE := $(CURDIR)/application/frontend/google_maps_api_key
GOOGLE_APPLICATION_CREDENTIALS = $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)

-include application/frontend/frontend.mk
-include application/backend/backend.mk

application-image-push: docker-buildx-setup $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS) $(BACKEND_VENDOR) 
	@$(DOCKER_BUILDX_BAKE) --print application
	@$(DOCKER_BUILDX_BAKE) --push application
.PHONY: application-image-push
