VEGITO_GO_VERSION = 1.24

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

VEGITO_EXAMPLE_APPLICATION_GO_MODULES = \
	backend \
	local/firebase-emulators/auth_functions \
	local/proxy

go-mod-tidy: $(VEGITO_EXAMPLE_APPLICATION_GO_MODULES:%=example-application-go-%-mod-tidy)
.PHONY: go-mod-tidy

$(VEGITO_EXAMPLE_APPLICATION_GO_MODULES:%=example-application-go-%-mod-tidy):
	@cd $(VEGITO_EXAMPLE_APPLICATION_DIR)/$(@:example-application-go-%-mod-tidy=%) && go mod tidy -v -go=$(VEGITO_GO_VERSION)
.PHONY: $(VEGITO_EXAMPLE_APPLICATION_GO_MODULES:%=example-application-go-%-mod-tidy)

go-mod-download: $(VEGITO_EXAMPLE_APPLICATION_GO_MODULES:%=example-application-go-%-mod-download)
.PHONY: go-mod-download

$(VEGITO_EXAMPLE_APPLICATION_GO_MODULES:%=example-application-go-%-mod-download):
	@cd $(VEGITO_EXAMPLE_APPLICATION_DIR)/$(@:example-application-go-%-mod-download=%) && go mod download
.PHONY: $(VEGITO_EXAMPLE_APPLICATION_GO_MODULES:%=example-application-go-%-mod-download) 

go-mod-upgrade: $(VEGITO_EXAMPLE_APPLICATION_GO_MODULES:%=example-application-go-%-mod-upgrade)
.PHONY: go-mod-upgrade

$(VEGITO_EXAMPLE_APPLICATION_GO_MODULES:%=example-application-go-%-mod-upgrade):
	@cd $(VEGITO_EXAMPLE_APPLICATION_DIR)/$(@:example-application-go-%-mod-upgrade=%) && rm -rf vendor && go get -u -v ./...
.PHONY: $(VEGITO_EXAMPLE_APPLICATION_GO_MODULES:%=example-application-go-%-mod-upgrade)

go-mod-vendor: $(VEGITO_EXAMPLE_APPLICATION_GO_MODULES:%=example-application-go-%-mod-vendor)
.PHONY: go-mod-vendor

go-mod-vendor-rm: $(VEGITO_EXAMPLE_APPLICATION_GO_MODULES:%=example-application-go-%-mod-vendor-rm)
.PHONY: go-mod-vendor-rm

$(VEGITO_EXAMPLE_APPLICATION_GO_MODULES:%=example-application-go-%-mod-vendor):
	@cd $(VEGITO_EXAMPLE_APPLICATION_DIR)/$(@:example-application-go-%-mod-vendor=%) && go mod vendor -v
.PHONY: $(VEGITO_EXAMPLE_APPLICATION_GO_MODULES:%=example-application-go-%-mod-vendor) 

$(VEGITO_EXAMPLE_APPLICATION_GO_MODULES:%=example-application-go-%-mod-vendor-rm):
	@rm -rf $(VEGITO_EXAMPLE_APPLICATION_DIR)/$(@:example-application-go-%-mod-vendor-rm=%)/vendor
.PHONY: $(VEGITO_EXAMPLE_APPLICATION_GO_MODULES:%=example-application-go-%-mod-vendor-rm) 

