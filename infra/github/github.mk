GITHUB_ACTION_RUNNER_IMAGE ?= $(PUBLIC_IMAGES_BASE):$(VERSION)-github-runner
GITHUB_ACTION_RUNNER_NAME ?= $(shell hostname)
GITHUB_ACTION_RUNNER_URL=https://github.com/7d4b9/refactored-winner
GITHUB_RUNNER_CONTAINER_NAME=$(PROJECT_NAME)-github-runner

github-runner-build:
	@cd $(CURDIR)/infra/github \
	&& docker build \
	  --build-arg builder_image=$(LATEST_BUILDER_IMAGE) \
	  -t $(GITHUB_ACTION_RUNNER_IMAGE) \
	  .
.PHONY: github-runner-build

github-runner: github-runner-rm github-runner-build 
	@docker run --rm -d \
	  --name $(GITHUB_RUNNER_CONTAINER_NAME) \
	  -v /var/run/docker.sock:/var/run/docker.sock \
	  $(GITHUB_ACTION_RUNNER_IMAGE) \
	  bash -c ' \
	  ./config.sh \
	  	--url $(GITHUB_ACTION_RUNNER_URL) \
		--token $(GITHUB_ACTION_RUNNER_TOKEN) \
		--unattended \
		--name docker-`hostname` \
	  && ./run.sh'
	  @docker logs $(GITHUB_RUNNER_CONTAINER_NAME)
.PHONY: github-runner

github-runner-rm: github-runner-build
	@-docker exec $(GITHUB_RUNNER_CONTAINER_NAME) \
	  ./config.sh remove --token $(GITHUB_ACTION_RUNNER_TOKEN) 2>/dev/null
	@-docker rm -f $(GITHUB_RUNNER_CONTAINER_NAME) 2>/dev/null
.PHONY: github-runner-rm