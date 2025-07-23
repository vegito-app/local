GIT_HEAD_VERSION ?= $(shell git describe --tags --abbrev=7 --match "v*" 2>/dev/null)

LOCAL_VERSION ?= $(GIT_HEAD_VERSION)
ifeq ($(LOCAL_VERSION),)
LOCAL_VERSION := latest
endif

GOOGLE_CLOUD_PROJECT_ID ?= moov-dev-439608
INFRA_PROJECT_NAME ?= moov

LOCAL_APPLICATION_TESTS_DIR ?= $(LOCAL_DIR)/application-tests

export

-include local.mk

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
	@$(MAKE) -j local-containers-up
.PHONY: dev

dev-rm: 
	@$(MAKE) -j local-containers-rm-all
.PHONY: dev-rm

logs: local-containers-dev-logs-f
.PHONY: logs

application-tests: local-application-tests-container-run
	@echo "Application tests completed successfully."
.PHONY: application-tests
