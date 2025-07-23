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

LOCAL_APPLICATION_BACKEND_INSTALL_BIN = $(HOME)/go/bin/backend
LOCAL_APPLICATION_BACKEND_VENDOR = $(CURDIR)/backend/vendor

$(LOCAL_APPLICATION_BACKEND_VENDOR):
	@$(MAKE) go-application/backend-mod-vendor

local-application-backend-run: $(LOCAL_APPLICATION_FRONTEND_BUILD_BUNDLE_JS) $(LOCAL_APPLICATION_BACKEND_INSTALL_BIN)
	@$(LOCAL_APPLICATION_BACKEND_INSTALL_BIN)
.PHONY: local-application-backend-run

$(LOCAL_APPLICATION_BACKEND_INSTALL_BIN): local-application-local-example-application-backend-install

LOCAL_APPLICATION_BACKEND_DIR ?= $(CURDIR)/application/backend

local-application-local-example-application-backend-install:
	@echo Installing backend...
	@cd $(LOCAL_APPLICATION_BACKEND_DIR) \
	  && go install -a -ldflags "-linkmode external -extldflags -static"
	#   && go install -a -ldflags "-linkmode external"
	@echo Installed backend.
.PHONY: local-application-local-example-application-backend-install

local-application-local-example-application-backend-install: $(LOCAL_APPLICATION_BACKEND_INSTALL_BIN)
	@$(LOCAL_APPLICATION_BACKEND_INSTALL_BIN)
.PHONY: local-application-local-example-application-backend-install

# Handle buildx cache in local folder
LOCAL_APPLICATION_BACKEND_IMAGE = $(IMAGES_BASE):application-backend-$(LOCAL_VERSION)
LOCAL_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_CACHE ?= $(LOCAL_DIR)/.containers/docker-buildx-cache/application-backend
$(LOCAL_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_CACHE):;	@mkdir -p "$@"
ifneq ($(wildcard $(LOCAL_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_CACHE)/index.json),)
LOCAL_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_CACHE_READ = type=local,src=$(LOCAL_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_CACHE)
endif
LOCAL_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_CACHE_WRITE= type=local,dest=$(LOCAL_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_CACHE)

local-application-backend-docker-compose-up: local-application-backend-docker-compose-rm
	$(LOCAL_APPLICATION_BACKEND_DIR)/docker-compose-up.sh &
	until nc -z application-backend 8080 ; do \
		sleep 1 ; \
	done
	@$(LOCAL_DOCKER_COMPOSE) logs application-backend
	@echo
	@echo Started Application Backend: 
	@echo View UI at http://127.0.0.1:8080/ui
	@echo Run "'make $(@:%-up=%-logs)'" to retrieve more logs
.PHONY: local-application-backend-docker-compose-up
