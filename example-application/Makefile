VEGITO_PROJECT_NAME := example-application
LOCAL_DIR := $(CURDIR)/local
GIT_HEAD_VERSION ?= $(shell git describe --tags --abbrev=7 --match "v*" 2>/dev/null)

VEGITO_EXAMPLE_APPLICATION_VERSION ?= $(GIT_HEAD_VERSION)
ifeq ($(VEGITO_EXAMPLE_APPLICATION_VERSION),)
VEGITO_EXAMPLE_APPLICATION_VERSION := latest
endif

VERSION ?= $(VEGITO_EXAMPLE_APPLICATION_VERSION)

# Version of the vegito-app/local development environment images to use.
LOCAL_VERSION ?= v1.11.0

export

INFRA_PROJECT_NAME := moov

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
	-f $(CURDIR)/docker-bake.hcl \
	$(APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:%=-f $(VEGITO_EXAMPLE_APPLICATION_DIR)/%/docker-bake.hcl) \
	-f $(LOCAL_DIR)/github-actions/docker-bake.hcl

LOCAL_DOCKER_COMPOSE = docker compose \
    -f $(CURDIR)/docker-compose.yml \
    -f $(LOCAL_DIR)/docker-compose.yml \
    -f $(CURDIR)/.docker-compose-services-override.yml \
    -f $(CURDIR)/.docker-compose-networks-override.yml \
    -f $(CURDIR)/.docker-compose-gpu-override.yml

LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES = \
  studio

-include example-application.mk
-include nodejs.mk
-include go.mk
-include git.mk

node-modules: local-node-modules
.PHONY: node-modules

dotenv: example-application-dotenv
.PHONY: dotenv

images: example-application-docker-images
.PHONY: images

images-ci: example-application-docker-images-ci
.PHONY: images-ci

images-pull: \
local-docker-images-pull-parallel \
example-application-docker-images-pull-parallel
.PHONY: images-pull

images-push: \
local-docker-images-push \
example-application-docker-images-push
.PHONY: images-push

dev: \
local-containers-up \
local-android-containers-up \
example-application-backend-container-up \
example-application-mobile-container-up
	@echo "🟢 Development environment is up and running."
.PHONY: dev

dev-rm: \
example-application-containers-rm \
local-containers-rm \
local-android-containers-rm
.PHONY: dev-rm

dev-ci: \
images-pull \
local-containers-up-ci \
example-application-backend-container-up-ci \
example-application-mobile-container-up-ci \
example-application-mobile-wait-for-boot
	@echo "🟢 Development environment is up and running in CI mode."
.PHONY: dev-ci

dev-ci-rm: \
example-application-tests-container-rm-ci \
example-application-containers-rm-ci \
local-containers-rm-ci \
local-dev-container-image-pull
.PHONY: dev-ci-rm

logs: local-dev-container-logs-f
.PHONY: logs

containers-logs-ci: \
local-containers-logs-ci \
example-application-containers-logs-ci
	@echo "✅ Retrieved CI containers logs successfully."
.PHONY: containers-logs-ci

functional-tests: local-robotframework-container-exec
	@echo "End-to-end tests completed successfully."
.PHONY: functional-tests

functional-tests-ci: example-application-tests-container-up
	@echo "End-to-end tests completed successfully."
.PHONY: functional-tests

test-local: example-application-tests-robot-all
	@echo "End-to-end tests completed successfully."
.PHONY: test-local

application-mobile-image-extract-android-artifacts: example-application-mobile-extract-android-artifacts
	@echo "✅ Extracted Android release artifacts successfully."
.PHONY: application-mobile-image-extract-android-artifacts

application-mobile-wait-for-boot: example-application-mobile-wait-for-boot
	@echo "✅ Booted mobile application successfully."
.PHONY: application-mobile-wait-for-boot

application-mobile-screenshot: example-application-mobile-screenshot
	@echo "✅ Captured mobile application screenshot successfully."
.PHONY: application-mobile-screenshot

application-mobile-dump: example-application-mobile-dump
	@echo "✅ Dumped mobile application successfully."
.PHONY: application-mobile-dum

docker-build-tags-list-ci-md:
	@echo "### 🐳 Docker Images Built (excluding latest):"
	@$(MAKE) example-application-docker-group-tags-list-ci 2>/dev/null \
	 | grep -vE 'latest$$' \
	 | grep -v 'make\[1\]\:' \
	 | sed 's/^/- /' || echo "_no tags for group '$$group'_" ; \
	  echo "" 
.PHONY: docker-build-tags-list-ci-md