
VEGITO_DOCKER_HUB_REGISTRY ?= docker.io/dbndev

DOCKERHUB_USERNAME ?= $(VEGITO_DOCKERHUB_USERNAME)
DOCKERHUB_PAT ?= $(VEGITO_DOCKERHUB_PAT)

LOCAL_DEBIAN_IMAGE_LATEST ?= debian:bookworm
LOCAL_DEBIAN_IMAGE_VERSION ?= debian:bookworm
LOCAL_GO_IMAGE_LATEST ?= golang:alpine
LOCAL_GO_IMAGE_VERSION ?= golang:alpine
LOCAL_RUST_IMAGE_LATEST ?=rust:1-alpine3.20
LOCAL_RUST_IMAGE_VERSION ?=rust:1-alpine3.20
LOCAL_DOCKER_DIND_ROOTLESS_IMAGE_LATEST ?= docker:dind-rootless
LOCAL_DOCKER_DIND_ROOTLESS_IMAGE_VERSION ?= docker:dind-rootless

local-docker-login-dockerhub:
	@echo "Logging into Docker Hub"
	@printf '%s' "$$DOCKERHUB_PAT" | docker login \
	  --username "$$DOCKERHUB_USERNAME" \
	  --password-stdin
.PHONY: local-docker-login-dockerhub

LOCAL_DOCKERHUB_DOCKER_BUILDX_BUILD_GROUPS ?= \
  tools \
  runners \
  builders \
  services \
  applications

local-docker-images-dockerhub-release:
	echo "🚀 Building for $(@:local-docker-images-%=%)"
	$(MAKE) local-docker-images-release \
	  LOCAL_DOCKER_BUILDX_BUILD_GROUPS="$(LOCAL_DOCKERHUB_DOCKER_BUILDX_BUILD_GROUPS)" \
	  VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME=$(VEGITO_DOCKER_HUB_REGISTRY)/$(VEGITO_LOCAL_IMAGES_BASE)-public \
	  VEGITO_LOCAL_PRIVATE_IMAGES_BASE=$(VEGITO_DOCKER_HUB_REGISTRY)/$(VEGITO_LOCAL_IMAGES_BASE)-private \
.PHONY: local-docker-images-dockerhub-release

local-docker-images-dockerhub-release-ci:
	@echo "🚀 Building for $(@:local-docker-images-%-ci=%)"
	@$(MAKE) local-docker-images-release-ci \
	  LOCAL_DOCKER_BUILDX_BUILD_GROUPS="$(LOCAL_DOCKERHUB_DOCKER_BUILDX_BUILD_GROUPS)" \
	  VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME=$(VEGITO_DOCKER_HUB_REGISTRY)/$(VEGITO_LOCAL_IMAGES_BASE)-public \
	  VEGITO_LOCAL_PRIVATE_IMAGES_BASE=$(VEGITO_DOCKER_HUB_REGISTRY)/$(VEGITO_LOCAL_IMAGES_BASE)-private \
.PHONY: local-docker-images-dockerhub-release-ci
