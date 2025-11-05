GITHUB_ACTIONS_RUNNER_STACK_ID ?= $(shell echo $$RANDOM)
GITHUB_ACTIONS_RUNNER_STACK ?= github-actions-$(GITHUB_ACTIONS_RUNNER_STACK_ID)
LOCAL_GITHUB_ACTIONS_DIR ?= $(CURDIR)
LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE ?= $(VEGITO_LOCAL_PUBLIC_IMAGES_BASE):github-actions-runner-$(VERSION)

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

LOCAL_GITHUB_ACTIONS_RUNNER_URL ?= https://github.com/organizations/vegito-app/settings/actions/runners

local-github-actions-runner-token-exist:
	@if [ ! -v GITHUB_ACTIONS_RUNNER_TOKEN ] ; then \
		echo Missing GITHUB_ACTIONS_RUNNER_TOKEN environment variable. ; \
		echo ; \
		echo Get a new self-hosted runner token. Click on "'New Runner'" here: ; \
		echo ; \
		echo $(LOCAL_GITHUB_ACTIONS_RUNNER_URL) ; \
		echo ; \
		echo Then, set the GITHUB_ACTIONS_RUNNER_TOKEN environment variable: ; \
		echo ; \
		echo 'export GITHUB_ACTIONS_RUNNER_TOKEN=<your_token>' ; \
		echo ; \
		echo or use it inline with make: ; \
		echo ; \
		echo 'GITHUB_ACTIONS_RUNNER_TOKEN=<your_token> make <your_target>' ; \
		echo ; \
		exit -1 ; \
	fi
.PHONY: local-github-actions-runner-token-exist

local-github-actions-runner-remove-token-exist:
	@if [ ! -v GITHUB_ACTIONS_RUNNER_REMOVE_TOKEN ] ; then \
		echo Missing GITHUB_ACTIONS_RUNNER_REMOVE_TOKEN environment variable. ; \
		echo ; \
		echo Get a new Github Actions runner token. ;\
		echo Click on "'Remove Runner'" on a current runner here: ; \
		echo ; \
		echo $(LOCAL_GITHUB_ACTIONS_RUNNER_URL) ; \
		echo ; \
		echo Then, set the GITHUB_ACTIONS_RUNNER_REMOVE_TOKEN environment variable: ; \
		echo ; \
		echo 'export GITHUB_ACTIONS_RUNNER_REMOVE_TOKEN=<your_token>' ; \
		echo ; \
		echo or use it inline with make: ; \
		echo ; \
		echo 'GITHUB_ACTIONS_RUNNER_REMOVE_TOKEN=<your_token> make <your_remove_target>' ; \
		echo ; \
		exit -1 ; \
	fi
.PHONY: local-github-actions-runner-remove-token-exist

LOCAL_GITHUB_ACTIONS_DOCKER_COMPOSE_PROJECT_NAME ?= $(VEGITO_PROJECT_NAME)-github-actions
LOCAL_GITHUB_ACTIONS_DOCKER_COMPOSE ?= COMPOSE_PROJECT_NAME=$(LOCAL_GITHUB_ACTIONS_DOCKER_COMPOSE_PROJECT_NAME) \
  docker compose -f $(LOCAL_GITHUB_ACTIONS_DIR)/docker-compose.yml

LOCAL_GITHUB_ACTIONS_RUNNER_CONTAINER_EXEC ?= $(LOCAL_GITHUB_ACTIONS_DOCKER_COMPOSE) exec github-actions-runner

LOCAL_GITHUB_ACTIONS_RUNNER_DOCKER_COMPOSE_SERVICES ?= runner

$(LOCAL_GITHUB_ACTIONS_RUNNER_DOCKER_COMPOSE_SERVICES:%=local-github-actions-%-image-pull):
	@echo Pulling the container image for $(@:local-%-image-pull=%)
	@$(LOCAL_GITHUB_ACTIONS_DOCKER_COMPOSE) pull $(@:local-%-image-pull=%)
.PHONY: $(LOCAL_GITHUB_ACTIONS_RUNNER_DOCKER_COMPOSE_SERVICES:%=local-github-actions-%-image-pull)

local-github-actions-runner-container-up: local-github-actions-runner-token-exist
	@echo Starting github-actions-runner container...
	@$(LOCAL_GITHUB_ACTIONS_DOCKER_COMPOSE) up -d github-actions-runner
.PHONY: local-github-actions-runner-container-up

# This avoids github dangling offline runners on github.com side.
local-github-actions-runner-container-rm: local-github-actions-runner-remove-token-exist
	@echo 🛑 Stopping and removing GitHub Actions runner containers...

	# Liste tous les containers `github-actions-runner-N`
	@containers=$$(docker ps -qf "name=github-actions-runner") ; \
	for container in $$containers ; do \
		echo 🔄 Unregistering runner in container $$container... ; \
		docker exec $$container bash -c "cd /runner && ./config.sh remove --token $(GITHUB_ACTIONS_RUNNER_REMOVE_TOKEN)" || true ; \
	done ; \

	# Attente passive que les containers se ferment d'eux-mêmes
	@echo ⏳ Waiting for containers to exit...
	@while docker ps -qf "name=github-actions-runner" | grep -q . ; do \
		echo "🕒 Still waiting..." ; \
		sleep 2 ; \
	done

	# Nettoyage des services
	@echo 🧹 Cleaning up services...
	@-$(LOCAL_GITHUB_ACTIONS_DOCKER_COMPOSE) rm -s -f github-actions-runner

	@echo ✅ All GitHub Actions runners removed.
.PHONY: local-github-actions-runner-container-rm

LOCAL_GITHUB_WORKFLOWS_DIR ?= $(LOCAL_DIR)/.github-actions/github-actionsworkflows/
LOCAL_GITHUB_ACT_SECRET_FILE ?= $(LOCAL_GITHUB_WORKFLOWS_DIR)/.secret

$(LOCAL_GITHUB_ACT_SECRET_FILE):
	@-rm -f $(LOCAL_GITHUB_ACT_SECRET_FILE) 2>&1
	@-echo DEV_GCLOUD_SERVICE_KEY=$$(jq -c . $(INFRA_DIR)/environments/google-cloud-credentials.json) >> $(LOCAL_GITHUB_ACT_SECRET_FILE)
	@-echo STAGING_GCLOUD_SERVICE_KEY=$$(jq -c . $(INFRA_DIR)/environments/staging/google-cloud-credentials.json) >> $(LOCAL_GITHUB_ACT_SECRET_FILE) 2>/dev/null 
	@-echo PRODUCTION_GCLOUD_SERVICE_KEY=$$(jq -c . $(INFRA_DIR)/environments/prod/google-cloud-credentials.json) >> $(LOCAL_GITHUB_ACT_SECRET_FILE) 2>/dev/null

LOCAL_GITHUB_WORKFLOWS := \
  dev.yml \
  dev-feature.yml \
  main.yml

LOCAL_GITHUB_ACT := act --secret-file $(LOCAL_GITHUB_ACT_SECRET_FILE) \
	 -P self-hosted=$(LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE) \
	 
$(LOCAL_GITHUB_WORKFLOWS:%=local-github-run-%-workflow): $(LOCAL_GITHUB_ACT_SECRET_FILE)
	@$(LOCAL_GITHUB_ACT) -W $(LOCAL_DIR)/.github-actions/github-actionsworkflows/$(@:github-run-%-workflow=%)
.PHONY: $(LOCAL_GITHUB_WORKFLOWS:%=local-github-run-%-workflow)
