APPLICATION_BACKEND_DIR ?= $(APPLICATION_DIR)/backend

APPLICATION_BACKEND_INSTALL_BIN = $(HOME)/go/bin/backend
APPLICATION_BACKEND_VENDOR = $(APPLICATION_DIR)/backend/vendor

$(APPLICATION_BACKEND_VENDOR):
	@$(MAKE) go-backend-mod-vendor

application-backend-run: $(APPLICATION_BACKEND_INSTALL_BIN)
	@$(APPLICATION_BACKEND_INSTALL_BIN)
.PHONY: application-backend-run

$(APPLICATION_BACKEND_INSTALL_BIN): application-backend-install

application-backend-install:
	@echo Installing backend...
	@cd $(APPLICATION_DIR)/backend \
	  && go install -a -ldflags "-linkmode external -extldflags -static"
	#   && go install -a -ldflags "-linkmode external"
	@echo Installed backend.
.PHONY: application-backend-install

# Handle buildx cache in local folder
APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE ?= $(APPLICATION_DIR)/.containers/docker-buildx-cache/application-backend
$(APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE):;	@mkdir -p "$@"
ifneq ($(wildcard $(APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)/index.json),)
APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ = type=local,src=$(APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)
endif
APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE= type=local,mode=max,dest=$(APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)
APPLICATION_BACKEND_IMAGE ?= $(PRIVATE_IMAGES_BASE):application-backend-latest

local-application-backend-container-up: local-application-backend-container-rm
	@echo Starting Application Backend...
	@$(APPLICATION_DIR)/backend/docker-compose-up.sh &
	until nc -z application-backend 8080 ; do \
		sleep 1 ; \
	done
	@$(LOCAL_DOCKER_COMPOSE) logs application-backend
	@echo
	@echo Started Application Backend: 
	@echo View UI at http://127.0.0.1:8080/ui
	@echo Run "'make $(@:%-up=%-logs)'" to retrieve more logs
.PHONY: local-application-backend-container-up

application-backend-gcloud-backend-images-delete-all:
	@echo "🗑️  Deleting backend image $(APPLICATION_BACKEND_IMAGE)..."
	@$(GCLOUD) container images delete --force-delete-tags $(APPLICATION_BACKEND_IMAGE)
.PHONY: application-backend-gcloud-backend-images-delete-all
