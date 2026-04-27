LOCAL_DOCKER_DIR ?= $(LOCAL_DIR)/docker
include $(LOCAL_DOCKER_DIR)/dockerhub.mk

GOOGLE_CLOUD_DOCKER_REGISTRY ?= $(GOOGLE_CLOUD_REGION)-docker.pkg.devs
GOOGLE_CLOUD_PROJECT_DOCKER_REGISTRY ?= $(GOOGLE_CLOUD_DOCKER_REGISTRY)/$(GOOGLE_CLOUD_PROJECT_ID)

VEGITO_LOCAL_IMAGES_BASE ?= vegito-local

VEGITO_PRIVATE_REPOSITORY ?= $(GOOGLE_CLOUD_PROJECT_DOCKER_REGISTRY)/docker-repository-private

VEGITO_CACHE_REPOSITORY ?= $(GOOGLE_CLOUD_PROJECT_DOCKER_REGISTRY)/docker-repository-cache
VEGITO_LOCAL_CACHE_IMAGES_BASE ?= $(VEGITO_CACHE_REPOSITORY)/$(VEGITO_LOCAL_IMAGES_BASE)

VEGITO_PUBLIC_REPOSITORY ?= $(GOOGLE_CLOUD_PROJECT_DOCKER_REGISTRY)/docker-repository-public
VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME ?= $(VEGITO_PUBLIC_REPOSITORY)/$(VEGITO_LOCAL_IMAGES_BASE)

ENABLE_LOCAL_CACHE ?= $(VEGITO_DOCKER_BUILD_ENABLE_LOCAL_CACHE)

local-docker-login-gcr: gcloud-auth-docker local-docker-login
	@echo "Logging into $(GOOGLE_CLOUD_PROJECT_DOCKER_REGISTRY)"
	@docker login $(GOOGLE_CLOUD_PROJECT_DOCKER_REGISTRY)
.PHONY: local-docker-login-gcr

local-docker-login: $(VEGITO_DOCKER_REGISTRIES:%=local-docker-login-%)
	@echo "🔐 Logged into: $(VEGITO_DOCKER_REGISTRIES)"
.PHONY: local-docker-login

docker-sock:
	sudo chmod o+rw /var/run/docker.sock
.PHONY: docker-sock

docker-clean: 
	@docker system prune --all --force
.PHONY: docker-clean

# Groups are used to manage the build process. 
# If an image is built in a group, all images in that group are built together.
LOCAL_DOCKER_BUILDX_BUILD_GROUPS ?= \
  dockerhub \
  tools \
  runners \
  builders \
  services \
  applications

# Build all images (dev)
# In this variant, images are built and loaded into the local Docker daemon.
# The build does not push images to a remote registry.
local-docker-images: $(LOCAL_DOCKER_BUILDX_BUILD_GROUPS:%=local-%-docker-images)
.PHONY: local-docker-images

$(LOCAL_DOCKER_BUILDX_BUILD_GROUPS:%=local-%-docker-images): local-docker-buildx-setup
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:local-%-docker-images=local-%)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --load $(@:local-%-docker-images=local-%)
.PHONY: $(LOCAL_DOCKER_BUILDX_BUILD_GROUPS:%=local-%-docker-images)

VEGITO_DOCKER_REGISTRIES ?= gcr dockerhub

local-docker-images-multi-registry-release: $(VEGITO_DOCKER_REGISTRIES:%=local-docker-images-%-release)
	@echo "✅ DevBuilt local images tagged for all registries successfully. No push performed."
.PHONY: local-docker-images-multi-registry-release

local-docker-images-gcr-release: local-docker-images-release
.PHONY: local-docker-images-gcr-release

# Build all images (CI)
# In this variant, images are built and pushed to the remote registry.
local-docker-images-ci: $(LOCAL_DOCKER_BUILDX_BUILD_GROUPS:%=local-%-docker-images-ci)
.PHONY: local-docker-images-ci

$(LOCAL_DOCKER_BUILDX_BUILD_GROUPS:%=local-%-docker-images-ci): local-docker-buildx-setup
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:%-docker-images-ci=%-ci)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push $(@:%-docker-images-ci=%-ci)
.PHONY: $(LOCAL_DOCKER_BUILDX_BUILD_GROUPS:%=local-%-docker-images-ci)

local-docker-images-multi-registry-release-ci: $(VEGITO_DOCKER_REGISTRIES:%=local-docker-images-%-release-ci)
	@echo "✅ CI Built and pushed images to all registries successfully."
.PHONY: local-docker-images-multi-registry-release-ci

local-docker-images-gcr-release-ci: local-docker-images-release-ci
.PHONY: local-docker-gcr-images-ci

local-docker-group-tags-list-ci: $(LOCAL_DOCKER_BUILDX_BUILD_GROUPS:%=local-%-docker-group-tags-list-ci)
.PHONY: local-docker-group-tags-list-ci

$(LOCAL_DOCKER_BUILDX_BUILD_GROUPS:%=local-%-docker-group-tags-list-ci):
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:local-%-docker-group-tags-list-ci=local-%-ci) | jq -r '.target | to_entries[] | .value.tags[]'
.PHONY: $(LOCAL_DOCKER_BUILDX_BUILD_GROUPS:%=local-%-docker-group-tags-list-ci)

