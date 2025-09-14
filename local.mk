# Local Docker Compose configuration
LOCAL_BUILDER_IMAGE ?= $(VEGITO_LOCAL_PUBLIC_IMAGES_BASE):builder-latest

LOCAL_DIR ?= $(CURDIR)

LOCAL_GITHUB_ACTIONS_DIR = $(LOCAL_DIR)/github
# local-images: local-docker-images-ci
# .PHONY: local-images

local-images-push: 
	@$(MAKE) -j local-docker-images-push local-android-docker-images-push-parallel
.PHONY: local-images-push

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

local-project-builder-image: docker-buildx-setup
	$(LOCAL_DOCKER_BUILDX_BAKE) --print local-project-builder
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
  dev \
  vault-dev \
  firebase-emulators \
  clarinet-devnet \
  application-tests \
  application-backend \
  application-mobile

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

LOCAL_DOCKER_COMPOSE_SERVICES_CI ?= \
  vault-dev \
  firebase-emulators \
  clarinet-devnet \
  application-tests \
  application-backend \
  application-mobile

local-containers-up-ci: 
	@$(MAKE) local-containers-up \
	  LOCAL_DOCKER_COMPOSE_SERVICES=$(LOCAL_DOCKER_COMPOSE_SERVICES_CI) \
      LOCAL_ANDROID_STUDIO_ON_START=false \
      LOCAL_ANDROID_STUDIO_CACHES_REFRESH=false \
      LOCAL_CLARINET_DEVNET_CACHES_REFRESH=false \
	  LOCAL_VAULT_AUDIT_INIT=false \
	  LOCAL_ANDROID_CONTAINER_NAME=application-mobile \
	  LOCAL_APPLICATION_BACKEND_IMAGE=$(VEGITO_LOCAL_PUBLIC_IMAGES_BASE):application-backend-$(VERSION) \
	  LOCAL_APPLICATION_MOBILE_IMAGE=$(VEGITO_LOCAL_PUBLIC_IMAGES_BASE):application-mobile-$(VERSION) \
	  LOCAL_APPLICATION_TESTS_IMAGE=$(VEGITO_LOCAL_PUBLIC_IMAGES_BASE):application-tests-$(VERSION)
	  LOCAL_CLARINET_DEVNET_IMAGE=$(VEGITO_LOCAL_PUBLIC_IMAGES_BASE):clarinet-devnet-$(VERSION) \
	  LOCAL_FIREBASE_EMULATORS_IMAGE=$(VEGITO_LOCAL_PUBLIC_IMAGES_BASE):firebase-emulators-$(VERSION) \
	  LOCAL_VAULT_DEV_IMAGE=$(VEGITO_LOCAL_PUBLIC_IMAGES_BASE):vault-dev-$(VERSION) \
.PHONY: local-containers-up-ci

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
	$(LOCAL_DOCKER_COMPOSE) up -d dev
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
