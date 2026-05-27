VEGITO_PROJECT_NAME := vegito-docker
GIT_HEAD_VERSION ?= $(shell git describe --tags --abbrev=7 --match "v*" 2>/dev/null)

ifdef VERSION
VEGITO_DOCKER_VERSION := $(VERSION)
endif

VEGITO_DOCKER_VERSION ?= $(GIT_HEAD_VERSION)

ifeq ($(VEGITO_DOCKER_VERSION),)
VEGITO_DOCKER_VERSION := latest
endif

VERSION ?= $(VEGITO_DOCKER_VERSION)

VEGITO_DOCKER_REGISTRIES ?= dockerhub

export

# Use docker.io as the default registry for local public images, but allow overriding it if needed.
# Remove after gcr is back in shape and can be used as the default registry for local public images.
VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME  ?= docker.io/dbndev/vegito-public
VEGITO_DOCKER_BUILD_ENABLE_LOCAL_CACHE ?= false

VEGITO_DOCKER_ALPINE_DIR ?= $(VEGITO_DOCKER_DIR)/alpine
VEGITO_DOCKER_DEBIAN_DIR ?= $(VEGITO_DOCKER_DIR)/debian
VEGITO_DOCKER_IO_DIR     ?= $(VEGITO_DOCKER_DIR)/docker.io

VEGITO_DOCKER_BUILDX_BAKE ?= \
  docker buildx bake \
  -f $(VEGITO_DOCKER_DIR)/docker-bake.hcl \
  -f $(VEGITO_DOCKER_IO_DIR)/docker-bake.hcl \
  $(VEGITO_DOCKER_IO_HUB_IMAGES:%=-f $(VEGITO_DOCKER_IO_DIR)/docker.io/%.docker-bake.hcl) \
  -f $(VEGITO_DOCKER_ALPINE_DIR)/docker-bake.hcl \
  -f $(VEGITO_DOCKER_DEBIAN_DIR)/docker-bake.hcl \
  $(VEGITO_DOCKER_DEBIAN_SPECIFICS:%=-f $(VEGITO_DOCKER_DEBIAN_DIR)/%/docker-bake.hcl) \
  $(VEGITO_DOCKER_DEBIAN_SPECIFICS:%=-f $(VEGITO_DOCKER_DEBIAN_DIR)/%/trixie.docker-bake.hcl)

-include docker.mk

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
vegito-docker-images-pull-parallel
.PHONY: images-pull

images-push: \
vegito-docker-login \
vegito-docker-images-push
.PHONY: images-push

devcontainer: devcontainer-vscode
.PHONY: devcontainer

devcontainer-codespaces: devcontainer-vscode-codespaces
.PHONY: devcontainer-codespaces

vegito-docker-tags-md-ci: vegito-docker-build-tags-list-ci-md
.PHONY: vegito-docker-tags-md-ci

vegito-docker-login: vegito-docker-login
.PHONY: vegito-docker-login
