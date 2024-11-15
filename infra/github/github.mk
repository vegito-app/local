GITHUB_ACTIONS_RUNNER_STACK_ID = $(shell echo $$RANDOM)
GITHUB_ACTIONS_RUNNER_STACK = github-actions-$(GITHUB_ACTIONS_RUNNER_STACK_ID)

GITHUB_ACTIONS_RUNNER_IMAGE = $(PUBLIC_IMAGES_BASE):github-runner-$(VERSION)
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

# Build image for local run and push it.
local-github-runner-image-push: $(GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE) docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print github-runner
	@$(DOCKER_BUILDX_BAKE) --push github-runner
.PHONY: local-github-runner-image-push

# This target will build and push a multi architecture image.
local-github-runner-image-ci: docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print github-runner-ci
	@$(DOCKER_BUILDX_BAKE) github-runner-ci
.PHONY: local-github-runner-image-ci

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

LOCAL_GITHUB_WORKFLOWS_DIR := $(CURDIR)/.github/workflows/
LOCAL_GITHUB_ACT_SECRET_FILE := $(LOCAL_GITHUB_WORKFLOWS_DIR)/.secret

$(LOCAL_GITHUB_ACT_SECRET_FILE):
	@-rm -f $(LOCAL_GITHUB_ACT_SECRET_FILE) 2>&1
	@-echo DEV_GCLOUD_SERVICE_KEY=$$(jq -c . $(CURDIR)/infra/environments/dev/gcloud-credentials.json) >> $(LOCAL_GITHUB_ACT_SECRET_FILE)
	@-echo STAGING_GCLOUD_SERVICE_KEY=$$(jq -c . $(CURDIR)/infra/environments/staging/gcloud-credentials.json) >> $(LOCAL_GITHUB_ACT_SECRET_FILE) 2>/dev/null 
	@-echo PRODUCTION_GCLOUD_SERVICE_KEY=$$(jq -c . $(CURDIR)/infra/environments/prod/gcloud-credentials.json) >> $(LOCAL_GITHUB_ACT_SECRET_FILE) 2>/dev/null

GITHUB_WORKFLOWS := \
  dev.yml \
  dev-feature.yml \
  staging.yml \
  production.yml

LOCAL_GITHUB_ACT := act --secret-file $(LOCAL_GITHUB_ACT_SECRET_FILE) \
	 -P self-hosted=$(GITHUB_ACTIONS_RUNNER_IMAGE) \
	 
$(GITHUB_WORKFLOWS:%=github-run-%-workflow): $(LOCAL_GITHUB_ACT_SECRET_FILE)
	@$(LOCAL_GITHUB_ACT) -W $(CURDIR)/.github/workflows/$(@:github-run-%-workflow=%)
.PHONY: $(GITHUB_WORKFLOWS:%=-github-run-%-workflow)