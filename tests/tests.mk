APPLICATION_TESTS := \
	account-validate \
	anonymous-login \
	cold-start \
	vegetable-add \
	vegetable-gallery \
	firestore

application-tests-robot-framework-all-run: local-application-tests-check-env $(APPLICATION_TESTS:%=application-test-%)
.PHONY: application-tests-robot-framework-all-run

application-tests-robot-framework-all-clean:
	@echo Cleaning all application tests output
	@rm -rf $(APPLICATION_DIR)/tests/output/*
.PHONY: application-tests-robot-framework-all-clean

APPLICATION_TESTS_ROBOT ?= $(LOCAL_DOCKER_COMPOSE) exec application-tests \
	robot --outputdir $(APPLICATION_DIR)/tests/output

$(APPLICATION_TESTS:%=application-test-%):
	@echo Running application test '$(@:application-test-%=%)'
	@$(APPLICATION_TESTS_ROBOT)	$(APPLICATION_DIR)/tests/robot/$(@:application-test-%=%).robot
.PHONY: $(APPLICATION_TESTS:%=application-test-%)
