GOOGLE_CLOUD_DOCKER_REGISTRY ?= $(GOOGLE_CLOUD_REGION)-docker.pkg.devs
GOOGLE_CLOUD_PROJECT_DOCKER_REGISTRY ?= $(GOOGLE_CLOUD_DOCKER_REGISTRY)/$(GOOGLE_CLOUD_PROJECT_ID)

export VEGITO_PUBLIC_REPOSITORY ?= $(GOOGLE_CLOUD_PROJECT_DOCKER_REGISTRY)/docker-repository-public

ENABLE_LOCAL_CACHE ?= $(VEGITO_DOCKER_BUILD_ENABLE_LOCAL_CACHE)

vegito-docker-login-gcr: gcloud-auth-docker
	@echo "Logging into $(GOOGLE_CLOUD_PROJECT_DOCKER_REGISTRY)"
	@docker login $(GOOGLE_CLOUD_PROJECT_DOCKER_REGISTRY)
.PHONY: vegito-docker-login-gcr

VEGITO_DOCKER_REGISTRIES ?= gcr dockerhub

vegito-docker-login: $(VEGITO_DOCKER_REGISTRIES:%=vegito-docker-login-%)
	@echo "🔐 Logged into: $(VEGITO_DOCKER_REGISTRIES)"
.PHONY: vegito-docker-login

vegito-docker-sock:
	@echo "🔨  Enabling docker.sock"
	@sudo chmod o+rw /var/run/docker.sock
.PHONY: vegito-docker-sock

vegito-docker-clean: 
	@echo "🧹 Cleaning up Docker..."
	@docker system prune --all --force
.PHONY: vegito-docker-clean

# Groups are used to manage the build process. 
# If an image is built in a group, all images in that group are built together.
VEGITO_DOCKER_BUILDX_BUILD_GROUPS ?= \
  dockerhub \
  runners

# Build all images (dev)
# In this variant, images are built and loaded into the local Docker daemon.
# The build does not push images to a remote registry.
vegito-docker-images: $(VEGITO_DOCKER_BUILDX_BUILD_GROUPS:%=%-docker-images)
.PHONY: vegito-docker-images

$(VEGITO_DOCKER_BUILDX_BUILD_GROUPS:%=%-docker-images): vegito-docker-buildx-setup
	@$(VEGITO_DOCKER_BUILDX_BAKE) --print $(@:%-docker-images=%)
	@$(VEGITO_DOCKER_BUILDX_BAKE) --load $(@:%-docker-images=%)
.PHONY: $(VEGITO_DOCKER_BUILDX_BUILD_GROUPS:%=%-docker-images)

vegito-docker-images-multi-registry-release: $(VEGITO_DOCKER_REGISTRIES:%=vegito-docker-images-%-release)
	@echo "✅ DevBuilt local images tagged for all registries successfully. No push performed."
.PHONY: vegito-docker-images-multi-registry-release

vegito-docker-images-gcr-release: vegito-docker-images-release
.PHONY: vegito-docker-images-gcr-release

# Build all images (CI)
# In this variant, images are built and pushed to the remote registry.
vegito-docker-images-ci: $(VEGITO_DOCKER_BUILDX_BUILD_GROUPS:%=%-docker-images-ci)
.PHONY: vegito-docker-images-ci

$(VEGITO_DOCKER_BUILDX_BUILD_GROUPS:%=%-docker-images-ci): vegito-docker-buildx-setup
	@$(VEGITO_DOCKER_BUILDX_BAKE) --print $(@:%-docker-images-ci=%-ci)
	@$(VEGITO_DOCKER_BUILDX_BAKE) --push $(@:%-docker-images-ci=%-ci)
.PHONY: $(VEGITO_DOCKER_BUILDX_BUILD_GROUPS:%=%-docker-images-ci)

vegito-docker-images-multi-registry-release-ci: $(VEGITO_DOCKER_REGISTRIES:%=vegito-docker-images-%-release-ci)
	@echo "✅ CI Built and pushed images to all registries successfully."
.PHONY: vegito-docker-images-multi-registry-release-ci

vegito-docker-images-gcr-release-ci: vegito-docker-images-release-ci
.PHONY: vegito-docker-gcr-images-ci

vegito-docker-group-tags-list-ci: $(VEGITO_DOCKER_BUILDX_BUILD_GROUPS:%=%-docker-group-tags-list-ci)
.PHONY: vegito-docker-group-tags-list-ci

$(VEGITO_DOCKER_BUILDX_BUILD_GROUPS:%=%-docker-group-tags-list-ci):
	@$(VEGITO_DOCKER_BUILDX_BAKE) --print $(@:%-docker-group-tags-list-ci=%-ci) | jq -r '.target | to_entries[] | .value.tags[]'
.PHONY: $(VEGITO_DOCKER_BUILDX_BUILD_GROUPS:%=%-docker-group-tags-list-ci)

