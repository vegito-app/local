GO_VERSION ?= 1.26.3

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

AI_NESTOR_GO_MODULES ?= \
	$(VEGITO_NESTOR_DIR)

nestor-go-mod-tidy: $(AI_NESTOR_GO_MODULES:%=nestor-go-%-mod-tidy)
.PHONY: nestor-go-mod-tidy

$(AI_NESTOR_GO_MODULES:%=nestor-go-%-mod-tidy):
	@cd $(@:nestor-go-%-mod-tidy=%) && go mod tidy -v -go=$(GO_VERSION)
.PHONY: $(AI_NESTOR_GO_MODULES:%=nestor-go-%-mod-tidy)

nestor-go-mod-download: $(AI_NESTOR_GO_MODULES:%=nestor-go-%-mod-download)
.PHONY: nestor-go-mod-download

$(AI_NESTOR_GO_MODULES:%=nestor-go-%-mod-download):
	@echo 'for i in 1 2 3; do \
	  cd $(@:nestor-go-%-mod-download=%) && \
	    GOPROXY=https://proxy.golang.org,direct go mod download && exit 0; \
	    echo "retry $$i"; \
	  sleep 5; \
	done; \
	exit 1;'
.PHONY: $(AI_NESTOR_GO_MODULES:%=nestor-go-%-mod-download) 

nestor-go-mod-upgrade: $(AI_NESTOR_GO_MODULES:%=nestor-go-%-mod-upgrade)
.PHONY: nestor-go-mod-upgrade

$(AI_NESTOR_GO_MODULES:%=nestor-go-%-mod-upgrade):
	@cd $(@:nestor-go-%-mod-upgrade=%) && rm -rf vendor && go get -u -v ./...
.PHONY: $(AI_NESTOR_GO_MODULES:%=nestor-go-%-mod-upgrade)

nestor-go-mod-vendor: $(AI_NESTOR_GO_MODULES:%=nestor-go-%-mod-vendor)
.PHONY: nestor-go-mod-vendor

nestor-go-mod-vendor-rm: $(AI_NESTOR_GO_MODULES:%=nestor-go-%-mod-vendor-rm)
.PHONY: nestor-go-mod-vendor-rm

$(AI_NESTOR_GO_MODULES:%=nestor-go-%-mod-vendor):
	@cd $(@:nestor-go-%-mod-vendor=%) && go mod vendor -v
.PHONY: $(AI_NESTOR_GO_MODULES:%=nestor-go-%-mod-vendor) 

$(AI_NESTOR_GO_MODULES:%=nestor-go-%-mod-vendor-rm):
	@rm -rf $(@:nestor-go-%-mod-vendor-rm=%)/vendor
.PHONY: $(AI_NESTOR_GO_MODULES:%=nestor-go-%-mod-vendor-rm) 
