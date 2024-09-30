# Activate cgo for using v8go server side html rendering
UNAME_M := $(shell uname -m)
ifeq ($(UNAME_M), x86_64)
  GOARCH ?= amd64
endif

ifeq ($(findstring arm,$(UNAME_M)),arm)
  GOARCH ?= arm64
endif

ifeq ($(UNAME_M), aarch64)
  GOARCH ?= arm64
endif

BACKEND_INSTALL_BIN = $(HOME)/go/bin/backend
BACKEND_VENDOR = $(CURDIR)/backend/vendor

$(BACKEND_VENDOR):
	@$(MAKE) go-application/backend-mod-vendor

backend-run: $(BACKEND_INSTALL_BIN)
	@$(BACKEND_INSTALL_BIN)
.PHONY: backend-run

$(BACKEND_INSTALL_BIN): 
	@echo Installing backend...
	@$(MAKE) backend-install
	@echo Installed backend.

backend-install:
	@cd application/backend && go install -a -ldflags "-linkmode external -extldflags -static"
.PHONY: backend-install

BACKEND_IMAGE ?= $(IMAGES_BASE):backend-$(VERSION)
LATEST_BACKEND_IMAGE ?= $(IMAGES_BASE):backend-latest

google-maps-api-key-file: $(GOOGLE_MAPS_API_KEY_FILE)
.PHONY: google-maps-api-key-file

$(GOOGLE_MAPS_API_KEY_FILE): 
	@echo -n $$GOOGLE_MAPS_API_KEY > $(GOOGLE_MAPS_API_KEY_FILE)
	
local-backend-image-run:
	@docker run --rm \
	  -p 8080:8080 \
	  -v $(GOOGLE_APPLICATION_CREDENTIALS):$(GOOGLE_APPLICATION_CREDENTIALS) \
	  -e GOOGLE_APPLICATION_CREDENTIALS \
	  $(LATEST_BACKEND_IMAGE)
.PHONY: local-backend-image-run

backend-image: docker-buildx-setup $(GOOGLE_MAPS_API_KEY_FILE)
	@$(DOCKER_BUILDX_BAKE) --print backend-local
	@$(DOCKER_BUILDX_BAKE) --load backend-local
.PHONY: backend-image

backend-image-push: docker-buildx-setup $(GOOGLE_MAPS_API_KEY_FILE)
	@$(DOCKER_BUILDX_BAKE) --print backend
	@$(DOCKER_BUILDX_BAKE) --push backend

backend-up:
	@docker compose -f $(CURDIR)/infra/gùithub/docker-compose.yml \
	  up -d  \
	backend
.PHONY: backend-up 

backend-rm:
	@docker compose -f $(CURDIR)/infra/github/docker-compose.yml \
	  rm -s -f
.PHONY: backend-rm
