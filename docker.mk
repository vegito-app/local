# Google Cloud Registry (GCR) configuration
GOOGLE_CLOUD_DOCKER_REGISTRY ?= $(GOOGLE_CLOUD_REGION)-docker.pkg.devs
GOOGLE_CLOUD_PROJECT_DOCKER_REGISTRY ?= $(GOOGLE_CLOUD_DOCKER_REGISTRY)/$(GOOGLE_CLOUD_PROJECT_ID)

vegito-docker-login-gcr: gcloud-auth-docker
	@echo "Logging into $(GOOGLE_CLOUD_PROJECT_DOCKER_REGISTRY)"
	@docker login $(GOOGLE_CLOUD_PROJECT_DOCKER_REGISTRY)
.PHONY: vegito-docker-login-gcr

-include $(LOCAL_DIR)/docker-io.mk

# Available values: gcr, dockerhub, gcr dockerhub, etc. (space-separated)
VEGITO_DOCKER_REGISTRIES ?= dockerhub
VEGITO_DOCKER_PUBLIC_IMAGES_VERSION ?= v0.0.10

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

vegito-docker-images-multi-registry-release: $(VEGITO_DOCKER_REGISTRIES:%=vegito-docker-images-%-release)
	@echo "✅ DevBuilt local images tagged for all registries successfully. No push performed."
.PHONY: vegito-docker-images-multi-registry-release

vegito-docker-images-gcr-release: vegito-docker-images-release
.PHONY: vegito-docker-images-gcr-release

# Build all images (CI)
# In this variant, images are built and pushed to the remote registry.
vegito-docker-images-ci: $(VEGITO_DOCKER_BUILDX_BUILD_GROUPS:%=%-docker-images-ci)
.PHONY: vegito-docker-images-ci

vegito-docker-images-multi-registry-release-ci: $(VEGITO_DOCKER_REGISTRIES:%=vegito-docker-images-%-release-ci)
	@echo "✅ CI Built and pushed images to all registries successfully."
.PHONY: vegito-docker-images-multi-registry-release-ci

vegito-docker-images-gcr-release-ci: vegito-docker-images-release-ci
.PHONY: vegito-docker-gcr-images-ci

vegito-docker-images-release:
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print release
	@$(LOCAL_DOCKER_BUILDX_BAKE) --load release
.PHONY: vegito-docker-images-release

vegito-docker-images-release-ci:
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print release-ci
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push release-ci
.PHONY: vegito-docker-images-release-ci

VEGITO_DOCKER_BUILDX_BUILD_GROUPS ?= \
	release \
	local-project-builder \
	local-android \
	local-android-runners \
	local-android-builders \
	local-android-emulator \
	local-android-appium \
	local-android-studio \
	local-clarinet-devnet \
	local-firebase-emulators \
	local-github-actions-runner \
	local-robotframework \
	local-stripe \
	local-trivy \
	local-vault-dev \
	vegito-example-application \
	vegito-example-application-builders \
	vegito-example-application-services \
	vegito-example-application-applications \
	vegito-example-application-release \
	vegito-example-application-builder \
	vegito-example-application-backend \
	vegito-example-application-mobile \
	vegito-example-application-tests 

vegito-docker-group-tags-list-ci: $(VEGITO_DOCKER_BUILDX_BUILD_GROUPS:%=%-docker-group-tags-list-ci)
.PHONY: vegito-docker-group-tags-list-ci

$(VEGITO_DOCKER_BUILDX_BUILD_GROUPS:%=%-docker-group-tags-list-ci):
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:%-docker-group-tags-list-ci=%-ci) | jq -r '.target | to_entries[] | .value.tags[]'
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

DOCKER ?= docker

export VEGITO_DOCKER_BUILDX_NAME ?= vegito-project-builder
export VEGITO_DOCKER_BUILDX_ARM_BUILDER_NAME ?= mac-arm

export VEGITO_DOCKER_BUILDX_ARM_BUILDER_ENDPOINT ?= tcp://10.6.6.3:23751

# Ajout d'un context docker distant pour le Mac
vegito-docker-context-arm:
	@echo "🔨  Creating buildx context $(VEGITO_DOCKER_BUILDX_ARM_BUILDER_NAME)"
	@$(DOCKER) context inspect $(VEGITO_DOCKER_BUILDX_ARM_BUILDER_NAME) >/dev/null 2>&1 || \
	  $(DOCKER) context create $(VEGITO_DOCKER_BUILDX_ARM_BUILDER_NAME) --docker "host=$(VEGITO_DOCKER_BUILDX_ARM_BUILDER_ENDPOINT)"
