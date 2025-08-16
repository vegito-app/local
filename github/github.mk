GITHUB_ACTIONS_RUNNER_STACK_ID ?= $(shell echo $$RANDOM)
GITHUB_ACTIONS_RUNNER_STACK ?= github-actions-$(GITHUB_ACTIONS_RUNNER_STACK_ID)

LOCAL_GITHUB_ACTIONS_DIR ?= $(LOCAL_DIR)/github/
LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_CACHE ?= $(LOCAL_GITHUB_ACTIONS_DIR)/.containers/docker-buildx-cache/infra-github
$(LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_CACHE):;	@mkdir -p "$@"
ifneq ($(wildcard $(LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_CACHE)/index.json),)
LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_CACHE_READ = type=local,src=$(LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_CACHE)
endif
LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_CACHE_WRITE= type=local,mode=max,dest=$(LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_CACHE)

LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE ?= $(PUBLIC_IMAGES_BASE):github-actions-runner-latest

# Build image for local run. This target will not push an image to the distant registry.
local-github-actions-runner-image: $(LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_CACHE) docker-buildx-setup
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print github-actions-runner
	@$(LOCAL_DOCKER_BUILDX_BAKE) --load github-actions-runner
.PHONY: local-github-actions-runner-image

# Build image for local run and push it.
local-github-actions-runner-image-push: $(LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_CACHE) docker-buildx-setup
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print github-actions-runner
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push github-actions-runner
.PHONY: local-github-actions-runner-image-push

# This target will build and push a multi architecture image.
local-github-actions-runner-image-ci: docker-buildx-setup
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print github-actions-runner-ci
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push github-actions-runner-ci
.PHONY: local-github-actions-runner-image-ci

LOCAL_GITHUB_DOCKER_COMPOSE_PROJECT_NAME ?= $(LOCAL_PROJECT_NAME)-github-actions
LOCAL_GITHUB_DOCKER_COMPOSE ?= COMPOSE_PROJECT_NAME=$(LOCAL_GITHUB_DOCKER_COMPOSE_PROJECT_NAME) \
  docker compose -f $(LOCAL_GITHUB_ACTIONS_DIR)/docker-compose.yml

local-github-actions-runner-token-exist:
	@if [ ! -v GITHUB_ACTIONS_RUNNER_TOKEN ] ; then \
		echo missing GITHUB_ACTIONS_RUNNER_TOKEN environment variable. \
		exit -1 ; \
	fi
.PHONY: local-github-actions-runner-token-exist

local-github-actions-runner-container-up: local-github-actions-runner-container-rm local-github-actions-runner-token-exist
	@$(LOCAL_GITHUB_DOCKER_COMPOSE) up -d github-actions-runner
.PHONY: local-github-actions-runner-container-up

# This avoids github dangling offline containers on github.com side.
# It uses './config.sh remove' from github-actions-runner containers entrypoint
# before exit (see ./entrypoint.sh)
local-github-actions-runner-container-rm:
	@-$(LOCAL_GITHUB_DOCKER_COMPOSE) rm -s -f github-actions-runner
.PHONY: local-github-actions-runner-container-rm

LOCAL_GITHUB_WORKFLOWS_DIR := $(LOCAL_DIR)/.github/workflows/
LOCAL_GITHUB_ACT_SECRET_FILE := $(LOCAL_GITHUB_WORKFLOWS_DIR)/.secret

$(LOCAL_GITHUB_ACT_SECRET_FILE):
	@-rm -f $(LOCAL_GITHUB_ACT_SECRET_FILE) 2>&1
	@-echo DEV_GCLOUD_SERVICE_KEY=$$(jq -c . $(INFRA_DIR)/environments/gcloud-credentials.json) >> $(LOCAL_GITHUB_ACT_SECRET_FILE)
	@-echo STAGING_GCLOUD_SERVICE_KEY=$$(jq -c . $(INFRA_DIR)/environments/staging/gcloud-credentials.json) >> $(LOCAL_GITHUB_ACT_SECRET_FILE) 2>/dev/null 
	@-echo PRODUCTION_GCLOUD_SERVICE_KEY=$$(jq -c . $(INFRA_DIR)/environments/prod/gcloud-credentials.json) >> $(LOCAL_GITHUB_ACT_SECRET_FILE) 2>/dev/null

LOCAL_GITHUB_WORKFLOWS := \
  dev.yml \
  dev-feature.yml \
  staging.yml \
  production.yml

LOCAL_GITHUB_ACT := act --secret-file $(LOCAL_GITHUB_ACT_SECRET_FILE) \
	 -P self-hosted=$(LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE) \
	 
$(LOCAL_GITHUB_WORKFLOWS:%=local-github-run-%-workflow): $(LOCAL_GITHUB_ACT_SECRET_FILE)
	@$(LOCAL_GITHUB_ACT) -W $(LOCAL_DIR)/.github/workflows/$(@:github-run-%-workflow=%)
.PHONY: $(LOCAL_GITHUB_WORKFLOWS:%=local-github-run-%-workflow)
