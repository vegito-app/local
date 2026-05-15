LOCAL_DOCKER_DIR ?= $(CURDIR)
include $(LOCAL_DOCKER_DIR)/dockerhub.mk

GOOGLE_CLOUD_DOCKER_REGISTRY ?= $(GOOGLE_CLOUD_REGION)-docker.pkg.devs
GOOGLE_CLOUD_PROJECT_DOCKER_REGISTRY ?= $(GOOGLE_CLOUD_DOCKER_REGISTRY)/$(GOOGLE_CLOUD_PROJECT_ID)

VEGITO_DOCKER_IMAGES_BASE ?= vegito

VEGITO_PRIVATE_REPOSITORY ?= $(GOOGLE_CLOUD_PROJECT_DOCKER_REGISTRY)/docker-repository-private

VEGITO_CACHE_REPOSITORY ?= $(GOOGLE_CLOUD_PROJECT_DOCKER_REGISTRY)/docker-repository-cache
VEGITO_LOCAL_CACHE_IMAGES_BASE ?= $(VEGITO_CACHE_REPOSITORY)/$(VEGITO_DOCKER_IMAGES_BASE)

VEGITO_PUBLIC_REPOSITORY ?= $(GOOGLE_CLOUD_PROJECT_DOCKER_REGISTRY)/docker-repository-public
VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME ?= $(VEGITO_PUBLIC_REPOSITORY)/$(VEGITO_DOCKER_IMAGES_BASE)

ENABLE_LOCAL_CACHE ?= $(VEGITO_DOCKER_BUILD_ENABLE_LOCAL_CACHE)

docker-login-gcr: gcloud-auth-docker docker-login
	@echo "Logging into $(GOOGLE_CLOUD_PROJECT_DOCKER_REGISTRY)"
	@docker login $(GOOGLE_CLOUD_PROJECT_DOCKER_REGISTRY)
.PHONY: docker-login-gcr

docker-login: $(DOCKER_REGISTRIES:%=docker-login-%)
	@echo "🔐 Logged into: $(DOCKER_REGISTRIES)"
.PHONY: docker-login

docker-sock:
	@echo "🔨  Enabling docker.sock"
	@sudo chmod o+rw /var/run/docker.sock
.PHONY: docker-sock

docker-clean: 
	@echo "🧹 Cleaning up Docker..."
	@docker system prune --all --force
.PHONY: docker-clean

# Groups are used to manage the build process. 
# If an image is built in a group, all images in that group are built together.
LOCAL_DOCKER_BUILDX_BUILD_GROUPS ?= \
  dockerhub \
  runners

# Build all images (dev)
# In this variant, images are built and loaded into the local Docker daemon.
# The build does not push images to a remote registry.
docker-images: $(LOCAL_DOCKER_BUILDX_BUILD_GROUPS:%=%-docker-images)
.PHONY: docker-images

$(LOCAL_DOCKER_BUILDX_BUILD_GROUPS:%=%-docker-images): docker-buildx-setup
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:%-docker-images=%)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --load $(@:%-docker-images=%)
.PHONY: $(LOCAL_DOCKER_BUILDX_BUILD_GROUPS:%=%-docker-images)
DOCKER_REGISTRIES ?= gcr dockerhub

docker-images-multi-registry-release: $(DOCKER_REGISTRIES:%=docker-images-%-release)
	@echo "✅ DevBuilt local images tagged for all registries successfully. No push performed."
.PHONY: docker-images-multi-registry-release

docker-images-gcr-release: docker-images-release
.PHONY: docker-images-gcr-release

# Build all images (CI)
# In this variant, images are built and pushed to the remote registry.
docker-images-ci: $(LOCAL_DOCKER_BUILDX_BUILD_GROUPS:%=%-docker-images-ci)
.PHONY: docker-images-ci

$(LOCAL_DOCKER_BUILDX_BUILD_GROUPS:%=%-docker-images-ci): docker-buildx-setup
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:%-docker-images-ci=%-ci)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push $(@:%-docker-images-ci=%-ci)
.PHONY: $(LOCAL_DOCKER_BUILDX_BUILD_GROUPS:%=%-docker-images-ci)

docker-images-multi-registry-release-ci: $(DOCKER_REGISTRIES:%=docker-images-%-release-ci)
	@echo "✅ CI Built and pushed images to all registries successfully."
.PHONY: docker-images-multi-registry-release-ci

docker-images-gcr-release-ci: docker-images-release-ci
.PHONY: docker-gcr-images-ci

docker-group-tags-list-ci: $(LOCAL_DOCKER_BUILDX_BUILD_GROUPS:%=%-docker-group-tags-list-ci)
.PHONY: docker-group-tags-list-ci

$(LOCAL_DOCKER_BUILDX_BUILD_GROUPS:%=%-docker-group-tags-list-ci):
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:%-docker-group-tags-list-ci=%-ci) | jq -r '.target | to_entries[] | .value.tags[]'
.PHONY: $(LOCAL_DOCKER_BUILDX_BUILD_GROUPS:%=%-docker-group-tags-list-ci)

