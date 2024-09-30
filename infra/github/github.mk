GITHUB_ACTION_RUNNER_IMAGE ?= $(PUBLIC_IMAGES_BASE):github-runner-latest

GITHUB_ACTION_RUNNER_TOKEN=AEOTDPFCTLVX5VG5KUTQRC3G7H5AW

GITHUB_ACTIONS_RUNNER_STACK_ID ?= $(shell echo $$RANDOM)
GITHUB_ACTIONS_RUNNER_STACK ?= github-actions-$(GITHUB_ACTIONS_RUNNER_STACK_ID)

github-runner-stack:
	@docker stack deploy \
	  --resolve-image never \
	  --compose-file $(CURDIR)/infra/github/docker-compose.yml \
	  $(GITHUB_ACTIONS_RUNNER_STACK)
.PHONY: github-runner-stack

github-runner:
	@docker compose -f $(CURDIR)/infra/github/docker-compose.yml \
	  up -d  \
	github-runner
.PHONY: github-runner

github-runner-rm:
	@docker compose -f $(CURDIR)/infra/github/docker-compose.yml \
	  rm -s -f
.PHONY: github-runner-rm

github-runner-stack-rm:
	@-docker stack rm $(GITHUB_ACTIONS_RUNNER_STACK)
.PHONY: github-runner-stack-rm

github-runner-image: docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print local-github-runner
	@$(DOCKER_BUILDX_BAKE) --load local-github-runner
.PHONY: github-runner-image

github-runner-image-push: docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print github-runner
	@$(DOCKER_BUILDX_BAKE) --push github-runner
.PHONY: github-runner-image-push