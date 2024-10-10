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
	@$(MAKE) go-application/backend-mod-vendor

application-backend-run: $(BACKEND_INSTALL_BIN)
	@$(BACKEND_INSTALL_BIN)
.PHONY: application-backend-run

$(BACKEND_INSTALL_BIN): application-backend-install

application-backend-install:
	@echo Installing backend...
	@cd application/backend \
	  && go install -a -ldflags "-linkmode external -extldflags -static"
	@echo Installed backend.
.PHONY: application-backend-install

LATEST_BACKEND_IMAGE ?= $(IMAGES_BASE):backend-latest

BACKEND_CONTAINER_NAME = $(PROJECT_NAME)_backend

BACKEND_IMAGE ?= $(IMAGES_BASE):backend-$(VERSION)

application-backend-image: docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print backend
	@$(DOCKER_BUILDX_BAKE) --load backend
.PHONY: application-backend-image

application-backend-image-push: docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print backend
	@$(DOCKER_BUILDX_BAKE) --load --push backend
.PHONY: application-backend-image-push

application-backend-image-push-ci: docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print backend-ci
	@$(DOCKER_BUILDX_BAKE) --push backend-ci
.PHONY: application-backend-image-push-ci

application-backend-docker-compose-run: backend-image backend-docker-rm $(GOOGLE_APPLICATION_CREDENTIALS)
	@docker run \
	  -p 8080:8080 \
	  --name $(BACKEND_CONTAINER_NAME) \
	  -v $(GOOGLE_APPLICATION_CREDENTIALS):$(GOOGLE_APPLICATION_CREDENTIALS) \
	  -e GOOGLE_APPLICATION_CREDENTIALS=$(GOOGLE_APPLICATION_CREDENTIALS) \
	  $(BACKEND_IMAGE)
.PHONY: application-backend-docker-compose-run

application-backend-docker-compose-up: application-backend-docker-compose-rm
	@$(CURDIR)/application/backend/docker-start.sh &
	@until nc -z backend 8080 ; do \
		sleep 1 ; \
	done
	@$(LOCAL_DOCKER_COMPOSE) logs backend
	@echo
	@echo Started Application Backend: 
	@echo View UI at http://127.0.0.1:8080/ui
	@echo Run "'make $(@:%-up=%-logs)'" to retrieve more logs
.PHONY: application-backend-docker-compose-up

application-backend-docker-compose-stop:
	@-$(LOCAL_DOCKER_COMPOSE) stop backend 2>/dev/null
.PHONY: application-backend-docker-compose-stop

application-backend-docker-compose-rm: application-backend-docker-compose-stop
	@$(LOCAL_DOCKER_COMPOSE) rm -f -s backend
.PHONY: application-backend-docker-compose-rm

application-backend-docker-compose-logs:
	@$(LOCAL_DOCKER_COMPOSE) logs --follow backend
.PHONY: application-backend-docker-compose-logs