docker-build-tags-list-ci-md:
	@echo "### 🐳 Docker Images Built (excluding latest):"
	@set -e; for group in $(LOCAL_DOCKER_BUILDX_BUILD_GROUPS); do \
	  echo "#### Group: '$$group'" ; \
	 $(MAKE) local-$$group-docker-group-tags-list-ci \
	 | grep -vE 'latest$$' \
	 | grep -v 'make\[1\]\:' \
	 | sed 's/^/- /' || echo "_no tags for group '$$group'_" ; \
	  echo "" ; \
	done
.PHONY: docker-build-tags-list-ci-md

DOCKER_HUB_IMAGES = \
  docker-dind-rootless \
  debian \
  golang-alpine \
  rust 

local-docker-hub-images-update:	
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print local-dockerhub-ci
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push local-dockerhub-ci
.PHONY: local-docker-hub-images-update

$(DOCKER_HUB_IMAGES:%=local-docker-%-image-update):
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:local-docker-%-image-update=local-%-ci)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push $(@:local-docker-%-image-update=local-%-ci)
.PHONY: $(DOCKER_HUB_IMAGES:%=local-docker-%-image-update)

local-docker-images-release:
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print local-release
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push local-release
.PHONY: local-docker-images-release

local-docker-images-release-ci:
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print local-release-ci
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push local-release-ci
.PHONY: local-docker-images-release-ci

LOCAL_DOCKER_BUILDX_NAME ?= vegito-project-builder
LOCAL_DOCKER_BUILDX_ARM_BUILDER_NAME ?= mac-arm

LOCAL_DOCKER_BUILDX_ARM_BUILDER_ENDPOINT=tcp://10.5.5.2:23751

# Ajout d'un context docker distant pour le Mac
local-docker-context-arm:
	@echo "🔨  Creating buildx context $(LOCAL_DOCKER_BUILDX_ARM_BUILDER_NAME)"
	@docker context inspect $(LOCAL_DOCKER_BUILDX_ARM_BUILDER_NAME) >/dev/null 2>&1 || \
	docker context create $(LOCAL_DOCKER_BUILDX_ARM_BUILDER_NAME) --docker "host=$(LOCAL_DOCKER_BUILDX_ARM_BUILDER_ENDPOINT)"
.PHONY: local-docker-context-arm

local-docker-context-arm-rm:
	@echo "🔨  Removing buildx context $(LOCAL_DOCKER_BUILDX_ARM_BUILDER_NAME)"
	@docker context rm $(LOCAL_DOCKER_BUILDX_ARM_BUILDER_NAME) || true
.PHONY: local-docker-context-arm-rm

local-docker-clean-all:
	@$(MAKE) -j \
	  docker-clean \
	  docker-buildx-clean \
	  docker-local-buildx-cache-clean
.PHONY: local-docker-clean-all

LOCAL_DOCKER_BUILDX_ENABLE_RAM_BUILDER ?= false

ifeq ($(LOCAL_DOCKER_BUILDX_ENABLE_RAM_BUILDER),true)
LOCAL_DOCKER_BUILDX_CREATE_DRIVER_OPTS += memory=20g
endif

LOCAL_DOCKER_BUILDX_ENABLE_MAC_BUILDER ?= false

local-docker-buildx-setup:
	@echo "🔨  Creating buildx context $(LOCAL_DOCKER_BUILDX_NAME)"
	@docker buildx inspect $(LOCAL_DOCKER_BUILDX_NAME) >/dev/null 2>&1 || { \
	  docker context use default && \
	  docker buildx create \
	  --name $(LOCAL_DOCKER_BUILDX_NAME) \
	  --driver docker-container \
	  --use \
	  $(LOCAL_DOCKER_BUILDX_CREATE_DRIVER_OPTS:%=--driver-opt "%") \
	  --platform linux/amd64; \
	}
ifeq ($(LOCAL_DOCKER_BUILDX_ENABLE_MAC_BUILDER),true)
	@$(MAKE) local-docker-context-arm
	@docker buildx inspect $(LOCAL_DOCKER_BUILDX_NAME) | grep $(LOCAL_DOCKER_BUILDX_ARM_BUILDER_NAME) >/dev/null 2>&1 || \
	  docker buildx create \
	    --append \
	    --name $(LOCAL_DOCKER_BUILDX_NAME) \
	    $(LOCAL_DOCKER_BUILDX_ARM_BUILDER_NAME) \
	    --platform linux/arm64
endif

	@docker buildx inspect --bootstrap
.PHONY: local-docker-buildx-setup

local-docker-buildx-rm:
	@echo "🔨  Removing buildx context $(LOCAL_DOCKER_BUILDX_NAME)"
	@-docker buildx rm $(LOCAL_DOCKER_BUILDX_NAME)
.PHONY: local-docker-buildx-rm

local-docker-buildx-clean:
	@echo "🧹 Cleaning up Docker Buildx cache..."
	@docker buildx prune --all --force
.PHONY: local-docker-buildx-clean

local-docker-local-buildx-cache-clean: 
	@echo "🧹 Cleaning up Docker Buildx cache..."
	@bash -c '\
	  for i in $$(find . -name "docker-buildx-cache" -type d) ; do \
	    echo $$i ; \
	    echo Removing $$(du -sh $$i) ; \
		rm -rf $$i ; \
	  done \
	'
.PHONY: local-docker-local-buildx-cache-clean
