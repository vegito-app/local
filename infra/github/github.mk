GITHUB_REPOSITORY_NAME ?= refactored-winner
GITHUB_ACTIONS_RUNNER_IMAGE ?= $(PUBLIC_IMAGES_BASE):github-runner-latest
GITHUB_ACTIONS_RUNNER_STACK_ID ?= $(shell echo $$RANDOM)
GITHUB_ACTIONS_RUNNER_STACK ?= github-actions-$(GITHUB_ACTIONS_RUNNER_STACK_ID)

# Build image for local run. This target will not push an image to the distant registry.
local-github-runner-image: docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print github-runner-local
	@$(DOCKER_BUILDX_BAKE) --load github-runner-local
.PHONY: local-github-runner-image

# Build multi architecture image. This target will build and push 
# an image to the distant registry but not load it locally.
local-github-runner-image-push: docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print github-runner
	@$(DOCKER_BUILDX_BAKE) --push github-runner
.PHONY: local-github-runner-image-push

GITHUB_DOCKER_COMPOSE := COMPOSE_PROJECT_NAME=$(PROJECT_NAME)-github-actions \
  docker compose -f $(CURDIR)/infra/github/docker-compose.yml

local-github-runner-token-exist:
	@if [ ! -v GITHUB_ACTIONS_RUNNER_TOKEN ] ; then \
		echo missing GITHUB_ACTIONS_RUNNER_TOKEN environment variable. \
		Set values from https://github.com/7d4b9/${GITHUB_REPOSITORY_NAME}/settings/actions/runners/new page. ; \
		exit -1 ; \
	fi
.PHONY: local-github-runner-token-exist

local-github-runner-docker-compose-up: github-runner-docker-compose-rm github-runner-token-exist
	@$(GITHUB_DOCKER_COMPOSE) up -d github-runner
.PHONY: local-github-runner-docker-compose-up

# This avoids github dangling offline containers on github.com side.
# It uses './config.sh remove' from github-runner containers entrypoint
# before exit (see ./entrypoint.sh)
local-github-runner-docker-compose-rm:
	@-$(GITHUB_DOCKER_COMPOSE) rm -s -f github-runner
.PHONY: local-github-runner-docker-compose-rm