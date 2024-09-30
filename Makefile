export 

PROJECT_NAME=utrade
PROJECT_ID = utrade-taxi-run-0
GIT_TAG = $(shell git rev-parse --short HEAD)
VERSION ?= dev

GOOGLE_CLOUD_PROJECT = $(PROJECT_ID)

REGION ?= us-central1
REGISTRY = $(REGION)-docker.pkg.dev

PUBLIC_REPOSITORY = $(REGISTRY)/$(PROJECT_ID)/docker-repository-public
PUBLIC_IMAGES_BASE ?= $(PUBLIC_REPOSITORY)/$(PROJECT_NAME)
BUILDER_IMAGE ?= $(PUBLIC_IMAGES_BASE):builder-$(VERSION)
LATEST_BUILDER_IMAGE ?= $(PUBLIC_IMAGES_BASE):builder-latest

REPOSITORY = $(REGISTRY)/$(PROJECT_ID)/docker-repository
IMAGES_BASE ?= $(REPOSITORY)/$(PROJECT_NAME)

DOCKER_BUILDX_BAKE = docker buildx bake \
	-f docker-bake.hcl  \
	-f application/backend/docker-bake.hcl  \
	-f infra/github/docker-bake.hcl

-include go.mk
-include nodejs.mk
-include infra/infra.mk 
-include local/local.mk
-include application/application.mk

builder-image-build-push: docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print builder
	@$(DOCKER_BUILDX_BAKE) --push builder
.PHONY: builder-image-build-push

builder-image-local: docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print local-builder
	@$(DOCKER_BUILDX_BAKE) --load local-builder
.PHONY: builder-image-local


docker-buildx-setup: $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)
	@-docker buildx create --use --name $(PROJECT_ID)-builder 2>/dev/null 
.PHONY: docker-buildx-setup

docker-login: gcloud-auth-docker
	docker login $(REGISTRY)/$(PROJECT_ID)
.PHONY: docker-login

docker-sock:
	sudo chmod o+rw /var/run/docker.sock
.PHONY: docker-sock
