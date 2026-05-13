VEGITO_PROJECT_NAME := vegito-docker
GIT_HEAD_VERSION ?= $(shell git describe --tags --abbrev=7 --match "v*" 2>/dev/null)

ifdef VERSION
LOCAL_VERSION := $(VERSION)
endif

LOCAL_VERSION ?= $(GIT_HEAD_VERSION)

ifeq ($(LOCAL_VERSION),)
LOCAL_VERSION := latest
endif

VERSION ?= $(LOCAL_VERSION)

VEGITO_DOCKER_REGISTRIES ?= dockerhub

export

# Use docker.io as the default registry for local public images, but allow overriding it if needed.
# Remove after gcr is back in shape and can be used as the default registry for local public images.
VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME ?= docker.io/dbndev/vegito-local-public
VEGITO_DOCKER_BUILD_ENABLE_LOCAL_CACHE ?= false

LOCAL_DOCKER_BUILDX_BAKE ?= \
  docker buildx bake \
  -f $(LOCAL_DOCKER_DIR)/docker-bake.hcl \
  -f $(LOCAL_DOCKER_DIR)/desktop-x/docker-bake.hcl

-include docker.mk

# Local/dev: build all images without pushing them.
# Tags are generated for all configured registries.
images: local-docker-images-multi-registry-release
.PHONY: images

# Local/dev: build images in smaller groups without pushing them.
# Useful when full parallel builds are too heavy for the workstation.
images-groups-build: local-docker-images
.PHONY: images-groups-build

# CI: build and push all images in parallel.
# Fastest path; requires runners with enough CPU, RAM and disk I/O.
images-ci:  \
local-docker-login \
local-docker-images-multi-registry-release-ci
.PHONY: images-ci

# CI: build and push images in smaller groups.
# Safer on constrained runners; slower than the full parallel path.
images-groups-build-ci:  \
local-docker-login \
local-docker-images-ci
.PHONY: images-groups-build-ci

images-pull: \
local-docker-images-pull-parallel
.PHONY: images-pull

images-push: \
local-docker-login \
local-docker-images-push
.PHONY: images-push

devcontainer: devcontainer-vscode
.PHONY: devcontainer

devcontainer-codespaces: devcontainer-vscode-codespaces
.PHONY: devcontainer-codespaces

docker-tags-md-ci: docker-build-tags-list-ci-md
.PHONY: docker-tags-md-ci

docker-login: local-docker-login
.PHONY: docker-login