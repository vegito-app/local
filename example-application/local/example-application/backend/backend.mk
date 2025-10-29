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

APPLICATION_BACKEND_DIR ?= $(VEGITO_EXAMPLE_APPLICATION_DIR)/backend
APPLICATION_BACKEND_INSTALL_BIN = $(HOME)/go/bin/backend
APPLICATION_BACKEND_VENDOR = $(APPLICATION_BACKEND_DIR)/vendor

$(APPLICATION_BACKEND_VENDOR):
	@$(MAKE) go-application/backend-mod-vendor

example-application-backend-run: $(APPLICATION_BACKEND_INSTALL_BIN)
	@$(APPLICATION_BACKEND_INSTALL_BIN)
.PHONY: example-application-backend-run

$(APPLICATION_BACKEND_INSTALL_BIN): example-application-backend-install

example-application-backend-install:
	@echo Installing backend...
	cd $(APPLICATION_BACKEND_DIR) \
	  && go install -a -ldflags "-linkmode external -extldflags -static"
	#   && go install -a -ldflags "-linkmode external"
	@echo Installed backend.
.PHONY: example-application-backend-install

example-application-backend-container-up: example-application-backend-container-rm
	@echo "Starting backend application container..."
	$(APPLICATION_BACKEND_DIR)/container-up.sh
.PHONY: example-application-backend-container-up
