LOCAL_GO_VERSION = 1.24

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
	example-application/backend \
	firebase-emulators/auth_functions \
	proxy

local-go-mod-tidy: $(LOCAL_GO_MODULES:%=local-go-%-mod-tidy)
.PHONY: local-go-mod-tidy

$(LOCAL_GO_MODULES:%=local-go-%-mod-tidy):
	@cd $(LOCAL_DIR)/$(@:local-go-%-mod-tidy=%) && go mod tidy -v -go=$(LOCAL_GO_VERSION)
.PHONY: $(LOCAL_GO_MODULES:%=local-go-%-mod-tidy)

local-go-mod-download: $(LOCAL_GO_MODULES:%=local-go-%-mod-download)
.PHONY: local-go-mod-download

$(LOCAL_GO_MODULES:%=local-go-%-mod-download):
	@cd $(LOCAL_DIR)/$(@:local-go-%-mod-download=%) && go mod download
.PHONY: $(LOCAL_GO_MODULES:%=local-go-%-mod-download) 

local-go-mod-upgrade: $(LOCAL_GO_MODULES:%=local-go-%-mod-upgrade)
.PHONY: local-go-mod-upgrade

$(LOCAL_GO_MODULES:%=local-go-%-mod-upgrade):
	@cd $(LOCAL_DIR)/$(@:local-go-%-mod-upgrade=%) && rm -rf vendor && go get -u -v ./...
.PHONY: $(LOCAL_GO_MODULES:%=local-go-%-mod-upgrade)

local-go-mod-vendor: $(LOCAL_GO_MODULES:%=local-go-%-mod-vendor)
.PHONY: local-go-mod-vendor

local-go-mod-vendor-rm: $(LOCAL_GO_MODULES:%=local-go-%-mod-vendor-rm)
.PHONY: local-go-mod-vendor-rm

$(LOCAL_GO_MODULES:%=local-go-%-mod-vendor):
	@cd $(LOCAL_DIR)/$(@:local-go-%-mod-vendor=%) && go mod vendor -v
.PHONY: $(LOCAL_GO_MODULES:%=local-go-%-mod-vendor) 

$(LOCAL_GO_MODULES:%=local-go-%-mod-vendor-rm):
	@rm -rf $(LOCAL_DIR)/$(@:local-go-%-mod-vendor-rm=%)/vendor
.PHONY: $(LOCAL_GO_MODULES:%=local-go-%-mod-vendor-rm) 
