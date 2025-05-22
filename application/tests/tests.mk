LOCAL_DOCKER_COMPOSE_SERVICES += local-application-tests

APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE=$(CURDIR)/local/.containers/docker-buildx-cache/application-tests
$(APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE):;	@mkdir -p "$@"
ifneq ($(wildcard $(APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)/index.json),)
APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ = type=local,src=$(APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)
endif
APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE= type=local,dest=$(APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)
APPLICATION_TESTS_IMAGE = ${PUBLIC_IMAGES_BASE}:application-tests-latest

local-application-tests-docker-compose-up: local-application-tests-docker-compose-rm
	@$(LOCAL_DOCKER_COMPOSE) up -d application-tests
	@$(LOCAL_DOCKER_COMPOSE) logs application-tests
.PHONY: local-application-tests-docker-compose-up

local-application-tests-docker-compose-run: 
	@${LOCAL_DOCKER_COMPOSE} exec application-tests rf
.PHONY: application-tests-docker-compose-run

APPLICATION_TESTS_EXEC = docker compose exec application-tests \
	robot --outputdir $(CURDIR)/application/tests/output

application-tests-check-env:
	@echo Checking application tests envirronment validity '$(@:application-test-%=%)'
	@$(APPLICATION_TESTS_EXEC) $(CURDIR)/check_env.sh
.PHONY: application-tests-check-env

APPLICATION_TESTS := \
	anonymous-login \
	vegetable-add

application-tests-all: $(APPLICATION_TESTS:%=application-test-%)

$(APPLICATION_TESTS:%=application-test-%):
	@echo Running application test '$(@:application-test-%=%)'
	@$(APPLICATION_TESTS_EXEC) $(CURDIR)/application/tests/robot/$(@:application-test-%=%).robot
.PHONY: $(APPLICATION_TESTS:%=application-test-%)