PROJECT_NAME=utrade
PROJECT_ID = utrade-taxi-run-0
GIT_HEAD = $(shell git rev-parse --short HEAD)
GIT_HEAD_VERSION ?= $(shell git describe --tags --abbrev=7 --match "v*")
VERSION ?= $(GIT_HEAD_VERSION)

GOOGLE_CLOUD_PROJECT = $(PROJECT_ID)
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

android-studio: local-docker-compose-android-studio-up
.PHONY: images images-ci android-studio
