# Local Docker Compose configuration
LOCAL_BUILDER_IMAGE ?= $(PUBLIC_IMAGES_BASE):builder-latest

LOCAL_DIR ?= $(CURDIR)

local-images: local-docker-images-host-arch
.PHONY: local-images

local-images-pull: 
	@$(MAKE) -j local-docker-images-pull
.PHONY: local-images-pull

local-images-push: 
	@$(MAKE) -j local-docker-images-push
.PHONY: local-images-push

local-images-ci: local-services-multi-arch-push-images
.PHONY: local-images-ci

LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_CACHE ?= $(LOCAL_DIR)/.containers/docker-buildx-cache/local-builder
$(LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_CACHE):;	@mkdir -p "$@"
ifneq ($(wildcard $(LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_CACHE)/index.json),)
LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_CACHE_READ = type=local,src=$(LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_CACHE)
endif
LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_CACHE_WRITE= type=local,mode=max,dest=$(LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_CACHE)

LOCAL_DOCKER_BUILDX_BAKE_IMAGES ?= \
  android-studio \
  clarinet-devnet \
  application-tests \
  firebase-emulators \
  vault-dev

local-docker-compose-dev-config-pull:
	@$(LOCAL_DOCKER_COMPOSE) pull dev
.PHONY: local-docker-compose-dev-image-pull

local-docker-images-pull: $(LOCAL_DOCKER_BUILDX_BAKE_IMAGES:%=local-%-image-pull) local-dev-container-image-pull
.PHONY: local-docker-images-pull

local-docker-images-push: $(LOCAL_DOCKER_BUILDX_BAKE_IMAGES:%=local-%-image-push) local-builder-image-push
.PHONY: local-docker-images-push

LOCAL_DOCKER_BUILDX_BAKE ?= docker buildx bake \
	-f $(LOCAL_DIR)/docker/docker-bake.hcl \
	-f $(LOCAL_DIR)/docker-bake.hcl \
	$(LOCAL_DOCKER_BUILDX_BAKE_IMAGES:%=-f $(LOCAL_DIR)/%/docker-bake.hcl) \
	-f $(LOCAL_DIR)/github/docker-bake.hcl

local-services-multi-arch-push-images: docker-buildx-setup local-builder-image-ci
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print local-services-multi-arch-push
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push local-services-multi-arch-push
.PHONY: local-services-multi-arch-push-images

local-docker-images-host-arch: local-builder-image
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print local-services-host-arch-load
	@$(LOCAL_DOCKER_BUILDX_BAKE) --load local-services-host-arch-load
.PHONY: local-docker-images-host-arch

$(LOCAL_DOCKER_BUILDX_BAKE_IMAGES:%=local-%-image): docker-buildx-setup
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:local-%-image=%)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --load $(@:local-%-image=%)
.PHONY: $(LOCAL_DOCKER_BUILDX_BAKE_IMAGES:%=local-%-image)

$(LOCAL_DOCKER_BUILDX_BAKE_IMAGES:%=local-%-image-push):
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:local-%-image-push=%)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push $(@:local-%-image-push=%)
.PHONY: $(LOCAL_DOCKER_BUILDX_BAKE_IMAGES:%=local-%-image-push)

# $(LOCAL_DOCKER_BUILDX_BAKE_IMAGES:%=local-%-image-pull):
# 	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:local-%-image-pull=%)
# 	@$(LOCAL_DOCKER_BUILDX_BAKE) --pull $(@:local-%-image-pull=%)
# .PHONY: $(LOCAL_DOCKER_BUILDX_BAKE_IMAGES:%=local-%-image-pull)

$(LOCAL_DOCKER_BUILDX_BAKE_IMAGES:%=local-%-image-ci): docker-buildx-setup
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:local-%-image-ci=%-ci)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push $(@:local-%-image-ci=%-ci)
.PHONY: $(LOCAL_DOCKER_BUILDX_BAKE_IMAGES:%=local-%-image-ci)

local-builder-image: $(LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_CACHE) docker-buildx-setup
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print builder
	@$(LOCAL_DOCKER_BUILDX_BAKE) --load builder
.PHONY: local-builder-image

local-builder-image-push: docker-buildx-setup
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print builder
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push builder
.PHONY: local-builder-image-push

local-builder-image-ci: docker-buildx-setup
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print builder-ci
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push builder-ci
.PHONY: local-builder-image-ci

local-gcloud-builder-image-delete:
	@echo "🗑️  Deleting builder image $(LOCAL_BUILDER_IMAGE)..."
	@$(GCLOUD) container images delete --force-delete-tags $(LOCAL_BUILDER_IMAGE)
.PHONY: local-gcloud-builder-image-delete

LOCAL_DOCKER_COMPOSE ?= docker compose \
  -f $(LOCAL_DIR)/docker-compose.yml \
  -f $(LOCAL_DIR)/.docker-compose-override.yml \
  -f $(LOCAL_DIR)/.docker-compose-networks-override.yml \
  -f $(LOCAL_DIR)/.docker-compose-gpu-override.yml

local-container-config-show:
	@$(LOCAL_DOCKER_COMPOSE) config
.PHONY: local-container-config-show

local-dev-container-image-pull:
	@$(LOCAL_DOCKER_COMPOSE) pull dev
.PHONY: local-dev-container-image-pull

local-dev-container-logs:
	@$(LOCAL_DOCKER_COMPOSE) logs dev
.PHONY: local-dev-container-logs

local-dev-container-logs-f:
	@$(LOCAL_DOCKER_COMPOSE) logs -f dev
.PHONY: local-dev-container-logs-f

LOCAL_DOCKER_COMPOSE_SERVICES ?= \
  android-studio \
  vault-dev \
  firebase-emulators \
  clarinet-devnet \
  application-backend \
  application-tests

local-containers-up: $(LOCAL_DOCKER_COMPOSE_SERVICES)
.PHONY: local-containers-up

local-containers-rm-all: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-container-rm)
.PHONY: local-containers-rm-all

$(LOCAL_DOCKER_COMPOSE_SERVICES:%=local-%-image-pull):
	$(LOCAL_DOCKER_COMPOSE) pull $(@:local-%-image-pull=%)
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

-include $(LOCAL_DIR)/nodejs.mk
-include $(LOCAL_DIR)/go.mk
-include $(LOCAL_DIR)/docker/docker.mk
-include $(LOCAL_DIR)/android-studio/android-studio.mk
-include $(LOCAL_DIR)/clarinet-devnet/clarinet-devnet.mk
-include $(LOCAL_DIR)/github/github.mk
-include $(LOCAL_DIR)/firebase-emulators/firebase-emulators.mk
-include $(LOCAL_DIR)/vault-dev/vault-dev.mk
-include $(LOCAL_DIR)/application-tests/application-tests.mk