docker-build-tags-list-ci-md:
	@echo "### 🐳 Docker Images Built (excluding latest):"
	@set -e; for group in $(LOCAL_DOCKER_BUILDX_BUILD_GROUPS); do \
	  echo "#### Group: '$$group'" ; \
	 $(MAKE) $$group-docker-group-tags-list-ci \
	 | grep -vE 'latest$$' \
	 | grep -v 'make\[1\]\:' \
	 | sed 's/^/- /' || echo "_no tags for group '$$group'_" ; \
	  echo "" ; \
	done
.PHONY: docker-build-tags-list-ci-md

VEGITO_DOCKER_IMAGES = \
  debian \
  desktop-x \
  flutter \
  flutter-desktop-x \
  docker-dind-rootless \
  golang-alpine \
  rust 

docker-hub-images-update:	
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print dockerhub-ci
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push dockerhub-ci
.PHONY: docker-hub-images-update

$(VEGITO_DOCKER_IMAGES:%=docker-%-image-update):
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:docker-%-image-update=%-ci)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push $(@:docker-%-image-update=%-ci)
.PHONY: $(VEGITO_DOCKER_IMAGES:%=docker-%-image-update)

docker-images-release:
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print release
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push release
.PHONY: docker-images-release

docker-images-release-ci:
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print release-ci
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push release-ci
.PHONY: docker-images-release-ci

LOCAL_DOCKER_BUILDX_NAME ?= vegito-project-builder
LOCAL_DOCKER_BUILDX_ARM_BUILDER_NAME ?= mac-arm

LOCAL_DOCKER_BUILDX_ARM_BUILDER_ENDPOINT=tcp://10.5.5.2:23751

# Ajout d'un context docker distant pour le Mac
docker-context-arm:
	@echo "🔨  Creating buildx context $(LOCAL_DOCKER_BUILDX_ARM_BUILDER_NAME)"
	@docker context inspect $(LOCAL_DOCKER_BUILDX_ARM_BUILDER_NAME) >/dev/null 2>&1 || \
	docker context create $(LOCAL_DOCKER_BUILDX_ARM_BUILDER_NAME) --docker "host=$(LOCAL_DOCKER_BUILDX_ARM_BUILDER_ENDPOINT)"
.PHONY: docker-context-arm

docker-context-arm-rm:
	@echo "🔨  Removing buildx context $(LOCAL_DOCKER_BUILDX_ARM_BUILDER_NAME)"
	@docker context rm $(LOCAL_DOCKER_BUILDX_ARM_BUILDER_NAME) || true
.PHONY: docker-context-arm-rm

docker-clean-all:
	@$(MAKE) -j \
	  docker-clean \
	  docker-buildx-clean \
	  docker-buildx-cache-clean
.PHONY: docker-clean-all

LOCAL_DOCKER_BUILDX_ENABLE_RAM_BUILDER ?= false

ifeq ($(LOCAL_DOCKER_BUILDX_ENABLE_RAM_BUILDER),true)
LOCAL_DOCKER_BUILDX_CREATE_DRIVER_OPTS += memory=20g
endif

LOCAL_DOCKER_BUILDX_ENABLE_MAC_BUILDER ?= false

docker-buildx-setup:
	@echo "🔨  Creating buildx context $(LOCAL_DOCKER_BUILDX_NAME)"
	@docker buildx inspect $(LOCAL_DOCKER_BUILDX_NAME) >/dev/null 2>&1 || { \
	  docker context use default && \
	  docker buildx create \
	  --name $(LOCAL_DOCKER_BUILDX_NAME) \
	  --driver docker-container \
	  --use \
	  $(LOCAL_DOCKER_BUILDX_CREATE_DRIVER_OPTS:%=--driver-opt "%") \
	  --platform linux/arm64 \
	  --platform linux/amd64; \
	}
ifeq ($(LOCAL_DOCKER_BUILDX_ENABLE_MAC_BUILDER),true)
	@$(MAKE) docker-context-arm
	@docker buildx inspect $(LOCAL_DOCKER_BUILDX_NAME) | grep $(LOCAL_DOCKER_BUILDX_ARM_BUILDER_NAME) >/dev/null 2>&1 || \
	  docker buildx create \
	    --append \
	    --name $(LOCAL_DOCKER_BUILDX_NAME) \
	    $(LOCAL_DOCKER_BUILDX_ARM_BUILDER_NAME) \
	    --platform linux/arm64
endif

	@docker buildx inspect --bootstrap
.PHONY: docker-buildx-setup

docker-buildx-rm:
	@echo "🔨  Removing buildx context $(LOCAL_DOCKER_BUILDX_NAME)"
	@-docker buildx rm $(LOCAL_DOCKER_BUILDX_NAME)
.PHONY: docker-buildx-rm

docker-buildx-clean:
	@echo "🧹 Cleaning up Docker Buildx cache..."
	@docker buildx prune --all --force
.PHONY: docker-buildx-clean

docker-buildx-cache-clean: 
	@echo "🧹 Cleaning up Docker Buildx cache..."
	@bash -c '\
	  for i in $$(find . -name "docker-buildx-cache" -type d) ; do \
	    echo $$i ; \
	    echo Removing $$(du -sh $$i) ; \
		rm -rf $$i ; \
	  done \
	'
.PHONY: docker-buildx-cache-clean
