GIT_HEAD_VERSION ?= $(shell git describe --tags --abbrev=7 --match "v*" 2>/dev/null)
INFRA_PROJECT_NAME ?= moov
VERSION ?= $(GIT_HEAD_VERSION)
ifeq ($(VERSION),)
VERSION := latest
endif

export

-include local/local.mk

DOCKER_BUILDX_BAKE_APPLICATION_IMAGES_WORKERS_IMAGES = \
  application-images-cleaner  \
  application-images-moderator 

DOCKER_BUILDX_BAKE_APPLICATION_IMAGES = \
  application-backend

DOCKER_BUILDX_BAKE_LOCAL_IMAGES = \
  android-studio \
  clarinet-devnet \
  application-tests \
  firebase-emulators \
  vault-dev 

DOCKER_BUILDX_BAKE_IMAGES = \
  $(DOCKER_BUILDX_BAKE_APPLICATION_IMAGES) \
  $(DOCKER_BUILDX_BAKE_APPLICATION_IMAGES_WORKERS_IMAGES) \
  $(DOCKER_BUILDX_BAKE_LOCAL_IMAGES) 

DOCKER_BUILDX_BAKE = docker buildx bake \
	-f docker-bake.hcl \
	-f local/docker-bake.hcl \
	$(DOCKER_BUILDX_BAKE_LOCAL_IMAGES:%=-f local/%/docker-bake.hcl) \
	$(DOCKER_BUILDX_BAKE_APPLICATION_IMAGES_WORKERS_IMAGES:application-images-%=-f application/images/%/docker-bake.hcl) \
	$(DOCKER_BUILDX_BAKE_APPLICATION_IMAGES:application-%=-f application/%/docker-bake.hcl) \
	-f local/github/docker-bake.hcl

-include docker/docker.mk
-include infra/infra.mk 
-include application/application.mk

images: 
	@$(MAKE) -j docker-images-local-arch
.PHONY: images

images-ci: docker-images-ci-multi-arch
.PHONY: images-ci

images-pull: 
	@$(MAKE) -j docker-local-images-pull
.PHONY: images-fast-pull

images-push: 
	@$(MAKE) -j docker-local-images-push
.PHONY: images-push

dev: 
	@$(MAKE) -j local-docker-compose-up
.PHONY: dev

dev-rm: 
	@$(MAKE) -j local-docker-compose-rm-all
.PHONY: dev-rm

logs: local-docker-compose-dev-logs-f
.PHONY: logs

tests-all: application-tests-all
.PHONY: tests-all
