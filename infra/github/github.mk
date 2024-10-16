GITHUB_ACTIONS_RUNNER_STACK_ID ?= $(shell echo $$RANDOM)
GITHUB_ACTIONS_RUNNER_STACK ?= github-actions-$(GITHUB_ACTIONS_RUNNER_STACK_ID)

GITHUB_ACTIONS_RUNNER_IMAGE ?= $(PUBLIC_IMAGES_BASE):github-runner-$(VERSION)
GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE=$(CURDIR)/infra/github/.docker-buildx-cache/github
$(GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE):;	@mkdir -p "$@"
ifneq ($(wildcard $(GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)/index.json),)
GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ = type=local,src=$(GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)
endif
GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE= type=local,dest=$(GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)

# Build image for local run. This target will not push an image to the distant registry.
local-github-runner-image: $(GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE) docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print github-runner
	@$(DOCKER_BUILDX_BAKE) --load github-runner
.PHONY: local-github-runner-image

# Build multi architecture image. This target will build and push 
# an image to the distant registry but not load it locally.
local-github-runner-image-push: docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print github-runner-ci
	@$(DOCKER_BUILDX_BAKE) --push github-runner-ci
.PHONY: local-github-runner-image-push

GITHUB_DOCKER_COMPOSE := COMPOSE_PROJECT_NAME=$(GOOGLE_CLOUD_PROJECT_ID)-github-actions \
  docker compose -f $(CURDIR)/infra/github/docker-compose.yml

local-github-runner-token-exist:
	@if [ ! -v GITHUB_ACTIONS_RUNNER_TOKEN ] ; then \
		echo missing GITHUB_ACTIONS_RUNNER_TOKEN environment variable. \
		exit -1 ; \
	fi
.PHONY: local-github-runner-token-exist

local-github-runner-docker-compose-up: local-github-runner-docker-compose-rm local-github-runner-token-exist
	@$(GITHUB_DOCKER_COMPOSE) up -d github-runner
.PHONY: local-github-runner-docker-compose-up

# This avoids github dangling offline containers on github.com side.
# It uses './config.sh remove' from github-runner containers entrypoint
# before exit (see ./entrypoint.sh)
local-github-runner-docker-compose-rm:
	@-$(GITHUB_DOCKER_COMPOSE) rm -s -f github-runner
.PHONY: local-github-runner-docker-compose-rm
