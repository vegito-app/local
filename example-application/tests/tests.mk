VEGITO_EXAMPLE_APPLICATION_TESTS_DIR ?= $(VEGITO_EXAMPLE_APPLICATION_DIR)/tests
VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_VERSION ?= $(VEGITO_LOCAL_PUBLIC_IMAGES_BASE):example-application-tests-$(VERSION)

VEGITO_EXAMPLE_APPLICATION_TESTS_ROBOT ?= \
	test-increment.robot

$(VEGITO_EXAMPLE_APPLICATION_TESTS_ROBOT:%=example-application-tests-robot-%): 
	@echo "Running robot test $(@:example-application-tests-robot-%=%)..."
	$(LOCAL_ROBOTFRAMEWORK_ROBOT) --outputdir $(VEGITO_EXAMPLE_APPLICATION_TESTS_DIR)/output \
		      $(VEGITO_EXAMPLE_APPLICATION_TESTS_DIR)/$(@:example-application-tests-robot-%=%)
.PHONY: $(VEGITO_EXAMPLE_APPLICATION_TESTS_ROBOT:%=example-application-tests-robot-%)

example-application-tests-robot-all: $(VEGITO_EXAMPLE_APPLICATION_TESTS_ROBOT:%=example-application-tests-robot-%)
	@echo "✅ All robot tests executed successfully."
.PHONY: example-application-tests-robot-all

example-application-tests-container-up: example-application-tests-container-rm
	@echo "Starting tests application container..."
	$(VEGITO_EXAMPLE_APPLICATION_TESTS_DIR)/container-up.sh
.PHONY: example-application-tests-container-up
