GIT_HEAD_VERSION ?= $(shell git describe --tags --abbrev=7 --match "v*" 2>/dev/null)
INFRA_PROJECT_NAME ?= moov
VERSION ?= $(GIT_HEAD_VERSION)
ifeq ($(VERSION),)
VERSION := latest
endif

export

-include git.mk
-include local/local.mk
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
