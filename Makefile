export 

PROJECT_ID = utrade-taxi-run-0
VERSION ?= dev
GIT_TAG = $(shell git rev-parse --short HEAD)

GOOGLE_CLOUD_PROJECT = $(PROJECT_ID)
GOOGLE_APPLICATION_CREDENTIALS = $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)
GOOGLE_MAPS_API_KEY_FILE := $(CURDIR)/frontend/google_maps_api_key

REGION ?= us-central1
REGISTRY = $(REGION)-docker.pkg.dev
REPOSITORY = $(REGISTRY)/$(PROJECT_ID)/utrade-repository

IMAGES_BASE ?= $(REPOSITORY)/utrade

BUILDER_IMAGE_VERSION ?= $(VERSION)
BUILDER_IMAGE ?= $(IMAGES_BASE):$(BUILDER_IMAGE_VERSION)-builder

BACKEND_IMAGE ?= $(IMAGES_BASE):$(VERSION)-backend

-include go.mk
-include nodejs.mk
-include cloud/cloud.mk 
-include frontend/frontend.mk
-include backend/backend.mk
-include local/local.mk

google-maps-api-key-file: $(GOOGLE_MAPS_API_KEY_FILE)
.PHONY: google-maps-api-key-file

$(GOOGLE_MAPS_API_KEY_FILE): 
	@echo -n $$GOOGLE_MAPS_API_KEY > $(GOOGLE_MAPS_API_KEY_FILE)

builder-image: docker-buildx-setup
	@docker buildx bake --print builder
	@docker buildx bake --push builder
.PHONY: builder-image

application-image: docker-buildx-setup $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS) $(BACKEND_VENDOR) 
	@docker buildx bake --print application
	@docker buildx bake --push application
.PHONY: application-image

docker-buildx-setup: $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS) $(GOOGLE_MAPS_API_KEY_FILE)
	@-docker buildx create --use --name $(PROJECT_ID)-builder 2>/dev/null 
.PHONY: docker-buildx-setup

docker-login: gcloud-auth-docker
	docker login $(REPOSITORY)
.PHONY: docker-login

unlock-docker-sock:
	sudo chmod o+rw /var/run/docker.sock
.PHONY: unlock-docker-sock
