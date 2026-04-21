GO_VERSION = 1.26.2

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

LOCAL_GO_MODULES ?= \
	$(LOCAL_DIR)/firebase-emulators/auth_functions \
	$(LOCAL_DIR)/proxy \
	$(VEGITO_EXAMPLE_APPLICATION_BACKEND_DIR)

local-go-mod-tidy: $(LOCAL_GO_MODULES:%=local-go-%-mod-tidy)
.PHONY: local-go-mod-tidy

$(LOCAL_GO_MODULES:%=local-go-%-mod-tidy):
	@cd $(@:local-go-%-mod-tidy=%) && go mod tidy -v -go=$(GO_VERSION)
.PHONY: $(LOCAL_GO_MODULES:%=local-go-%-mod-tidy)

local-go-mod-download: $(LOCAL_GO_MODULES:%=local-go-%-mod-download)
.PHONY: local-go-mod-download

$(LOCAL_GO_MODULES:%=local-go-%-mod-download):
	@echo 'for i in 1 2 3; do \
	  cd $(@:local-go-%-mod-download=%) && \
	    GOPROXY=https://proxy.golang.org,direct go mod download && exit 0; \
	    echo "retry $$i"; \
	  sleep 5; \
	done; \
	exit 1;'
.PHONY: $(LOCAL_GO_MODULES:%=local-go-%-mod-download) 

local-go-mod-upgrade: $(LOCAL_GO_MODULES:%=local-go-%-mod-upgrade)
.PHONY: local-go-mod-upgrade

$(LOCAL_GO_MODULES:%=local-go-%-mod-upgrade):
	@cd $(@:local-go-%-mod-upgrade=%) && rm -rf vendor && go get -u -v ./...
.PHONY: $(LOCAL_GO_MODULES:%=local-go-%-mod-upgrade)

local-go-mod-vendor: $(LOCAL_GO_MODULES:%=local-go-%-mod-vendor)
.PHONY: local-go-mod-vendor

local-go-mod-vendor-rm: $(LOCAL_GO_MODULES:%=local-go-%-mod-vendor-rm)
.PHONY: local-go-mod-vendor-rm

$(LOCAL_GO_MODULES:%=local-go-%-mod-vendor):
	@cd $(@:local-go-%-mod-vendor=%) && go mod vendor -v
.PHONY: $(LOCAL_GO_MODULES:%=local-go-%-mod-vendor) 

$(LOCAL_GO_MODULES:%=local-go-%-mod-vendor-rm):
	@rm -rf $(@:local-go-%-mod-vendor-rm=%)/vendor
.PHONY: $(LOCAL_GO_MODULES:%=local-go-%-mod-vendor-rm) 
