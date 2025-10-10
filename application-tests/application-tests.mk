LOCAL_APPLICATION_TESTS_DIR ?= $(LOCAL_DIR)/application/tests

LOCAL_APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE ?= $(LOCAL_DIR)/.containers/docker-buildx-cache/application-tests
$(LOCAL_APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE):;	@mkdir -p "$@"
ifneq ($(wildcard $(LOCAL_APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)/index.json),)
LOCAL_APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ = type=local,src=$(LOCAL_APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)
endif
LOCAL_APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE= type=local,mode=max,dest=$(LOCAL_APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)
LOCAL_APPLICATION_TESTS_LATEST_IMAGE ?= $(PUBLIC_IMAGES_BASE):application-tests-latest

local-application-tests-container-up: local-application-tests-container-rm
	@LOCAL_VERSION=latest $(LOCAL_DIR)/application-tests/docker-compose-up.sh &
	@$(LOCAL_DOCKER_COMPOSE) logs application-tests
	@echo
	@echo Started Application tests display: 
	@echo Run "'make $(@:%-up=%-logs)'" to retrieve more logs

local-application-tests-container-run: 
	@$(LOCAL_DOCKER_COMPOSE) exec application-tests rf
.PHONY: application-tests-container-run

local-application-tests-check-env:
	@echo Checking application tests environment validity	
	$(LOCAL_DOCKER_COMPOSE) exec application-tests bash $(LOCAL_APPLICATION_TESTS_DIR)/check_env.sh
.PHONY: local-application-tests-check-env
