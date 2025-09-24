
GIT_HEAD_VERSION ?= $(shell git describe --tags --abbrev=7 --match "v*" 2>/dev/null)

LOCAL_VERSION ?= $(GIT_HEAD_VERSION)
ifeq ($(LOCAL_VERSION),)
LOCAL_VERSION := latest
endif

VERSION ?= $(LOCAL_VERSION)

export

INFRA_PROJECT_NAME := moov

DEV_GOOGLE_CLOUD_PROJECT_ID := moov-dev-439608

PROJECT_NAME := vegito-local
LOCAL_APPLICATION_TESTS_DIR := $(LOCAL_DIR)/application-tests

LOCAL_DOCKER_BUILDX_BAKE = docker buildx bake \
	-f $(LOCAL_DIR)/docker/docker-bake.hcl \
	-f $(LOCAL_DIR)/docker-bake.hcl \
	$(LOCAL_DOCKER_BUILDX_BAKE_IMAGES:%=-f $(LOCAL_DIR)/%/docker-bake.hcl) \
	-f $(LOCAL_ANDROID_DIR)/docker-bake.hcl \
	$(LOCAL_ANDROID_DOCKER_BUILDX_BAKE_IMAGES:%=-f $(LOCAL_ANDROID_DIR)/%/docker-bake.hcl) \
	-f $(LOCAL_APPLICATION_DIR)/docker-bake.hcl \
	$(APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:%=-f $(LOCAL_APPLICATION_DIR)/%/docker-bake.hcl) \
	-f $(LOCAL_DIR)/github/docker-bake.hcl

LOCAL_DOCKER_COMPOSE = docker compose \
    -f $(CURDIR)/docker-compose.yml \
    -f $(LOCAL_APPLICATION_DIR)/docker-compose.yml \
    -f $(CURDIR)/.docker-compose-services-override.yml \
    -f $(CURDIR)/.docker-compose-networks-override.yml \
    -f $(CURDIR)/.docker-compose-gpu-override.yml

-include local.mk
-include git.mk

node-modules: local-node-modules
.PHONY: node-modules

images: docker-images
.PHONY: images

images-ci: docker-images-ci
.PHONY: images-ci

images-pull: 
	@echo Pulling all images in parallel...
	@$(MAKE) -j \
	  local-docker-images-pull-parallel \
	  local-application-docker-images-pull-parallel
.PHONY: images-pull

images-push: 
	@$(MAKE) -j local-docker-images-push
.PHONY: images-push

dev: 
	@$(MAKE) -j local-containers-up
.PHONY: dev

dev-rm: local-containers-rm local-application-containers-rm
.PHONY: dev-rm

dev-ci: images-pull
	@echo "Starting CI for development containers..."
	@$(MAKE) -j \
	  local-containers-up-ci \
	  local-application-containers-up-ci
.PHONY: dev-ci
  
dev-ci-rm: local-containers-rm-ci local-application-containers-rm-ci
.PHONY: dev-ci-rm

logs: local-containers-dev-logs-f
.PHONY: logs

end-to-end-tests: local-application-tests-container-run
	@echo "End-to-end tests completed successfully."
.PHONY: end-to-end-tests
