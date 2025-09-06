GIT_HEAD_VERSION ?= $(shell git describe --tags --abbrev=7 --match "v*" 2>/dev/null)

LOCAL_VERSION ?= $(GIT_HEAD_VERSION)
ifeq ($(LOCAL_VERSION),)
LOCAL_VERSION := latest
endif

VERSION ?= $(LOCAL_VERSION)

DEV_GOOGLE_CLOUD_PROJECT_ID := moov-dev-439608
GOOGLE_CLOUD_PROJECT_ID ?= $(DEV_GOOGLE_CLOUD_PROJECT_ID)

INFRA_PROJECT_NAME := moov
LOCAL_APPLICATION_TESTS_DIR := $(LOCAL_DIR)/application-tests
LOCAL_PROJECT_NAME := vegito-local

LOCAL_DOCKER_COMPOSE_SERVICES ?= \
  vault-dev \
  firebase-emulators \
  clarinet-devnet \
  application-tests \
  application-backend \
  application-mobile

export

-include git.mk
-include local.mk

LOCAL_APPLICATION_TESTS_DIR := $(LOCAL_DIR)/application-tests
LOCAL_PROJECT_NAME := vegito-local

LOCAL_DOCKER_COMPOSE_SERVICES := \
  vault-dev \
  firebase-emulators \
  clarinet-devnet \
  application-tests \
  application-backend \
  application-mobile

LOCAL_DOCKER_BUILDX_BAKE = docker buildx bake \
	-f $(LOCAL_DIR)/docker/docker-bake.hcl \
	-f $(LOCAL_DIR)/docker-bake.hcl \
	$(LOCAL_DOCKER_BUILDX_BAKE_IMAGES:%=-f $(LOCAL_DIR)/%/docker-bake.hcl) \
	-f $(LOCAL_ANDROID_DIR)/docker-bake.hcl \
	$(LOCAL_ANDROID_DOCKER_BUILDX_BAKE_IMAGES:%=-f $(LOCAL_ANDROID_DIR)/%/docker-bake.hcl) \
	-f $(LOCAL_APPLICATION_DIR)/docker-bake.hcl \
	$(APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:local-application-%=-f $(LOCAL_APPLICATION_DIR)/%/docker-bake.hcl) \
	-f $(LOCAL_DIR)/github/docker-bake.hcl

LOCAL_DOCKER_COMPOSE = docker compose \
    -f $(CURDIR)/docker-compose.yml \
    -f $(LOCAL_APPLICATION_DIR)/docker-compose.yml \
    -f $(CURDIR)/.docker-compose-override.yml \
    -f $(CURDIR)/.docker-compose-networks-override.yml \
    -f $(CURDIR)/.docker-compose-gpu-override.yml

node-modules: local-node-modules
.PHONY: node-modules

images: docker-images
.PHONY: images

images-ci: docker-images-ci
.PHONY: images-ci

images-pull: 
	@$(MAKE) -j local-dockercompose-images-pull
.PHONY: images-fast-pull

images-push: 
	@$(MAKE) -j local-dockercompose-images-push
.PHONY: images-push

dev: 
	@$(MAKE) -j local-containers-up
.PHONY: dev

dev-rm: 
	@$(MAKE) -j local-containers-rm-all
.PHONY: dev-rm

logs: local-containers-dev-logs-f
.PHONY: logs

end-to-end-tests: local-application-tests-container-run
	@echo "End-to-end tests completed successfully."
.PHONY: end-to-end-tests
