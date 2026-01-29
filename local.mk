# Local Docker Compose configuration
LOCAL_BUILDER_IMAGE ?= $(VEGITO_LOCAL_PUBLIC_IMAGES_BASE):builder-latest
LOCAL_BUILDER_IMAGE_VERSION ?= $(VEGITO_LOCAL_PUBLIC_IMAGES_BASE):builder-$(VERSION)
LOCAL_DIR ?= $(CURDIR)

LOCAL_GITHUB_ACTIONS_DIR = $(LOCAL_DIR)/github-actions

LOCAL_DOCKER_BUILDX_BAKE_IMAGES ?= \
  clarinet-devnet \
  robotframework \
  firebase-emulators \
  vault-dev

local-docker-images-pull-parallel: local-docker-compose-images-pull-parallel local-android-docker-images-pull-parallel
.PHONY: local-docker-images-pull-parallel

local-docker-images-push: $(LOCAL_DOCKER_BUILDX_BAKE_IMAGES:%=local-%-image-push) local-builder-image-push
.PHONY: local-docker-images-push

LOCAL_DOCKER_BUILDX_BAKE ?= docker buildx bake --progress=plain \
	-f $(LOCAL_DIR)/docker/docker-bake.hcl \
	-f $(LOCAL_DIR)/docker-bake.hcl \
	-f $(LOCAL_DIR)/android/docker-bake.hcl \
	-f $(LOCAL_DIR)/android/studio/docker-bake.hcl \
	-f $(LOCAL_DIR)/android/emulator/docker-bake.hcl \
	-f $(LOCAL_DIR)/android/flutter/docker-bake.hcl \
	-f $(LOCAL_DIR)/android/appium/docker-bake.hcl \
	$(LOCAL_DOCKER_BUILDX_BAKE_IMAGES:%=-f $(LOCAL_DIR)/%/docker-bake.hcl) \
	-f $(LOCAL_DIR)/github-actions/docker-bake.hcl

$(LOCAL_DOCKER_BUILDX_BAKE_IMAGES:%=local-%-image): docker-buildx-setup
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:local-%-image=%)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --load $(@:local-%-image=%)
.PHONY: $(LOCAL_DOCKER_BUILDX_BAKE_IMAGES:%=local-%-image)

$(LOCAL_DOCKER_BUILDX_BAKE_IMAGES:%=local-%-image-push):
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:local-%-image-push=%)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push $(@:local-%-image-push=%)
.PHONY: $(LOCAL_DOCKER_BUILDX_BAKE_IMAGES:%=local-%-image-push)

$(LOCAL_DOCKER_BUILDX_BAKE_IMAGES:%=local-%-image-ci): docker-buildx-setup
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:local-%-image-ci=%-ci)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push $(@:local-%-image-ci=%-ci)
.PHONY: $(LOCAL_DOCKER_BUILDX_BAKE_IMAGES:%=local-%-image-ci)

local-project-builder-image: docker-buildx-setup
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print local-project-builder
	@$(LOCAL_DOCKER_BUILDX_BAKE) --load local-project-builder
.PHONY: local-project-builder-image

local-project-builder-image-ci: docker-buildx-setup
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print local-project-builder-ci
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push local-project-builder-ci
.PHONY: local-project-builder-image-ci

local-gcloud-builder-image-delete:
	@echo "🗑️  Deleting builder image $(LOCAL_BUILDER_IMAGE)..."
	@$(GCLOUD) container images delete --force-delete-tags $(LOCAL_BUILDER_IMAGE)
.PHONY: local-gcloud-builder-image-delete

LOCAL_DOCKER_COMPOSE ?= docker compose \
  -f $(LOCAL_DIR)/docker-compose.yml \
  -f $(LOCAL_DIR)/.docker-compose-services-override.yml \
  -f $(LOCAL_DIR)/.docker-compose-networks-override.yml \
  -f $(LOCAL_DIR)/.docker-compose-gpu-override.yml


LOCAL_DOCKER_COMPOSE_SERVICES ?= \
  clarinet-devnet \
  firebase-emulators \
  vault-dev \
  robotframework

local-docker-images-pull: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-image-pull) local-dev-container-image-pull
.PHONY: local-docker-images-pull

local-docker-compose-images-pull: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-image-pull)
.PHONY: local-docker-compose-images-pull

local-docker-compose-images-pull-parallel: 
	@echo "⬇︎ Pulling all local docker compose images..."
	@$(MAKE) -j local-docker-compose-images-pull
.PHONY: local-docker-compose-images-pull-parallel

local-docker-compose-images-pull: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-image-pull)
.PHONY: local-docker-compose-images-pull

local-docker-compose-images-push: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-image-push) local-dev-container-image-push
.PHONY: local-docker-compose-images-push

local-docker-compose-network-rm-dev: 
	@echo "🗑️  Removing the docker network used"
	@-docker network rm $(COMPOSE_PROJECT_NAME)_dev
.PHONY: local-docker-compose-network-rm-dev

local-dev-images-pull: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-image-pull)
.PHONY: local-dev-images-pull

local-containers-up: $(LOCAL_DOCKER_COMPOSE_SERVICES)
.PHONY: local-containers-up

local-containers-rm: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-container-rm)
.PHONY: local-containers-rm

local-containers-logs: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-container-logs)
.PHONY: local-containers-logs

$(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-image-pull):
	@echo "⬇︎ Pulling image for $(@:local-%-image-pull=%)..."
	@$(LOCAL_DOCKER_COMPOSE) pull $(@:local-%-image-pull=%)
