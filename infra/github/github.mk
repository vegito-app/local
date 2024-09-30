GITHUB_ACTION_RUNNER_IMAGE ?= $(PUBLIC_IMAGES_BASE):github-runner-$(GIT_TAG)

GITHUB_ACTIONS_RUNNER_STACK_ID ?= $(shell echo $$RANDOM)
GITHUB_ACTIONS_RUNNER_STACK ?= github-actions-$(GITHUB_ACTIONS_RUNNER_STACK_ID)

# Build image for local run. This target will not push an image to the distant registry.
github-runner-image: docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print local-github-runner
	@$(DOCKER_BUILDX_BAKE) --load local-github-runner
.PHONY: github-runner-image

# Build multi architecture image. This target will build and push 
# an image to the distant registry but not load it locally.
github-runner-image-push: docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print github-runner
	@$(DOCKER_BUILDX_BAKE) --push github-runner
.PHONY: github-runner-image-push

# launch local github-runner stack with docker compose.
# Set GITHUB_ACTION_RUNNER_TOKEN before running this target.
github-runner:
	@docker compose -f $(CURDIR)/infra/gùithub/docker-compose.yml \
	  up -d  \
	github-runner
.PHONY: github-runner

# remove local docker-compose github-runner container stack
github-runner-rm:
	@docker compose -f $(CURDIR)/infra/github/docker-compose.yml \
	  rm -s -f
.PHONY: github-runner-rm

# Docker Swarm stack: will use the latest image from repository by design. 
# Use 'make github-runner' instead to use a locally builded image with Docker Compose instead.
# Set GITHUB_ACTION_RUNNER_TOKEN before running this target.
github-runner-stack:
	@docker stack deploy \
	  --compose-file $(CURDIR)/infra/github/docker-compose.yml \
	  $(GITHUB_ACTIONS_RUNNER_STACK)
.PHONY: github-runner-stack

# Remove local github-runner Docker Swarm stack
# Set GITHUB_ACTIONS_RUNNER_STACK or GITHUB_ACTIONS_RUNNER_STACK_ID according to 
# a current running stack value to target a specific Swarm stack removal.
github-runner-stack-rm:
	@-docker stack rm $(GITHUB_ACTIONS_RUNNER_STACK)
.PHONY: github-runner-stack-rm