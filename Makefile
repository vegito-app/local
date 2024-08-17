export 

PROJECT_ID = utrade-taxi-run-0
GIT_TAG = $(shell git rev-parse --short HEAD)
REGION = us-central1
REGISTRY = $(REGION)-docker.pkg.dev
REPOSITORY = $(REGISTRY)/$(PROJECT_ID)/utrade-repository
VERSION ?= dev
IMAGES_BASE ?= $(REPOSITORY)/utrade
BACKEND_IMAGE ?= $(IMAGES_BASE):$(VERSION)-backend
BACKEND_INSTALL_BIN = $(HOME)/go/bin/backend
BUILDER_IMAGE_VERSION ?= $(VERSION)
BUILDER_IMAGE ?= $(IMAGES_BASE):$(BUILDER_IMAGE_VERSION)-builder
GO_VERSION = 1.22
GOOGLE_CLOUD_PROJECT = $(PROJECT_ID)
GOOGLE_APPLICATION_CREDENTIALS = $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS)
GOOGLE_MAPS_API_KEY_FILE := $(CURDIR)/frontend/google_maps_api_key

-include cloud/cloud.mk 
-include frontend/frontend.mk
-include backend/backend.mk
-include local/local.mk

google-maps-api-key-file: $(GOOGLE_MAPS_API_KEY_FILE)
.PHONY: google-maps-api-key-file

$(GOOGLE_MAPS_API_KEY_FILE): 
	@echo -n $$GOOGLE_MAPS_API_KEY > $(GOOGLE_MAPS_API_KEY_FILE)

GO_MODULES := backend cloud/infra/auth local/proxy

go-mod-tidy: $(GO_MODULES:%=go-%-mod-tidy)
.PHONY: go-mod-tidy

$(GO_MODULES:%=go-%-mod-tidy):
	@cd $(CURDIR)/$(@:go-%-mod-tidy=%) && go mod tidy -v -go=$(GO_VERSION)
.PHONY: $(GO_MODULES:%=go-%-mod-tidy) 

go-mod-download: $(GO_MODULES:%=go-%-mod-download)
.PHONY: go-mod-download

$(GO_MODULES:%=go-%-mod-download):
	@cd $(CURDIR)/$(@:go-%-mod-download=%) && go mod download
.PHONY: $(GO_MODULES:%=go-%-mod-download) 

go-mod-upgrade: $(GO_MODULES:%=go-%-mod-upgrade)
.PHONY: go-mod-upgrade

$(GO_MODULES:%=go-%-mod-upgrade):
	@cd $(CURDIR)/$(@:go-%-mod-upgrade=%) && rm -rf vendor && go get -u -v ./...
.PHONY: $(GO_MODULES:%=go-%-mod-upgrade)

go-mod-vendor: $(GO_MODULES:%=go-%-mod-vendor)
.PHONY: go-mod-vendor

go-mod-vendor-rm: $(GO_MODULES:%=go-%-mod-vendor-rm)
.PHONY: go-mod-vendor-rm

$(GO_MODULES:%=go-%-mod-vendor):
	@cd $(CURDIR)/$(@:go-%-mod-vendor=%) && go mod vendor -v
.PHONY: $(GO_MODULES:%=go-%-mod-vendor) 

$(GO_MODULES:%=go-%-mod-vendor-rm):
	@rm -rf $(CURDIR)/$(@:go-%-mod-vendor-rm=%)/vendor
.PHONY: $(GO_MODULES:%=go-%-mod-vendor-rm) 

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