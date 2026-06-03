VEGITO_PROJECT_NAME := vegito-nestor
GIT_HEAD_VERSION ?= $(shell git describe --tags --abbrev=7 --match "v*" 2>/dev/null)

COMPOSE_PROJECT_NAME ?= $(VEGITO_PROJECT_NAME)-$(VEGITO_PROJECT_USER)
# LOCAL_DOCKER_BUILDX_CI_BUILD_GROUPS := # applications
ifdef VERSION
LOCAL_VERSION := $(VERSION)
endif

LOCAL_VERSION ?= $(GIT_HEAD_VERSION)

ifeq ($(LOCAL_VERSION),)
LOCAL_VERSION := latest
endif

VERSION ?= $(LOCAL_VERSION)

VEGITO_PUBLIC_REPOSITORY ?= docker.io/dbndev
VEGITO_DOCKER_TRIXIE_DEBIAN_VSCODE_GOLANG_AI_DOCKER_DESKTOP_X_IMAGE_LATEST ?= $(VEGITO_PUBLIC_REPOSITORY)/vegito-public:trixie-debian-vscode-golang-ai-docker-desktop-x-latest

LOCAL_DOCKER_COMPOSE ?= docker compose \
    -f $(CURDIR)/docker-compose.yml

LOCAL_DOCKER_COMPOSE_SERVICES ?= nestor

include docker.mk
include nestor/nestor.mk
include go.mk

LOCAL_DEVCONTAINERS_DOCKER_COMPOSE_SERVICES ?= nestor

include .devcontainer/devcontainer.mk

# Local/dev: build all images without pushing them.
# Tags are generated for all configured registries.
images: vegito-nestor-images-multi-registry-release
.PHONY: images

# CI: build and push all images in parallel.
# Fastest path; requires runners with enough CPU, RAM and disk I/O.
images-ci:  \
docker-login \
vegito-docker-%-images-update
.PHONY: images-ci

images-pull: \
vegito-nestor-images-pull-parallel
.PHONY: images-pull

images-push: \
docker-login \
vegito-nestor-images-push
.PHONY: images-push

devcontainer: devcontainer-vscode
.PHONY: devcontainer

devcontainer-codespaces: devcontainer-vscode-codespaces
.PHONY: devcontainer-codespaces

docker-login: vegito-docker-login-dockerhub
.PHONY: docker-login