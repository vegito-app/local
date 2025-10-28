LOCAL_ROBOTFRAMEWORK_TESTS_DIR ?= $(LOCAL_DIR)/example-application/tests

LOCAL_ROBOTFRAMEWORK_IMAGE_VERSION ?= $(VEGITO_LOCAL_PUBLIC_IMAGES_BASE):robotframework-$(VERSION)

local-robotframework-container-up: local-robotframework-container-rm
	@echo "Starting robotframework tests container..."
	@VERSION=latest $(LOCAL_DIR)/robotframework/docker-compose-up.sh &
	@$(LOCAL_DOCKER_COMPOSE) logs robotframework-tests
	@echo
	@echo Started Application tests display: 
	@echo Run "'make $(@:%-up=%-logs)'" to retrieve more logs
.PHONY: robotframework-container-up

ROBOT ?= $(LOCAL_DOCKER_COMPOSE) exec robotframework robot

local-robotframework-container-run:
	@echo "📝 Running robotframework..."
	@$(ROBOT) --outputdir $(LOCAL_ROBOTFRAMEWORK_TESTS_DIR) robot
.PHONY: robotframework-container-run

local-robotframework-check-env:
	@echo Checking application tests environment validity	
	@$(LOCAL_DOCKER_COMPOSE) exec robotframework bash $(LOCAL_ROBOTFRAMEWORK_TESTS_DIR)/check_env.sh
.PHONY: local-robotframework-check-env
