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
APPLICATION_BACKEND_DIR ?= $(LOCAL_APPLICATION_DIR)/backend
APPLICATION_BACKEND_INSTALL_BIN = $(HOME)/go/bin/backend
APPLICATION_BACKEND_VENDOR = $(APPLICATION_BACKEND_DIR)/vendor

$(APPLICATION_BACKEND_VENDOR):
	@$(MAKE) go-application/backend-mod-vendor

application-backend-run: $(APPLICATION_BACKEND_INSTALL_BIN)
	@$(APPLICATION_BACKEND_INSTALL_BIN)
.PHONY: application-backend-run

$(APPLICATION_BACKEND_INSTALL_BIN): application-backend-install

application-backend-install:
	@echo Installing backend...
	@cd application/backend \
	  && go install -a -ldflags "-linkmode external -extldflags -static"
	#   && go install -a -ldflags "-linkmode external"
	@echo Installed backend.
.PHONY: application-backend-install

# Handle buildx cache in local folder
APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE=$(APPLICATION_BACKEND_DIR)/.docker-buildx-cache/
$(APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE):;	@mkdir -p "$@"
ifneq ($(wildcard $(APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)/index.json),)
APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ = type=local,src=$(APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)
endif
APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE= type=local,dest=$(APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)

application-backend-container-up: application-backend-container-rm
	@$(CURDIR)/application/backend/docker-start.sh &
	@until nc -z backend 8080 ; do \
		sleep 1 ; \
	done
	@$(LOCAL_DOCKER_COMPOSE) logs backend
	@echo
	@echo Started Application Backend: 
	@echo View UI at http://127.0.0.1:8080/ui
	@echo Run "'make $(@:%-up=%-logs)'" to retrieve more logs
.PHONY: application-backend-container-up

application-backend-container-stop:
	@-$(LOCAL_DOCKER_COMPOSE) stop backend 2>/dev/null
.PHONY: application-backend-container-stop

application-backend-container-rm: application-backend-container-stop
	@$(LOCAL_DOCKER_COMPOSE) rm -f -s backend
.PHONY: application-backend-container-rm

application-backend-container-logs:
	@$(LOCAL_DOCKER_COMPOSE) logs --follow backend
.PHONY: application-backend-container-logs