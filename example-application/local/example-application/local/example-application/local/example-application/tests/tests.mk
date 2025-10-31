EXAMPLE_APPLICATION_TESTS_DIR ?= $(EXAMPLE_APPLICATION_DIR)/tests
EXAMPLE_APPLICATION_TESTS_IMAGE_VERSION ?= $(VEGITO_LOCAL_PUBLIC_IMAGES_BASE):example-application-tests-$(VERSION)

EXAMPLE_APPLICATION_TESTS_ROBOT ?= \
	test-increment.robot

$(EXAMPLE_APPLICATION_TESTS_ROBOT:%=example-application-tests-robot-%): 
	@echo "Running robot test $(@:example-application-tests-robot-%=%)..."
	$(ROBOT) --outputdir $(EXAMPLE_APPLICATION_TESTS_DIR)/output \
		      $(EXAMPLE_APPLICATION_TESTS_DIR)/$(@:example-application-tests-robot-%=%)
.PHONY: $(EXAMPLE_APPLICATION_TESTS_ROBOT:%=example-application-tests-robot-%)

example-application-tests-robot-all: $(EXAMPLE_APPLICATION_TESTS_ROBOT:%=example-application-tests-robot-%)
	@echo "✅ All robot tests executed successfully."
.PHONY: example-application-tests-robot-all

example-application-tests-container-up: example-application-tests-container-rm
	@echo "Starting tests application container..."
	$(EXAMPLE_APPLICATION_TESTS_DIR)/container-up.sh
.PHONY: example-application-tests-container-up
