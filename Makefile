GIT_HEAD_VERSION ?= $(shell git describe --tags --abbrev=7 --match "v*")

VERSION ?= $(GIT_HEAD_VERSION)

PROJECT_NAME ?= utrade

GOOGLE_CLOUD_PROJECT_ID = utrade-taxi-run-0

REGION ?= us-central1

export 

-include go.mk
-include nodejs.mk
-include docker/docker.mk
-include infra/infra.mk 
-include local/local.mk
-include application/application.mk

images: docker-local-arch-images
.PHONY: images

images-ci: docker-multi-arch-images
.PHONY: images-ci

android-studio: local-android-studio-docker-compose-up
.PHONY: images images-ci android-studio
