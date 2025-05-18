GIT_HEAD_VERSION ?= $(shell git describe --tags --abbrev=7 --match "v*" 2>/dev/null)
VERSION ?= $(GIT_HEAD_VERSION)
ifeq ($(VERSION),)
VERSION := latest
endif

GOOGLE_CLOUD_REGION = europe-west1

DEV_GOOGLE_CLOUD_PROJECT_ID=moov-dev-439608
DEV_GOOGLE_CLOUD_PROJECT_NUMBER = 203475703228

STAGING_GOOGLE_CLOUD_PROJECT_ID=moov-staging-440506
STAGING_GOOGLE_CLOUD_PROJECT_NUMBER = 326118600145

PROD_GOOGLE_CLOUD_PROJECT_ID=moov-438615
PROD_GOOGLE_CLOUD_PROJECT_NUMBER = 378762893981

export

-include docker/docker.mk
-include local/local.mk
-include infra/infra.mk 
-include application/application.mk

images: docker-images-local-arch
.PHONY: images

images-ci: docker-images-ci-multi-arch
.PHONY: images-ci

images-pull: 
	@$(MAKE) -j local-docker-images-pull
.PHONY: images-fast-pull

images-push: 
	@$(MAKE) -j local-docker-images-push
.PHONY: images-push

dev: 
	@$(MAKE) -j local-docker-compose-up
.PHONY: dev

dev-rm: 
	@$(MAKE) -j local-docker-compose-rm-all
.PHONY: dev-rm

logs: local-docker-compose-dev-logs-f
.PHONY: logs