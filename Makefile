VEGITO_PROJECT_NAME := vegito-local
GIT_HEAD_VERSION := $(shell git describe --tags --abbrev=7 --match "v*" 2>/dev/null)

VERSION ?= $(GIT_HEAD_VERSION)

ifeq ($(strip $(VERSION)),)
VERSION := latest
endif

LOCAL_VERSION ?= $(VERSION)

COMPOSE_PROJECT_NAME ?= $(VEGITO_PROJECT_NAME)-$(VEGITO_PROJECT_USER)
# LOCAL_DOCKER_BUILDX_CI_BUILD_GROUPS := # applications

export VEGITO_DOCKER_REGISTRIES ?= dockerhub

# Use docker.io as the default registry for local public images, but allow overriding it if needed.
# Remove after gcr is back in shape and can be used as the default registry for local public images.
export VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME ?= docker.io/dbndev/vegito-local-public
export VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME ?= docker.io/dbndev/vegito-public
export VEGITO_DOCKER_PRIVATE_IMAGES_BASE_NAME ?= docker.io/dbndev/vegito-private
export VEGITO_DOCKER_TRIXIE_DEBIAN_OBS_VSCODE_GOLANG_AI_DOCKER_DESKTOP_X_IMAGE_LATEST ?= docker.io/dbndev/vegito-public:trixie-debian-obs-vscode-golang-ai-docker-latest
export VEGITO_DOCKER_TRIXIE_DEBIAN_IMAGE_VERSION ?= docker.io/dbndev/vegito-public:trixie-debian-latest
export LOCAL_ROBOTFRAMEWORK_TESTS_DIR = $(VEGITO_EXAMPLE_APPLICATION_TESTS_DIR)/robot
export LOCAL_ROBOTFRAMEWORK_TESTS_OUTPUT_DIR ?= $(VEGITO_EXAMPLE_APPLICATION_TESTS_DIR)/output

LOCAL_DOCKER_BUILDX_BAKE ?= \
  VEGITO_EXAMPLE_APPLICATION_BUILDER_BASE_CONTEXT_CI=target:vegito-debian-project-builder-version-ci \
  VEGITO_EXAMPLE_APPLICATION_MOBILE_BUILDER_CONTEXT_CI=target:local-android-flutter-version-ci \
  VEGITO_EXAMPLE_APPLICATION_MOBILE_RUNNER_CONTEXT_CI=target:local-android-appium-version-ci \
  VEGITO_EXAMPLE_APPLICATION_TESTS_ROBOTFRAMEWORK_CONTEXT_CI=target:local-robotframework-version-ci \
  docker buildx bake \
  -f $(LOCAL_DIR)/docker-bake.hcl \
  $(LOCAL_DOCKER_BUILDX_BAKE_IMAGES:%=-f $(LOCAL_DIR)/%/docker-bake.hcl) \
  -f $(LOCAL_ANDROID_DIR)/docker-bake.hcl \
  $(LOCAL_ANDROID_DOCKER_BUILDX_BAKE_IMAGES:%=-f $(LOCAL_ANDROID_DIR)/%/docker-bake.hcl) \
  -f $(LOCAL_DIR)/github-actions/docker-bake.hcl \
  -f $(VEGITO_EXAMPLE_APPLICATION_DIR)/docker-bake.hcl \
  $(EXAMPLE_APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:%=-f $(VEGITO_EXAMPLE_APPLICATION_DIR)/%/docker-bake.hcl)
  
VEGITO_DOCKER_BUILDX_BAKE = $(LOCAL_DOCKER_BUILDX_BAKE)

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

LOCAL_DOCKER_BUILDX_BUILD_GROUPS ?= \
  tools \
  runners \
  builders \
  services \
  applications
#   dockerhub \

GCLOUD ?= $(LOCAL_DOCKER_COMPOSE) run -it --rm --entrypoint=gcloud dev --project=$(GOOGLE_CLOUD_PROJECT_ID)

LOCAL_TRIVY_IMAGE_SCAN_INPUT_IMAGE ?= $(VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME):example-application-$(VERSION)

VEGITO_DOCKER_BUILDX_BAKE ?= $(LOCAL_DOCKER_BUILDX_BAKE)

-include local.mk
-include docker.mk
-include gcloud.mk
-include android.mk
-include git.mk
-include nodejs.mk
-include go.mk

LOCAL_DEVCONTAINERS_DOCKER_COMPOSE_SERVICES ?= \
  android-studio \
  firebase-emulators \
  nestor \
  vault-dev \
  robotframework \
  $(VEGITO_DOCKER_COMPOSE_SERVICES:%=vegito-%)
#   $(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=android-%) \


-include .devcontainer/devcontainer.mk

node-modules: local-node-modules
.PHONY: node-modules

dotenv: local-dotenv
.PHONY: dotenv

# Local/dev: build all images without pushing them.
# Tags are generated for all configured registries.
images: vegito-docker-images-multi-registry-release
.PHONY: images

# Local/dev: build images in smaller groups without pushing them.
# Useful when full parallel builds are too heavy for the workstation.
images-groups-build: vegito-docker-images
.PHONY: images-groups-build

# CI: build and push all images in parallel.
# Fastest path; requires runners with enough CPU, RAM and disk I/O.
images-ci:  \
vegito-docker-login \
vegito-docker-images-multi-registry-release-ci
.PHONY: images-ci

# CI: build and push images in smaller groups.
# Safer on constrained runners; slower than the full parallel path.
images-groups-build-ci:  \
vegito-docker-login \
vegito-docker-images-ci
.PHONY: images-groups-build-ci

images-pull: \
vegito-docker-images-pull-parallel \
vegito-android-docker-images-pull-parallel \
example-application-docker-images-pull-parallel
.PHONY: images-pull

images-push: \
vegito-docker-login \
vegito-docker-images-push \
local-application-docker-images-push
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

docker-tags-md-ci: docker-build-tags-list-ci-md
.PHONY: docker-tags-md-ci

docker-login: vegito-docker-login
.PHONY: docker-login