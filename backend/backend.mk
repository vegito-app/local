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
	@$(MAKE) go-backend-mod-vendor

backend-run: $(BACKEND_INSTALL_BIN)
	@$(BACKEND_INSTALL_BIN)
.PHONY: backend-run

$(BACKEND_INSTALL_BIN): 
	@echo Installing backend...
	@$(MAKE) backend-install
	@echo Installed backend.

backend-install:
	@cd backend && go install -a -ldflags "-linkmode external -extldflags -static"
.PHONY: backend-install