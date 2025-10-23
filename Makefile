VEGITO_PROJECT_NAME := vegito-local
GIT_HEAD_VERSION ?= $(shell git describe --tags --abbrev=7 --match "v*" 2>/dev/null)

LOCAL_VERSION ?= $(GIT_HEAD_VERSION)
ifeq ($(LOCAL_VERSION),)
LOCAL_VERSION := latest
endif

VERSION ?= $(LOCAL_VERSION)

export

INFRA_PROJECT_NAME := moov

DEV_GOOGLE_CLOUD_PROJECT_ID := moov-dev-439608

DEV_GOOGLE_CLOUD_PROJECT_NAME   ?= $(INFRA_PROJECT_NAME)-dev
DEV_GOOGLE_CLOUD_PROJECT_ID     ?= $(DEV_GOOGLE_CLOUD_PROJECT_NAME)-439608
DEV_GOOGLE_CLOUD_PROJECT_NUMBER ?= 203475703228

STAGING_GOOGLE_CLOUD_PROJECT_NAME   ?= $(INFRA_PROJECT_NAME)-staging
STAGING_GOOGLE_CLOUD_PROJECT_ID     ?= $(STAGING_GOOGLE_CLOUD_PROJECT_NAME)-440506
STAGING_GOOGLE_CLOUD_PROJECT_NUMBER ?= 326118600145

PROD_GOOGLE_CLOUD_PROJECT_NAME   ?= $(INFRA_PROJECT_NAME)
PROD_GOOGLE_CLOUD_PROJECT_ID     ?= $(PROD_GOOGLE_CLOUD_PROJECT_NAME)-438615
PROD_GOOGLE_CLOUD_PROJECT_NUMBER ?= 378762893981

STAGING_GOOGLE_CLOUD_PROJECT_NAME   ?= $(INFRA_PROJECT_NAME)-staging
STAGING_GOOGLE_CLOUD_PROJECT_ID     ?= $(STAGING_GOOGLE_CLOUD_PROJECT_NAME)-440506
STAGING_GOOGLE_CLOUD_PROJECT_NUMBER ?= 326118600145

LOCAL_ROBOTFRAMEWORK_TESTS_DIR := $(LOCAL_DIR)/robotframework

LOCAL_DOCKER_BUILDX_BAKE = docker buildx bake \
	-f $(LOCAL_DIR)/docker/docker-bake.hcl \
	-f $(LOCAL_DIR)/docker-bake.hcl \
	$(LOCAL_DOCKER_BUILDX_BAKE_IMAGES:%=-f $(LOCAL_DIR)/%/docker-bake.hcl) \
	-f $(LOCAL_ANDROID_DIR)/docker-bake.hcl \
	$(LOCAL_ANDROID_DOCKER_BUILDX_BAKE_IMAGES:%=-f $(LOCAL_ANDROID_DIR)/%/docker-bake.hcl) \
	-f $(EXAMPLE_APPLICATION_DIR)/docker-bake.hcl \
	$(APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:%=-f $(EXAMPLE_APPLICATION_DIR)/%/docker-bake.hcl) \
	-f $(LOCAL_DIR)/github-actions/docker-bake.hcl

LOCAL_DOCKER_COMPOSE = docker compose \
    -f $(CURDIR)/docker-compose.yml \
    -f $(EXAMPLE_APPLICATION_DIR)/docker-compose.yml \
    -f $(CURDIR)/.docker-compose-services-override.yml \
    -f $(CURDIR)/.docker-compose-networks-override.yml \
    -f $(CURDIR)/.docker-compose-gpu-override.yml

LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES = \
  studio

-include local.mk
-include git.mk
-include nodejs.mk
-include go.mk

node-modules: local-node-modules
.PHONY: node-modules

images: docker-images
.PHONY: images

images-ci: docker-images-ci
.PHONY: images-ci

images-pull: local-docker-images-pull-parallel local-android-docker-images-pull-parallel example-application-docker-images-pull-parallel
.PHONY: images-pull

images-push: local-docker-images-push local-application-docker-images-push
.PHONY: images-push

dev: local-containers-up local-android-containers-up example-application-containers-up
.PHONY: dev

dev-rm: example-application-containers-rm local-containers-rm local-android-containers-rm
.PHONY: dev-rm

dev-ci: images-pull local-containers-up-ci example-application-containers-up-ci
	@echo "🟢 Development environment is up and running in CI mode."
.PHONY: dev-ci

application-mobile-image-extract-android-artifacts: local-android-mobile-image-tag-release-extract
	@echo "✅ Extracted Android release artifacts successfully."
.PHONY: application-mobile-image-extract-android-artifacts

dev-ci-rm: \
local-dev-container-image-pull \
local-containers-rm-ci \
example-application-containers-rm-ci \
local-docker-compose-network-rm-dev
.PHONY: dev-ci-rm

logs: local-dev-container-logs-f
.PHONY: logs

end-to-end-tests: local-robotframework-tests-container-run
	@echo "End-to-end tests completed successfully."
.PHONY: end-to-end-tests