vegito-docker-build-tags-list-ci-md:
	@echo "### 🐳 Docker Images Built (excluding latest):"
	@set -e; for group in $(VEGITO_DOCKER_BUILDX_BUILD_GROUPS); do \
	  echo "#### Group: '$$group'" ; \
	 $(MAKE) $$group-docker-group-tags-list-ci \
	 | grep -vE 'latest$$' \
	 | grep -v 'make\[1\]\:' \
	 | sed 's/^/- /' || echo "_no tags for group '$$group'_" ; \
	  echo "" ; \
	done
.PHONY: vegito-docker-build-tags-list-ci-md

vegito-docker-images-release:
	@$(VEGITO_DOCKER_BUILDX_BAKE) --print release
	@$(VEGITO_DOCKER_BUILDX_BAKE) --load release
.PHONY: vegito-docker-images-release

vegito-docker-images-release-ci:
	@$(VEGITO_DOCKER_BUILDX_BAKE) --print release-ci
	@$(VEGITO_DOCKER_BUILDX_BAKE) --push release-ci
.PHONY: vegito-docker-images-release-ci

VEGITO_DOCKER_BUILDX_NAME ?= vegito-project-builder
VEGITO_DOCKER_BUILDX_ARM_BUILDER_NAME ?= mac-arm

VEGITO_DOCKER_BUILDX_ARM_BUILDER_ENDPOINT ?= tcp://10.5.5.2:23751

# Ajout d'un context docker distant pour le Mac
vegito-docker-context-arm:
	@echo "🔨  Creating buildx context $(VEGITO_DOCKER_BUILDX_ARM_BUILDER_NAME)"
	@docker context inspect $(VEGITO_DOCKER_BUILDX_ARM_BUILDER_NAME) >/dev/null 2>&1 || \
	docker context create $(VEGITO_DOCKER_BUILDX_ARM_BUILDER_NAME) --docker "host=$(VEGITO_DOCKER_BUILDX_ARM_BUILDER_ENDPOINT)"
.PHONY: vegito-docker-context-arm

vegito-docker-context-arm-rm:
	@echo "🔨  Removing buildx context $(VEGITO_DOCKER_BUILDX_ARM_BUILDER_NAME)"
	@docker context rm $(VEGITO_DOCKER_BUILDX_ARM_BUILDER_NAME) || true
.PHONY: vegito-docker-context-arm-rm

vegito-docker-clean-all:
	@$(MAKE) -j \
	  vegito-docker-clean \
	  vegito-docker-buildx-clean \
	  vegito-docker-buildx-cache-clean
.PHONY: vegito-docker-clean-all

VEGITO_DOCKER_BUILDX_ENABLE_RAM_BUILDER ?= false

ifeq ($(VEGITO_DOCKER_BUILDX_ENABLE_RAM_BUILDER),true)
VEGITO_DOCKER_BUILDX_CREATE_DRIVER_OPTS += memory=20g
endif

VEGITO_DOCKER_BUILDX_ENABLE_MAC_BUILDER ?= false

vegito-docker-buildx-setup:
	@echo "🔨  Creating buildx context $(VEGITO_DOCKER_BUILDX_NAME)"
	@docker buildx inspect $(VEGITO_DOCKER_BUILDX_NAME) >/dev/null 2>&1 || { \
	  docker context use default && \
	  docker buildx create \
	    --name $(VEGITO_DOCKER_BUILDX_NAME) \
	    --driver docker-container \
	    --use \
	    $(VEGITO_DOCKER_BUILDX_CREATE_DRIVER_OPTS:%=--driver-opt "%") \
	    --platform linux/arm64 \
	    --platform linux/amd64; \
	}
ifeq ($(VEGITO_DOCKER_BUILDX_ENABLE_MAC_BUILDER),true)
	@$(MAKE) vegito-docker-context-arm
	@docker buildx inspect $(VEGITO_DOCKER_BUILDX_NAME) | grep $(VEGITO_DOCKER_BUILDX_ARM_BUILDER_NAME) >/dev/null 2>&1 || \
	  docker buildx create \
	    --append \
	    --name $(VEGITO_DOCKER_BUILDX_NAME) \
	    $(VEGITO_DOCKER_BUILDX_ARM_BUILDER_NAME) \
	    --platform linux/arm64
endif
	@docker buildx inspect --bootstrap
	@docker run --privileged --rm tonistiigi/binfmt --install all
.PHONY: vegito-docker-buildx-setup

vegito-docker-buildx-rm:
	@echo "🔨  Removing buildx context $(VEGITO_DOCKER_BUILDX_NAME)"
	@-docker buildx rm $(VEGITO_DOCKER_BUILDX_NAME)
.PHONY: vegito-docker-buildx-rm

vegito-docker-buildx-clean:
	@echo "🧹 Cleaning up Docker Buildx cache..."
	@docker buildx prune --all --force
.PHONY: vegito-docker-buildx-clean

vegito-docker-buildx-cache-clean: 
	@echo "🧹 Cleaning up Docker Buildx cache..."
	@bash -c '\
	  for i in $$(find . -name "vegito-docker-buildx-cache" -type d) ; do \
	    echo $$i ; \
	    echo Removing $$(du -sh $$i) ; \
		rm -rf $$i ; \
	  done \
	'
.PHONY: vegito-docker-buildx-cache-clean
