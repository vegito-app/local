GIT_HEAD_VERSION ?= $(shell git describe --tags --abbrev=7 --match "v*" 2>/dev/null)
VERSION ?= $(GIT_HEAD_VERSION)
ifeq ($(VERSION),)
VERSION := latest
endif

export 

-include go.mk
-include nodejs.mk
-include docker/docker.mk
-include infra/infra.mk 
-include local/local.mk
-include application/application.mk

images: docker-images-local-arch
.PHONY: images

images-ci: node-modules-ci docker-images-ci-multi-arch
.PHONY: images-ci

android-studio: local-android-studio-docker-compose-up
.PHONY: images images-ci android-studio

dev-local: \
local-firebase-emulators-docker-compose-up \
local-android-studio-docker-compose-up \
application-backend-docker-compose-up
.PHONY: dev-local
