GIT_HEAD_VERSION ?= $(shell git describe --tags --abbrev=7 --match "v*" 2>/dev/null)
VERSION ?= $(GIT_HEAD_VERSION)
ifeq ($(VERSION),)
VERSION := latest
endif

GOOGLE_CLOUD_REGION = europe-west1

DEV_GOOGLE_CLOUD_PROJECT_ID=moov-dev-439608
DEV_GOOGLE_CLOUD_PROJECT_NUMBER = 203475703228
DEV_GOOGLE_IDP_OAUTH_KEY_SECRET_ID=projects/${DEV_GOOGLE_CLOUD_PROJECT_ID}/secrets/google-idp-oauth-key
DEV_GOOGLE_IDP_OAUTH_CLIENT_ID_SECRET_ID=projects/${DEV_GOOGLE_CLOUD_PROJECT_ID}/secrets/google-idp-oauth-client-id
DEV_STRIPE_KEY_SECRET_SECRET_ID=projects/${DEV_GOOGLE_CLOUD_PROJECT_ID}/secrets/stripe-key

STAGING_GOOGLE_CLOUD_PROJECT_ID=moov-staging-440506
STAGING_GOOGLE_CLOUD_PROJECT_NUMBER = 326118600145
STAGING_GOOGLE_IDP_OAUTH_KEY_SECRET_ID=projects/${STAGING_GOOGLE_CLOUD_PROJECT_ID}/secrets/google-idp-oauth-key
STAGING_GOOGLE_IDP_OAUTH_CLIENT_ID_SECRET_ID=projects/${STAGING_GOOGLE_CLOUD_PROJECT_ID}/secrets/google-idp-oauth-client-id
STAGING_STRIPE_KEY_SECRET_SECRET_ID=projects/${STAGING_GOOGLE_CLOUD_PROJECT_ID}/secrets/stripe-key

PROD_GOOGLE_CLOUD_PROJECT_ID=moov-438615
PROD_GOOGLE_CLOUD_PROJECT_NUMBER = 378762893981
PROD_GOOGLE_IDP_OAUTH_KEY_SECRET_ID=projects/${PROD_GOOGLE_CLOUD_PROJECT_ID}/secrets/google-idp-oauth-key
PROD_GOOGLE_IDP_OAUTH_CLIENT_ID_SECRET_ID=projects/${PROD_GOOGLE_CLOUD_PROJECT_ID}/secrets/google-idp-oauth-client-id
PROD_STRIPE_KEY_SECRET_SECRET_ID=projects/${PROD_GOOGLE_CLOUD_PROJECT_ID}/secrets/stripe-key

export

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