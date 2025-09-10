# Local Docker Compose configuration
LOCAL_BUILDER_IMAGE ?= $(VEGITO_LOCAL_PUBLIC_IMAGES_BASE):builder-latest

LOCAL_DIR ?= $(CURDIR)

local-images: 
	@$(MAKE) -j local-docker-images-ci
.PHONY: local-images

local-images-push: 
	@$(MAKE) -j local-docker-images-push local-android-docker-images-push-parallel
.PHONY: local-images-push

LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_CACHE ?= $(LOCAL_DIR)/.containers/docker-buildx-cache/local-builder
$(LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_CACHE):;	@mkdir -p "$@"
ifneq ($(wildcard $(LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_CACHE)/index.json),)
LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ = type=local,src=$(LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_CACHE)
endif
LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_CACHE_WRITE= type=local,mode=max,dest=$(LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_CACHE)

LOCAL_DOCKER_BUILDX_BAKE_IMAGES ?= \
  clarinet-devnet \
  application-tests \
  firebase-emulators \
  vault-dev

local-docker-images-pull-parallel: local-docker-compose-images-pull-parallel local-android-docker-images-pull-parallel
.PHONY: local-docker-images-pull-parallel

local-dockercompose-images-push: 
	@$(MAKE) -j local-dockercompose-images-push
.PHONY: local-dockercompose-images-push

LOCAL_DOCKER_BUILDX_BAKE ?= docker buildx bake --progress=plain \
	-f $(LOCAL_DIR)/docker/docker-bake.hcl \
	-f $(LOCAL_DIR)/docker-bake.hcl \
	-f $(LOCAL_DIR)/android/docker-bake.hcl \
	-f $(LOCAL_DIR)/android/studio/docker-bake.hcl \
	-f $(LOCAL_DIR)/android/emulator/docker-bake.hcl \
	-f $(LOCAL_DIR)/android/flutter/docker-bake.hcl \
	-f $(LOCAL_DIR)/android/appium/docker-bake.hcl \
	$(LOCAL_DOCKER_BUILDX_BAKE_IMAGES:%=-f $(LOCAL_DIR)/%/docker-bake.hcl) \
	-f $(LOCAL_DIR)/github/docker-bake.hcl

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

local-project-builder-image: $(LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_CACHE) docker-buildx-setup
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

local-container-config-show:
	@$(LOCAL_DOCKER_COMPOSE) config
.PHONY: local-container-config-show

local-dev-container-image-pull:
	docker pull $(LOCAL_BUILDER_IMAGE)
.PHONY: local-dev-container-image-pull

local-dev-container-image-push:
	@docker push $(LOCAL_BUILDER_IMAGE)
.PHONY: local-dev-container-image-push

local-dev-container-logs:
	@$(LOCAL_DOCKER_COMPOSE) logs dev
.PHONY: local-dev-container-logs

local-dev-container-logs-f:
	@$(LOCAL_DOCKER_COMPOSE) logs -f dev
.PHONY: local-dev-container-logs-f

LOCAL_DOCKER_COMPOSE_SERVICES ?= \
  vault-dev \
  firebase-emulators \
  clarinet-devnet \
  application-tests

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

local-dev-images-pull: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-image-pull)
.PHONY: local-dev-images-pull

local-containers-up: $(LOCAL_DOCKER_COMPOSE_SERVICES)
.PHONY: local-containers-up

local-containers-rm-all: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-container-rm)
.PHONY: local-containers-rm-all

$(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-image-pull):
	@$(LOCAL_DOCKER_COMPOSE) pull $(@:local-%-image-pull=%)
.PHONY: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-image-pull)

$(LOCAL_DOCKER_COMPOSE_SERVICES):
	@$(MAKE) $(@:%=local-%-container-up)
.PHONY: $(LOCAL_DOCKER_COMPOSE_SERVICES)

$(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-container-rm): 
	@$(MAKE) $(@:%-rm=%-stop)
	@$(LOCAL_DOCKER_COMPOSE) rm -f $(@:local-%-container-rm=%)
.PHONY: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-container-rm)

$(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-container-start):
	@-$(LOCAL_DOCKER_COMPOSE) start $(@:local-%-container-start=%) 2>/dev/null
.PHONY: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-container-start)

$(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-container-stop):
	@-$(LOCAL_DOCKER_COMPOSE) stop $(@:local-%-container-stop=%) 2>/dev/null
.PHONY: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-container-stop)

$(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-container-logs):
	@$(LOCAL_DOCKER_COMPOSE) logs $(@:local-%-container-logs=%)
.PHONY: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-container-logs)

$(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-container-logs-f):
	@$(LOCAL_DOCKER_COMPOSE) logs --follow $(@:local-%-container-logs-f=%)
.PHONY: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-container-logs-f)

$(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-container-sh):
	@$(LOCAL_DOCKER_COMPOSE) exec -it $(@:local-%-container-sh=%) bash
.PHONY: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-container-sh)

local-dev-container:
	@echo "🔧 Starting local development container..."
	@$(LOCAL_DOCKER_COMPOSE) up -d dev
.PHONY: local-dev-container

local-dev-container-rm:
	@$(LOCAL_DOCKER_COMPOSE) rm -s -f dev
.PHONY: local-dev-container-rm

local-dev-container-sh:
	@$(LOCAL_DOCKER_COMPOSE) exec -it dev bash
.PHONY: local-dev-container-sh

-include $(LOCAL_DIR)/nodejs.mk
-include $(LOCAL_DIR)/go.mk
-include $(LOCAL_DIR)/docker/docker.mk
-include $(LOCAL_DIR)/android/android.mk
-include $(LOCAL_DIR)/clarinet-devnet/clarinet-devnet.mk
-include $(LOCAL_DIR)/github/github.mk
-include $(LOCAL_DIR)/firebase-emulators/firebase-emulators.mk
-include $(LOCAL_DIR)/vault-dev/vault-dev.mk
-include $(LOCAL_DIR)/application-tests/application-tests.mk
