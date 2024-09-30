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

DOCKER_BUILDX_BAKE = docker buildx bake \
	-f docker-bake.hcl  \
	-f infra/github/docker-bake.hcl

builder-image-build-push: docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print builder
	@$(DOCKER_BUILDX_BAKE) --push builder
.PHONY: builder-image-build-push

builder-image-local: docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print local-builder
	@$(DOCKER_BUILDX_BAKE) --load local-builder
.PHONY: builder-image-local

application-image-push: docker-buildx-setup $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS) $(BACKEND_VENDOR) 
	@$(DOCKER_BUILDX_BAKE) --print application
	@$(DOCKER_BUILDX_BAKE) --push application
.PHONY: application-image-push

docker-buildx-setup: $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS) $(GOOGLE_MAPS_API_KEY_FILE)
	@-docker buildx create --use --name $(PROJECT_ID)-builder 2>/dev/null 
.PHONY: docker-buildx-setup

docker-login: gcloud-auth-docker
	docker login $(REGISTRY)/$(PROJECT_ID)
.PHONY: docker-login

docker-sock:
	sudo chmod o+rw /var/run/docker.sock
.PHONY: docker-sock
