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

BACKEND_VENDOR = $(CURDIR)/backend/vendor

$(BACKEND_VENDOR):
	@$(MAKE) go-backend-mod-vendor

BACKEND_INSTALL_BIN = $(shell go env GOPATH)/bin/backend

backend-run: $(BACKEND_INSTALL_BIN) $(FRONTEND_BUILD_DIR) $(UI_JAVASCRIPT_SOURCE_FILE) 
	@backend
.PHONY: backend-run

$(BACKEND_INSTALL_BIN): 
	@$(MAKE) backend-install

backend-install: $(BACKEND_VENDOR)
	@cd backend && go install -a -ldflags "-linkmode external -extldflags -static"
.PHONY: backend-install