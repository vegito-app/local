export 

PROJECT_ID = utrade-taxi-run-0
REGION = us-central1
REGISTRY = $(REGION)-docker.pkg.dev
REPOSITORY = $(REGISTRY)/$(PROJECT_ID)/utrade-repository
VERSION ?= v0.0.0
IMAGES_BASE ?= $(REPOSITORY)/utrade
BACKEND_IMAGE ?= $(IMAGES_BASE):$(VERSION)-backend
BUILDER_IMAGE_VERSION ?= $(VERSION)
BUILDER_IMAGE ?= $(IMAGES_BASE):$(BUILDER_IMAGE_VERSION)-builder
GO_VERSION = 1.22
GOOGLE_APPLICATION_CREDENTIALS = $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)
GIT_TAG = $(shell git rev-parse --short HEAD)

-include cloud/cloud.mk 
-include frontend/frontend.mk
-include backend/backend.mk
-include local/local.mk

GOOGLE_MAPS_API_KEY_FILE := $(CURDIR)/frontend/google_maps_api_key

google-maps-api-key-file: $(GOOGLE_MAPS_API_KEY_FILE)
.PHONY: google-maps-api-key-file

$(GOOGLE_MAPS_API_KEY_FILE):
	@echo -n $$REACT_APP_GOOGLE_MAPS_API_KEY > $(GOOGLE_MAPS_API_KEY_FILE)

GO_MODULES := backend cloud/infra/go

go-mod-tidy: $(GO_MODULES:%=go-%-mod-tidy)
.PHONY: go-mod-tidy

$(GO_MODULES:%=go-%-mod-tidy):
	@cd $(CURDIR)/$(@:go-%-mod-tidy=%) && go mod tidy -v -go=$(GO_VERSION)
.PHONY: $(GO_MODULES:%=go-%-mod-tidy) 

go-mod-upgrade: $(GO_MODULES:%=go-%-mod-upgrade)
.PHONY: go-mod-upgrade

$(GO_MODULES:%=go-%-mod-upgrade):
	@cd $(CURDIR)/$(@:go-%-mod-upgrade=%) && rm -rf vendor && go get -u -v ./...
.PHONY: $(GO_MODULES:%=go-%-mod-upgrade)

go-mod-vendor: $(GO_MODULES:%=go-%-mod-vendor)
.PHONY: go-mod-vendor

$(GO_MODULES:%=go-%-mod-vendor):
	@cd $(CURDIR)/$(@:go-%-mod-vendor=%) && go mod vendor -v
.PHONY: $(GO_MODULES:%=go-%-mod-vendor) 

builder-image-bake: docker-buildx-setup dev-docker-bake-print
	@docker buildx bake builder --push
.PHONY: builder-image-bake

application-image-bake: docker-buildx-setup application-image-bake-print $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS) $(BACKEND_VENDOR) 
	@docker buildx bake application --push
.PHONY: application-image-bake

application-image-bake-print: docker-buildx-setup
	@docker buildx bake application --print
.PHONY: webapp-image-bake-print

docker-buildx-setup: $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS) $(GOOGLE_MAPS_API_KEY_FILE)
	@-docker buildx create --use --name $(PROJECT_ID)-builder 2>/dev/null 
.PHONY: docker-buildx-setup

dev-docker-bake-print: docker-buildx-setup
	@docker buildx bake dev --print
.PHONY: dev-docker-bake-print

docker-login: gcloud-auth-docker
	docker login $(REPOSITORY)
.PHONY: docker-login

unlock-docker-sock:
	sudo chmod o+rw /var/run/docker.sock
.PHONY: unlock-docker-sock