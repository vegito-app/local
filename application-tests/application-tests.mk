LOCAL_APPLICATION_TESTS_DIR ?= $(LOCAL_DIR)/application/tests

LOCAL_APPLICATION_TESTS_IMAGE_VERSION ?= $(VEGITO_LOCAL_PUBLIC_IMAGES_BASE):application-tests-$(VERSION)

local-application-tests-container-up: local-application-tests-container-rm
	@VERSION=latest $(LOCAL_DIR)/application-tests/docker-compose-up.sh &
	@$(LOCAL_DOCKER_COMPOSE) logs application-tests
	@echo
	@echo Started Application tests display: 
	@echo Run "'make $(@:%-up=%-logs)'" to retrieve more logs
.PHONY: application-tests-container-up

local-application-tests-container-run: 
	@$(LOCAL_DOCKER_COMPOSE) exec application-tests rf
.PHONY: application-tests-container-run

local-application-tests-check-env:
	@echo Checking application tests environment validity	
	$(LOCAL_DOCKER_COMPOSE) exec application-tests bash $(LOCAL_APPLICATION_TESTS_DIR)/check_env.sh
.PHONY: local-application-tests-check-env
