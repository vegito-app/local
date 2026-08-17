
export VEGITO_DOCKER_PUBLIC_REPOSITORY ?= docker.io/dbndev

DOCKERHUB_USERNAME ?= $(VEGITO_DOCKERHUB_USERNAME)
DOCKERHUB_PAT ?= $(VEGITO_DOCKERHUB_PAT)

export VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME  ?= $(VEGITO_DOCKER_PUBLIC_REPOSITORY)/vegito-public

vegito-docker-login-dockerhub:
	@echo "Logging into Docker Hub"
	@printf '%s' "$$VEGITO_DOCKERHUB_PAT" | docker login \
	  --username "$$VEGITO_DOCKERHUB_USERNAME" \
	  --password-stdin
.PHONY: vegito-docker-login-dockerhub

VEGITO_DOCKERHUB_DOCKER_BUILDX_BUILD_GROUPS ?= \
  tools \
  runners \
  builders \
  services \
  applications

vegito-docker-images-dockerhub-release:
	@echo "🚀 Building for $(@:vegito-docker-images-%=%)"
	@$(MAKE) vegito-docker-images-release \
	  VEGITO_DOCKER_BUILDX_BUILD_GROUPS="$(VEGITO_DOCKERHUB_DOCKER_BUILDX_BUILD_GROUPS)" \
	  VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME=$(VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME) \
	  VEGITO_DOCKER_PUBLIC_REPOSITORY=$(VEGITO_DOCKER_PUBLIC_REPOSITORY)
.PHONY: vegito-docker-images-dockerhub-release
# 	  VEGITO_DOCKER_PRIVATE_IMAGES_BASE=$(VEGITO_DOCKER_HUB_REGISTRY)/$(VEGITO_DOCKER_IMAGES_BASE)-private

vegito-docker-images-dockerhub-release-ci:
	@echo "🚀 Building for $(@:vegito-docker-images-%-ci=%)"
	@$(MAKE) vegito-docker-images-release-ci \
	  VEGITO_DOCKER_BUILDX_BUILD_GROUPS="$(VEGITO_DOCKERHUB_DOCKER_BUILDX_BUILD_GROUPS)" \
	  VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME=$(VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME) \
	  VEGITO_DOCKER_PUBLIC_REPOSITORY=$(VEGITO_DOCKER_PUBLIC_REPOSITORY)
.PHONY: vegito-docker-images-dockerhub-release-ci
# 	  VEGITO_DOCKER_PRIVATE_IMAGES_BASE=$(VEGITO_DOCKER_HUB_REGISTRY)/$(VEGITO_DOCKER_IMAGES_BASE)-private