.PHONY: vegito-docker-context-arm

vegito-docker-context-arm-rm:
	@echo "🔨  Removing buildx context $(VEGITO_DOCKER_BUILDX_ARM_BUILDER_NAME)"
	@$(DOCKER) context rm $(VEGITO_DOCKER_BUILDX_ARM_BUILDER_NAME) || true
.PHONY: vegito-docker-context-arm-rm

vegito-docker-clean-all:
	@$(MAKE) -j \
	  vegito-docker-clean \
	  vegito-docker-buildx-clean \
	  vegito-docker-buildx-cache-clean
.PHONY: vegito-docker-clean-all

VEGITO_DOCKER_BUILDX_ENABLE_ARM_BUILDER ?= false

ifeq ($(VEGITO_DOCKER_BUILDX_ENABLE_ARM_BUILDER),true)
VEGITO_DOCKER_BUILDX_CREATE_DRIVER_OPTS += memory=20g
endif

vegito-docker-buildx-setup:
	@echo "🔨  Creating buildx context $(VEGITO_DOCKER_BUILDX_NAME)"
ifeq ($(VEGITO_DOCKER_BUILDX_ENABLE_ARM_BUILDER),true)
	@echo "🔨  Enabling ARM builder"
	  $(DOCKER) buildx inspect $(VEGITO_DOCKER_BUILDX_NAME) >/dev/null 2>&1 || { \
	  $(DOCKER) context use default && \
	  $(DOCKER) buildx create \
	    --name $(VEGITO_DOCKER_BUILDX_NAME) \
	    --driver docker-container \
	    --use \
	    $(VEGITO_DOCKER_BUILDX_CREATE_DRIVER_OPTS:%=--driver-opt "%") \
	    --platform linux/amd64; \
	}
	$(MAKE) vegito-docker-context-arm
	$(DOCKER) buildx inspect $(VEGITO_DOCKER_BUILDX_NAME) | grep $(VEGITO_DOCKER_BUILDX_ARM_BUILDER_NAME) >/dev/null 2>&1 || \
	  $(DOCKER) buildx create \
	    --append \
	    --name $(VEGITO_DOCKER_BUILDX_NAME) \
	    $(VEGITO_DOCKER_BUILDX_ARM_BUILDER_NAME) \
	    --platform linux/arm64
else
	@$(DOCKER) buildx inspect $(VEGITO_DOCKER_BUILDX_NAME) >/dev/null 2>&1 || { \
	  $(DOCKER) context use default && \
	  $(DOCKER) buildx create \
	    --name $(VEGITO_DOCKER_BUILDX_NAME) \
	    --driver docker-container \
	    --use \
	    $(VEGITO_DOCKER_BUILDX_CREATE_DRIVER_OPTS:%=--driver-opt "%") \
	    --platform linux/arm64 \
	    --platform linux/amd64; \
	}
endif
	@docker buildx inspect $(VEGITO_DOCKER_BUILDX_NAME) --bootstrap
	@$(MAKE) vegito-docker-buildx-configure-dns
	@docker run --privileged --rm tonistiigi/binfmt --install all
.PHONY: vegito-docker-buildx-setup
vegito-docker-buildx-rm:
	@echo "🔨  Removing buildx context $(VEGITO_DOCKER_BUILDX_NAME)"
	@-$(DOCKER) buildx rm $(VEGITO_DOCKER_BUILDX_NAME)
.PHONY: vegito-docker-buildx-rm

vegito-docker-buildx-clean:
	@echo "🧹 Cleaning up Docker Buildx cache..."
	@$(DOCKER) buildx prune --all --force
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

# Force the local Docker gateway DNS for the native BuildKit daemon.
# This avoids inheriting the LAN DHCP DNS, which cannot resolve Vegito registries.
VEGITO_DOCKER_BUILDX_NATIVE_DNS ?= 172.16.0.1

vegito-docker-buildx-configure-dns:
	@echo "🔧 Configuring native BuildKit DNS: $(VEGITO_DOCKER_BUILDX_NATIVE_DNS)"
	@docker --context default exec \
		buildx_buildkit_$(VEGITO_DOCKER_BUILDX_NAME)0 \
		sh -c 'printf "nameserver %s\n" "$(VEGITO_DOCKER_BUILDX_NATIVE_DNS)" > /etc/resolv.conf'
.PHONY: vegito-docker-buildx-configure-dns
