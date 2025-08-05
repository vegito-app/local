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

LOCAL_GO_MODULES := \
	application/backend \
	firebase-emulators/functions/auth \
	proxy

go-mod-tidy: $(LOCAL_GO_MODULES:%=go-%-mod-tidy)
.PHONY: go-mod-tidy

$(LOCAL_GO_MODULES:%=go-%-mod-tidy):
	@cd $(LOCAL_DIR)/$(@:go-%-mod-tidy=%) && go mod tidy -v -go=$(LOCAL_GO_VERSION)
.PHONY: $(LOCAL_GO_MODULES:%=go-%-mod-tidy)

go-mod-download: $(LOCAL_GO_MODULES:%=go-%-mod-download)
.PHONY: go-mod-download

$(LOCAL_GO_MODULES:%=go-%-mod-download):
	@cd $(LOCAL_DIR)/$(@:go-%-mod-download=%) && go mod download
.PHONY: $(LOCAL_GO_MODULES:%=go-%-mod-download) 

go-mod-upgrade: $(LOCAL_GO_MODULES:%=go-%-mod-upgrade)
.PHONY: go-mod-upgrade

$(LOCAL_GO_MODULES:%=go-%-mod-upgrade):
	@cd $(LOCAL_DIR)/$(@:go-%-mod-upgrade=%) && rm -rf vendor && go get -u -v ./...
.PHONY: $(LOCAL_GO_MODULES:%=go-%-mod-upgrade)

go-mod-vendor: $(LOCAL_GO_MODULES:%=go-%-mod-vendor)
.PHONY: go-mod-vendor

go-mod-vendor-rm: $(LOCAL_GO_MODULES:%=go-%-mod-vendor-rm)
.PHONY: go-mod-vendor-rm

$(LOCAL_GO_MODULES:%=go-%-mod-vendor):
	@cd $(LOCAL_DIR)/$(@:go-%-mod-vendor=%) && go mod vendor -v
.PHONY: $(LOCAL_GO_MODULES:%=go-%-mod-vendor) 

$(LOCAL_GO_MODULES:%=go-%-mod-vendor-rm):
	@rm -rf $(LOCAL_DIR)/$(@:go-%-mod-vendor-rm=%)/vendor
.PHONY: $(LOCAL_GO_MODULES:%=go-%-mod-vendor-rm) 
