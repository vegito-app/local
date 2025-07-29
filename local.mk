LATEST_BUILDER_IMAGE ?= $(PUBLIC_IMAGES_BASE):builder-latest

LOCAL_DIR ?= $(CURDIR)

LOCAL_DOCKER_COMPOSE ?= docker compose \
  -f $(LOCAL_DIR)/docker-compose.yml \
  -f $(LOCAL_DIR)/.docker-compose-override.yml \
  -f $(LOCAL_DIR)/.docker-compose-networks-override.yml \
  -f $(LOCAL_DIR)/.docker-compose-gpu-override.yml

local-container-config-show:
	@$(LOCAL_DOCKER_COMPOSE) config
.PHONY: local-container-config-show

LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_CACHE ?= $(LOCAL_DIR)/.containers/docker-buildx-cache/local-builder
$(LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_CACHE):;	@mkdir -p "$@"
ifneq ($(wildcard $(LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_CACHE)/index.json),)
LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_CACHE_READ = type=local,src=$(LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_CACHE)
endif
LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_CACHE_WRITE= type=local,mode=max,dest=$(LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_CACHE)

local-dev-container-image-pull:
	@$(LOCAL_DOCKER_COMPOSE) pull dev
.PHONY: local-dev-container-image-pull

local-docker-images-pull: $(LOCAL_DOCKER_BUILDX_BAKE_IMAGES:%=local-%-image-pull)
.PHONY: local-images-pull

local-docker-images-push: $(LOCAL_DOCKER_BUILDX_BAKE_IMAGES:%=local-%-image-push)
.PHONY: local-images-push

local-dev-container-logs:
	@$(LOCAL_DOCKER_COMPOSE) logs dev
.PHONY: local-dev-container-logs

local-dev-container-logs-f:
	@$(LOCAL_DOCKER_COMPOSE) logs -f dev
.PHONY: local-dev-container-logs-f

LOCAL_DOCKER_COMPOSE_SERVICES ?= \
  android-studio \
  application-backend \
  application-tests \
  clarinet-devnet \
  firebase-emulators \
  vault-dev

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
	@$(LOCAL_DOCKER_COMPOSE) up -d dev
.PHONY: local-dev-container

local-dev-container-rm:
	@$(LOCAL_DOCKER_COMPOSE) rm -s -f dev
.PHONY: local-dev-container-rm

local-dev-container-sh:
	@$(LOCAL_DOCKER_COMPOSE) exec -it dev bash
.PHONY: local-dev-container-sh

-include $(LOCAL_DIR)/docker/docker.mk
-include $(LOCAL_DIR)/android-studio/android-studio.mk
-include $(LOCAL_DIR)/clarinet-devnet/clarinet-devnet.mk
-include $(LOCAL_DIR)/github/github.mk
-include $(LOCAL_DIR)/firebase-emulators/firebase-emulators.mk
-include $(LOCAL_DIR)/vault-dev/vault-dev.mk
-include $(LOCAL_DIR)/application-tests/application-tests.mk
