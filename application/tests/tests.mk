APPLICATION_TESTS := \
	anonymous-login \
	vegetable-add

application-tests-robot-framework-all-run: local-application-tests-check-env $(APPLICATION_TESTS:%=application-test-%)
.PHONY: application-tests-robot-framework-all-run

application-tests-robot-framework-all-clean:
	@echo Cleaning all application tests output
	@rm -rf $(CURDIR)/application/tests/output/*
.PHONY: application-tests-robot-framework-all-clean

APPLICATION_TESTS_ROBOT ?= $(LOCAL_DOCKER_COMPOSE) exec application-tests \
	robot --outputdir $(CURDIR)/application/tests/output

$(APPLICATION_TESTS:%=application-test-%):
	@echo Running application test '$(@:application-test-%=%)'
	@$(APPLICATION_TESTS_ROBOT)	$(CURDIR)/application/tests/robot/$(@:application-test-%=%).robot
.PHONY: $(APPLICATION_TESTS:%=application-test-%)
