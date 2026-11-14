VEGITO_PROJECT_NAME := example-application
GIT_HEAD_VERSION := $(shell git describe --tags --abbrev=7 --match "v*" 2>/dev/null)

VEGITO_EXAMPLE_APPLICATION_VERSION ?= $(GIT_HEAD_VERSION)
ifeq ($(VEGITO_EXAMPLE_APPLICATION_VERSION),)
VEGITO_EXAMPLE_APPLICATION_VERSION := latest
endif

VERSION ?= $(VEGITO_EXAMPLE_APPLICATION_VERSION)

VEGITO_DOCKER_PUBLIC_REPOSITORY ?= registry-public.vegito.app/vegito-app

VEGITO_DOCKER_PUBLIC_REPOSITORY := $(or $(VEGITO_DOCKER_PUBLIC_REPOSITORY), $(VEGITO_DOCKER_PUBLIC_REGISTRY)/vegito-app)
VEGITO_EXAMPLE_APPLICATION_PUBLIC_DOCKER_IMAGES_BASE_NAME := $(or $(VEGITO_EXAMPLE_APPLICATION_PUBLIC_DOCKER_IMAGES_BASE_NAME), $(VEGITO_DOCKER_PUBLIC_REPOSITORY)/$(VEGITO_PROJECT_NAME))
VEGITO_EXAMPLE_APPLICATION_MOBILE_IMAGE_VERSION ?= $(VEGITO_EXAMPLE_APPLICATION_PUBLIC_DOCKER_IMAGES_BASE_NAME):mobile-$(VERSION)
VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE ?= $(VEGITO_EXAMPLE_APPLICATION_PUBLIC_DOCKER_IMAGES_BASE_NAME):backend-$(VERSION)

-include example-application.mk
-include gcloud.mk
-include git.mk
-include nodejs.mk
-include go.mk

node-modules: local-node-modules
.PHONY: node-modules

dotenv: example-application-dotenv
.PHONY: dotenv

images: example-application-docker-images-host-arch
.PHONY: images

images-ci: example-application-release-ci
.PHONY: images-ci

images-pull-ci: \
local-docker-images-pull-parallel \
example-application-docker-images-pull-parallel
.PHONY: images-pull

images-pull-ci:
	@$(MAKE) images-pull \
	  LOCAL_DOCKER_COMPOSE_SERVICES=$(LOCAL_DOCKER_COMPOSE_SERVICES_CI)
.PHONY: images-pull-ci

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
images-pull-ci \
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
.PHONY: application-mobile-dump

docker-tags-md-ci: 
	@echo "Generating Docker tags markdown for CI..."	
	@$(MAKE) VEGITO_DOCKER_BUILDX_BUILD_GROUPS=vegito-example-application \
	   vegito-docker-build-tags-list-ci-md 2>/dev/null \
	| grep -v 'make\[1\]'
.PHONY: docker-tags-md-ci

docker-login: vegito-docker-login
.PHONY: docker-login

docker-buildx-setup: vegito-docker-buildx-setup
.PHONY: docker-buildx-setup
