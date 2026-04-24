ifeq ($(DOCKERHUB_ENABLED),1)
# Use the dbndev Docker Hub account
GOOGLE_CLOUD_PROJECT_DOCKER_REGISTRY ?= docker.io/dbndev

VEGITO_LOCAL_PUBLIC_IMAGES_BASE ?= $(GOOGLE_CLOUD_PROJECT_DOCKER_REGISTRY)/$(VEGITO_LOCAL_IMAGES_BASE)-public
VEGITO_LOCAL_PRIVATE_IMAGES_BASE ?= $(GOOGLE_CLOUD_PROJECT_DOCKER_REGISTRY)/$(VEGITO_LOCAL_IMAGES_BASE)-private

LOCAL_DEBIAN_IMAGE_LATEST ?= debian:bookworm
LOCAL_DEBIAN_IMAGE_VERSION ?= debian:bookworm
LOCAL_GO_IMAGE_LATEST ?= golang:alpine
LOCAL_GO_IMAGE_VERSION ?= golang:alpine
LOCAL_RUST_IMAGE_LATEST ?=rust:1-alpine3.20
LOCAL_RUST_IMAGE_VERSION ?=rust:1-alpine3.20
LOCAL_DOCKER_DIND_ROOTLESS_IMAGE_LATEST ?= docker:dind-rootless
LOCAL_DOCKER_DIND_ROOTLESS_IMAGE_VERSION ?= docker:dind-rootless
endif

local-docker-login-dockerhub:
	@echo "Logging into Docker Hub"
	@printf '%s' "$$DOCKERHUB_PAT" | docker login \
	  --username "$$DOCKERHUB_USERNAME" \
	  --password-stdin
.PHONY: local-docker-login-dockerhub