.PHONY: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-image-pull)

$(LOCAL_DOCKER_COMPOSE_SERVICES):
	@echo "⬆︎ Bringing up container for $(@:%=%)..."
	@$(MAKE) $(@:%=local-%-container-up)
.PHONY: $(LOCAL_DOCKER_COMPOSE_SERVICES)

$(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-container-rm): 
	@echo "🗑️  Removing container for $(@:local-%-container-rm=%)..."
	@$(MAKE) $(@:%-rm=%-stop)
	@$(LOCAL_DOCKER_COMPOSE) rm -f $(@:local-%-container-rm=%)
.PHONY: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-container-rm)

$(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-container-start):
	@echo "▶️ Starting $(@:local-%-container-start=%)..."
	@-$(LOCAL_DOCKER_COMPOSE) start $(@:local-%-container-start=%) 2>/dev/null
.PHONY: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-container-start)

$(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-container-stop):
	@echo "🛑 Stopping $(@:local-%-container-stop=%)..."
	@-$(LOCAL_DOCKER_COMPOSE) stop $(@:local-%-container-stop=%) 2>/dev/null
.PHONY: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-container-stop)

$(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-container-logs):
	@echo "🗒️ Showing logs for $(@:local-%-container-logs=%)..."
	@$(LOCAL_DOCKER_COMPOSE) logs $(@:local-%-container-logs=%)
.PHONY: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-container-logs)

$(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-container-logs-f):
	@echo "📝 Following logs for $(@:local-%-container-logs-f=%)..."
	@$(LOCAL_DOCKER_COMPOSE) logs --follow $(@:local-%-container-logs-f=%)
.PHONY: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-container-logs-f)

$(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-container-sh):
	@echo "💻 Opening bash shell for $(@:local-%-container-sh=%)..."
	@$(LOCAL_DOCKER_COMPOSE) exec $(@:local-%-container-sh=%) bash
.PHONY: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-container-sh)

local-dev-container:
	@echo "⬆︎ Bringing up dev container..."
	@$(LOCAL_DOCKER_COMPOSE) up -d --remove-orphans dev
.PHONY: local-dev-container

local-dev-container-rm:
	@$(LOCAL_DOCKER_COMPOSE) rm -s -f dev
.PHONY: local-dev-container-rm

local-dev-container-sh:
	@$(LOCAL_DOCKER_COMPOSE) exec dev bash
.PHONY: local-dev-container-sh

local-container-config-show:
	@echo "📦 Showing container configuration..."
	@$(LOCAL_DOCKER_COMPOSE) config
.PHONY: local-container-config-show

local-dev-container-image-pull:
	@echo "⬇︎ Pulling builder image $(LOCAL_BUILDER_IMAGE)..."
	@$(LOCAL_DOCKER_COMPOSE) pull dev
.PHONY: local-dev-container-image-pull

local-dev-container-image-push:
	@echo "⬆︎ Pushing builder image $(LOCAL_BUILDER_IMAGE)..."
	@docker push $(LOCAL_BUILDER_IMAGE)
.PHONY: local-dev-container-image-push

local-dev-container-logs:
	@echo "🗒️ Showing logs for dev container..."
	@$(LOCAL_DOCKER_COMPOSE) logs dev
.PHONY: local-dev-container-logs

local-dev-container-logs-f:
	@echo "📝 Following logs for dev container..."
	@$(LOCAL_DOCKER_COMPOSE) logs -f dev
.PHONY: local-dev-container-logs-f

# Local Docker Compose Services for CI
LOCAL_DOCKER_COMPOSE_SERVICES_CI ?= \
  robotframework

#   clarinet-devnet
LOCAL_DEV_CONTAINER_DOCKER_COMPOSE_NAME = dev

LOCAL_DEV_CONTAINER_RUN = \
  LOCAL_CONTAINER_INSTALL=false \
  MAKE_DEV_ON_START=false \
  $(LOCAL_DOCKER_COMPOSE) run --rm $(LOCAL_DEV_CONTAINER_DOCKER_COMPOSE_NAME)

LOCAL_CONTAINERS_OPERATIONS_CI = up rm logs

$(LOCAL_CONTAINERS_OPERATIONS_CI:%=local-containers-%-ci): local-dev-container-image-pull
	@echo "Running operation 'local-containers-$(@:local-containers-%-ci=%)' for all local containers in CI..."
	@echo "Using builder image: $(LOCAL_BUILDER_IMAGE)"
	@$(LOCAL_DEV_CONTAINER_RUN) \
	    make local-containers-$(@:local-containers-%-ci=%) \
	      LOCAL_DOCKER_COMPOSE_SERVICES="$(LOCAL_DOCKER_COMPOSE_SERVICES_CI)" \
	      LOCAL_CLARINET_DEVNET_CACHES_REFRESH=false \
	      LOCAL_VAULT_AUDIT_INIT=false \
	      VERSION=$(LOCAL_VERSION)
.PHONY: $(LOCAL_CONTAINERS_OPERATIONS_CI:%=local-containers-%-ci)

-include $(LOCAL_DIR)/docker/docker.mk
-include $(LOCAL_DIR)/android/android.mk
-include $(LOCAL_DIR)/clarinet-devnet/clarinet-devnet.mk
-include $(LOCAL_DIR)/github-actions/github-actions.mk
-include $(LOCAL_DIR)/firebase-emulators/firebase-emulators.mk
-include $(LOCAL_DIR)/vault-dev/vault-dev.mk
-include $(LOCAL_DIR)/robotframework/robotframework.mk
