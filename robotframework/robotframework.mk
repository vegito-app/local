LOCAL_ROBOTFRAMEWORK_TESTS_DIR ?= $(LOCAL_DIR)/example-application/tests
LOCAL_ROBOTFRAMEWORK_TESTS_OUTPUT_DIR ?= $(LOCAL_ROBOTFRAMEWORK_TESTS_DIR)/output
LOCAL_ROBOTFRAMEWORK_IMAGE_VERSION ?= $(VEGITO_LOCAL_PUBLIC_IMAGES_BASE):robotframework-$(VERSION)

local-robotframework-container-up: local-robotframework-container-rm
	@echo "Starting robotframework tests container..."
	@VERSION=latest $(LOCAL_DIR)/robotframework/docker-compose-up.sh &
	@$(LOCAL_DOCKER_COMPOSE) logs robotframework-tests
	@echo
	@echo Started Application tests display: 
	@echo Run "'make $(@:%-up=%-logs)'" to retrieve more logs
.PHONY: local-robotframework-container-up

ROBOT ?= $(LOCAL_DOCKER_COMPOSE) exec robotframework robot

# local-robotframework-container-exec:
# 	echo "📝 Running robotframework..."
# 	mkdir -p $(LOCAL_ROBOTFRAMEWORK_TESTS_OUTPUT_DIR)
# 	$(ROBOT) --outputdir $(LOCAL_ROBOTFRAMEWORK_TESTS_OUTPUT_DIR) robot
# .PHONY: local-robotframework-container-exec

local-robotframework-container-exec:
	@echo "📝 Running robotframework..."
	@$(LOCAL_DOCKER_COMPOSE) exec robotframework sh -c "\
	  set -euxo pipefail; \
	  cd $(LOCAL_ROBOTFRAMEWORK_TESTS_DIR); \
	  mkdir -p output; \
	  robot --outputdir output robot"
.PHONY: local-robotframework-container-exec
