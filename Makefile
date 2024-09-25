export 

PROJECT_NAME=utrade
PROJECT_ID = utrade-taxi-run-0
GIT_TAG = $(shell git rev-parse --short HEAD)
VERSION ?= dev

GOOGLE_CLOUD_PROJECT = $(PROJECT_ID)
GOOGLE_APPLICATION_CREDENTIALS = $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)
GOOGLE_MAPS_API_KEY_FILE := $(CURDIR)/frontend/google_maps_api_key

REGION ?= us-central1
REGISTRY = $(REGION)-docker.pkg.dev

PUBLIC_REPOSITORY = $(REGISTRY)/$(PROJECT_ID)/docker-repository-public
PUBLIC_IMAGES_BASE ?= $(PUBLIC_REPOSITORY)/$(PROJECT_NAME)
BUILDER_IMAGE ?= $(PUBLIC_IMAGES_BASE):$(VERSION)-builder
LATEST_BUILDER_IMAGE ?= $(PUBLIC_IMAGES_BASE):latest-builder

REPOSITORY = $(REGISTRY)/$(PROJECT_ID)/docker-repository
IMAGES_BASE ?= $(REPOSITORY)/$(PROJECT_NAME)
BACKEND_IMAGE ?= $(IMAGES_BASE):$(VERSION)-backend
LATEST_BACKEND_IMAGE ?= $(IMAGES_BASE):latest-backend

-include go.mk
-include nodejs.mk
-include infra/infra.mk 
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

local-builder-image: docker-buildx-setup
	@docker buildx bake --print localbuilder
	@docker buildx bake --load localbuilder
.PHONY: local-builder-image

application-image: docker-buildx-setup $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS) $(BACKEND_VENDOR) 
	@docker buildx bake --print application
	@docker buildx bake --push application
.PHONY: application-image

docker-buildx-setup: $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS) $(GOOGLE_MAPS_API_KEY_FILE)
	@-docker buildx create --use --name $(PROJECT_ID)-builder 2>/dev/null 
.PHONY: docker-buildx-setup

docker-login: gcloud-auth-docker
	docker login $(REGISTRY)/$(PROJECT_ID)
.PHONY: docker-login

docker-sock:
	sudo chmod o+rw /var/run/docker.sock
.PHONY: docker-sock
