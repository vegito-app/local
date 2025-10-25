LOCAL_ROBOTFRAMEWORK_TESTS_DIR ?= $(LOCAL_DIR)/example-application/tests

LOCAL_ROBOTFRAMEWORK_TESTS_IMAGE_VERSION ?= $(VEGITO_LOCAL_PUBLIC_IMAGES_BASE):robotframework-$(VERSION)

local-robotframework-tests-container-up: local-robotframework-tests-container-rm
	@echo "Starting robotframework tests container..."
	@VERSION=latest $(LOCAL_DIR)/robotframework/docker-compose-up.sh &
	@$(LOCAL_DOCKER_COMPOSE) logs robotframework-tests
	@echo
	@echo Started Application tests display: 
	@echo Run "'make $(@:%-up=%-logs)'" to retrieve more logs
.PHONY: robotframework-container-up

ROBOT ?= $(LOCAL_DOCKER_COMPOSE) exec robotframework-tests robot

local-robotframework-tests-container-run:
	@echo "Running robot tests..."
	@$(ROBOT) --outputdir ${LOCAL_ROBOTFRAMEWORK_TESTS_DIR} robot
.PHONY: robotframework-container-run

local-robotframework-tests-check-env:
	@echo Checking application tests environment validity	
	@$(LOCAL_DOCKER_COMPOSE) exec robotframework-tests bash $(LOCAL_ROBOTFRAMEWORK_TESTS_DIR)/check_env.sh
.PHONY: local-robotframework-tests-check-env
