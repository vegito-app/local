VEGITO_PROJECT_NAME := vegito-local
GIT_HEAD_VERSION ?= $(shell git describe --tags --abbrev=7 --match "v*" 2>/dev/null)

COMPOSE_PROJECT_NAME ?= $(VEGITO_PROJECT_NAME)-$(VEGITO_PROJECT_USER)
# LOCAL_DOCKER_BUILDX_CI_BUILD_GROUPS := # applications
ifdef VERSION
LOCAL_VERSION := $(VERSION)
endif

LOCAL_VERSION ?= $(GIT_HEAD_VERSION)

ifeq ($(LOCAL_VERSION),)
LOCAL_VERSION := latest
endif

VERSION ?= $(LOCAL_VERSION)

export

LOCAL_ROBOTFRAMEWORK_TESTS_DIR = $(VEGITO_EXAMPLE_APPLICATION_TESTS_DIR)/robot

LOCAL_DOCKER_BUILDX_BAKE ?= docker buildx bake \
	-f $(LOCAL_DIR)/docker/docker-bake.hcl \
	-f $(LOCAL_DIR)/docker-bake.hcl \
	$(LOCAL_DOCKER_BUILDX_BAKE_IMAGES:%=-f $(LOCAL_DIR)/%/docker-bake.hcl) \
	-f $(LOCAL_ANDROID_DIR)/docker-bake.hcl \
	$(LOCAL_ANDROID_DOCKER_BUILDX_BAKE_IMAGES:%=-f $(LOCAL_ANDROID_DIR)/%/docker-bake.hcl) \
	-f $(VEGITO_EXAMPLE_APPLICATION_DIR)/docker-bake.hcl \
	$(EXAMPLE_APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:%=-f $(VEGITO_EXAMPLE_APPLICATION_DIR)/%/docker-bake.hcl) \
	-f $(LOCAL_DIR)/github-actions/docker-bake.hcl

LOCAL_DOCKER_COMPOSE ?= docker compose \
    -f $(CURDIR)/docker-compose.yml \
    -f $(VEGITO_EXAMPLE_APPLICATION_DIR)/docker-compose.yml \
  	-f $(CURDIR)/trivy/docker-compose.yml \
    -f $(CURDIR)/.docker-compose-services-override.yml \
    -f $(CURDIR)/.docker-compose-networks-override.yml \
    -f $(CURDIR)/.docker-compose-gpu-override.yml

LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES ?= \
  studio

LOCAL_DOCKER_COMPOSE_SERVICES ?= \
  firebase-emulators \
  vault-dev \
  robotframework \
  trivy
#   clarinet-devnet \

LOCAL_TRIVY_IMAGE_SCAN_INPUT_IMAGE ?= $(VEGITO_LOCAL_PUBLIC_IMAGES_BASE):example-application-$(VERSION)

-include gcloud.mk
-include go.mk
-include nodejs.mk
-include android.mk
-include local.mk
-include git.mk

LOCAL_GO_MODULES += \
 $(VEGITO_EXAMPLE_APPLICATION_BACKEND_DIR)

LOCAL_DEVCONTAINERS_DOCKER_COMPOSE_SERVICES ?= \
  firebase-emulators \
  vault-dev \
  robotframework \
  $(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=android-%) \
  $(VEGITO_DOCKER_COMPOSE_SERVICES:%=vegito-%)

-include .devcontainer/devcontainer.mk

node-modules: local-node-modules
.PHONY: node-modules

dotenv: local-dotenv
.PHONY: dotenv

images: local-docker-images
.PHONY: images

images-ci: \
local-docker-images-ci \
vegito-example-application-builders-ci \
example-application-docker-images-multi-arch
.PHONY: images-ci

images-pull: \
local-docker-images-pull-parallel \
local-android-docker-images-pull-parallel \
example-application-docker-images-pull-parallel
.PHONY: images-pull

images-push: local-docker-images-push local-application-docker-images-push
.PHONY: images-push

devcontainer: devcontainer-vscode
.PHONY: devcontainer

devcontainer-codespaces: devcontainer-vscode-codespaces
.PHONY: devcontainer-codespaces

dev: \
local-containers-up \
local-android-containers-up \
example-application-backend-container-up \
example-application-mobile-container-up
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
example-application-mobile-container-up-ci
	@echo "🟢 Development environment is up and running in CI mode."
.PHONY: dev-ci

application-mobile-image-extract-android-artifacts: \
example-application-mobile-image-pull \
example-application-mobile-extract-android-artifacts
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
.PHONY: application-mobile-dump

dev-ci-rm: \
local-dev-container-image-pull \
local-containers-rm-ci \
example-application-containers-rm-ci \
local-docker-compose-network-rm-dev
.PHONY: dev-ci-rm

logs: local-dev-container-logs-f
.PHONY: logs

containers-logs-ci: local-containers-logs-ci example-application-containers-logs-ci
	@echo "✅ Retrieved CI containers logs successfully."
.PHONY: containers-logs-ci

functional-tests: local-robotframework-container-exec
	@echo "End-to-end tests completed successfully."
.PHONY: functional-tests

functional-tests-ci: example-application-tests-container-up
	@echo "End-to-end tests completed successfully."
.PHONY: functional-tests-ci

test-local: example-application-tests-robot-all
	@echo "End-to-end tests completed successfully."
.PHONY: test-local

docker-build-tags-list-ci-md:
	@echo "### 🐳 Docker Images Built (excluding latest):"
	@set -e; for group in $(LOCAL_DOCKER_BUILDX_CI_BUILD_GROUPS); do \
	  echo "#### Group: '$$group'" ; \
	 $(MAKE) local-$$group-docker-group-tags-list-ci \
	 | grep -vE 'latest$$' \
	 | grep -v 'make\[1\]\:' \
	 | sed 's/^/- /' || echo "_no tags for group '$$group'_" ; \
	  echo "" ; \
	done
.PHONY: docker-build-tags-list-ci-md