GIT_HEAD_VERSION ?= $(shell git describe --tags --abbrev=7 --match "v*" 2>/dev/null)

LOCAL_VERSION ?= $(GIT_HEAD_VERSION)
ifeq ($(LOCAL_VERSION),)
LOCAL_VERSION := latest
endif

GOOGLE_CLOUD_PROJECT_ID ?= moov-dev-439608
INFRA_PROJECT_NAME ?= moov

LOCAL_APPLICATION_TESTS_DIR ?= $(LOCAL_DIR)/application-tests
LOCAL_APPLICATION_FIREBASE_FUNCTIONS_DIR ?= $(LOCAL_DIR)/firebase-emulators/functions

export

-include local.mk

images:
	@$(MAKE) -j local-docker-images-host-arch
.PHONY: images

images-ci: local-docker-images-ci-multi-arch
.PHONY: images-ci

images-pull: 
	@$(MAKE) -j local-docker-images-pull
.PHONY: images-fast-pull

images-push: 
	@$(MAKE) -j local-docker-images-push
.PHONY: images-push

dev: 
	@$(MAKE) -j local-containers-up
.PHONY: dev

dev-rm: 
	@$(MAKE) -j local-containers-rm-all
.PHONY: dev-rm

logs: local-containers-dev-logs-f
.PHONY: logs

end-to-end-tests: local-application-tests-container-run
	@echo "End-to-end tests completed successfully."
.PHONY: end-to-end-tests
