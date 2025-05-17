GIT_HEAD_VERSION ?= $(shell git describe --tags --abbrev=7 --match "v*" 2>/dev/null)
VERSION ?= $(GIT_HEAD_VERSION)
ifeq ($(VERSION),)
VERSION := latest
endif

GOOGLE_CLOUD_REGION = europe-west1

ifeq ($(INFRA_ENV),)
INFRA_ENV = dev
endif

ifeq ($(INFRA_ENV),prod)

GOOGLE_CLOUD_PROJECT_ID = moov-438615
GOOGLE_CLOUD_PROJECT_NUMBER = 378762893981
else ifeq ($(INFRA_ENV),staging)
GOOGLE_CLOUD_PROJECT_ID = moov-staging-440506
GOOGLE_CLOUD_PROJECT_NUMBER = 326118600145
else ifeq ($(INFRA_ENV),dev)
GOOGLE_CLOUD_PROJECT_ID = moov-dev-439608
GOOGLE_CLOUD_PROJECT_NUMBER = 203475703228
else
  $(error Invalid INFRA_ENV: $(INFRA_ENV))
endif

export

-include local/local.mk
-include infra/infra.mk 
-include application/application.mk

images: docker-images-local-arch
.PHONY: images

images-ci: docker-images-ci-multi-arch
.PHONY: images-ci

dev: dev-docker-compose
.PHONY: dev

dev-rm: dev-docker-compose-rm
.PHONY: dev-rm
