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

APPLICATION_BACKEND_INSTALL_BIN = $(HOME)/go/bin/backend
APPLICATION_BACKEND_VENDOR = $(CURDIR)/backend/vendor

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

LATEST_APPLICATION_BACKEND_IMAGE = $(IMAGES_BASE):backend-latest

APPLICATION_BACKEND_CONTAINER_NAME = $(GOOGLE_CLOUD_PROJECT_ID)_backend

# Handle buildx cache in local folder
APPLICATION_BACKEND_IMAGE = $(IMAGES_BASE):backend-$(VERSION)
APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE=$(CURDIR)/.docker-buildx-cache/application-backend
$(APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE):;	@mkdir -p "$@"
ifneq ($(wildcard $(APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)/index.json),)
APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ = type=local,src=$(APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)
endif
APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE= type=local,dest=$(APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)

application-backend-image: $(APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)
	@$(DOCKER_BUILDX_BAKE) --print backend
	@$(DOCKER_BUILDX_BAKE) --load backend
.PHONY: application-backend-image

application-backend-image-ci: $(APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)
	@$(DOCKER_BUILDX_BAKE) --print backend-ci
	@$(DOCKER_BUILDX_BAKE) --load backend-ci
.PHONY: application-backend-image-ci

application-backend-image-push: $(APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)
	@$(DOCKER_BUILDX_BAKE) --print backend
	@$(DOCKER_BUILDX_BAKE) --push backend
.PHONY: application-backend-image-push

# Push application-backend images on each environments
$(INFRA_ENV:%=application-backend-%-image-push):
	@INFRA_ENV=$(@:application-backend-%-image-push=%) $(MAKE) application-backend-image-push
.PHONY: $(INFRA_ENV:%=application-backend-%-image-push)

application-backend-image-push-ci: docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print backend-ci
	@$(DOCKER_BUILDX_BAKE) --push backend-ci
.PHONY: application-backend-image-push-ci

application-backend-docker-compose-run: backend-image backend-docker-rm $(GOOGLE_APPLICATION_CREDENTIALS)
	@docker run \
	  -p 8080:8080 \
	  --name $(APPLICATION_BACKEND_CONTAINER_NAME) \
	  -v $(GOOGLE_APPLICATION_CREDENTIALS):$(GOOGLE_APPLICATION_CREDENTIALS) \
	  -e GOOGLE_APPLICATION_CREDENTIALS=$(GOOGLE_APPLICATION_CREDENTIALS) \
	  $(APPLICATION_BACKEND_IMAGE)
.PHONY: application-backend-docker-compose-run

application-backend-docker-compose-up: application-backend-docker-compose-rm
	@$(CURDIR)/application/backend/docker-compose-up.sh &
	@until nc -z backend 8080 ; do \
		sleep 1 ; \
	done
	@$(DOCKER_COMPOSE) logs backend
	@echo
	@echo Started Application Backend: 
	@echo View UI at http://127.0.0.1:8080/ui
	@echo Run "'make $(@:%-up=%-logs)'" to retrieve more logs
.PHONY: application-backend-docker-compose-up

application-backend-docker-compose-stop:
	@-$(DOCKER_COMPOSE) stop backend 2>/dev/null
.PHONY: application-backend-docker-compose-stop

application-backend-docker-compose-rm: application-backend-docker-compose-stop
	@$(DOCKER_COMPOSE) rm -f -s backend
.PHONY: application-backend-docker-compose-rm

application-backend-docker-compose-logs:
	@$(DOCKER_COMPOSE) logs --follow backend
.PHONY: application-backend-docker-compose-logs