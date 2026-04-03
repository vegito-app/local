# Activate cgo for using v8go server side html rendering
UNAME_M := $(shell uname -m)
ifeq ($(UNAME_M), x86_64)
  GOARCH = amd64
endif

ifeq ($(findstring arm,$(UNAME_M)),arm)
  GOARCH = arm64
endif

ifeq ($(UNAME_M), aarch64)
  GOARCH = arm64
endif

VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGES_BASE ?= $(VEGITO_EXAMPLE_APPLICATION_PUBLIC_IMAGES_BASE):backend
VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE       ?= $(VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGES_BASE)-$(VERSION)
VEGITO_EXAMPLE_APPLICATION_BACKEND_DIR         ?= $(VEGITO_EXAMPLE_APPLICATION_DIR)/backend
VEGITO_EXAMPLE_APPLICATION_BACKEND_INSTALL_BIN ?= $(HOME)/go/bin/backend
VEGITO_EXAMPLE_APPLICATION_BACKEND_VENDOR      ?= $(VEGITO_EXAMPLE_APPLICATION_BACKEND_DIR)/vendor

$(VEGITO_EXAMPLE_APPLICATION_BACKEND_VENDOR):
	@$(MAKE) go-application/backend-mod-vendor

example-application-backend-run: $(VEGITO_EXAMPLE_APPLICATION_BACKEND_INSTALL_BIN)
	@$(VEGITO_EXAMPLE_APPLICATION_BACKEND_INSTALL_BIN)
.PHONY: example-application-backend-run

$(VEGITO_EXAMPLE_APPLICATION_BACKEND_INSTALL_BIN): example-application-backend-install

example-application-backend-install:
	@echo Installing backend...
	cd $(VEGITO_EXAMPLE_APPLICATION_BACKEND_DIR) \
	  && go install -a -ldflags "-linkmode external -extldflags -static"
	#   && go install -a -ldflags "-linkmode external"
	@echo Installed backend.
.PHONY: example-application-backend-install

example-application-backend-container-up: example-application-backend-container-rm
	@echo "Starting backend application container..."
	$(VEGITO_EXAMPLE_APPLICATION_BACKEND_DIR)/container-up.sh
.PHONY: example-application-backend-container-up

vegito-example-application-backend-gcloud-image-delete:
	@echo "🗑️  Deleting backend image $(VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_LATEST)..."
	@$(GCLOUD) container images delete --force-delete-tags $(VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_LATEST)
.PHONY: vegito-example-application-backend-gcloud-image-delete