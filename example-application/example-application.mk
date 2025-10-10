LOCAL_EXAMPLE_APPLICATION_DIR ?= $(CURDIR)/example-application

-include $(LOCAL_EXAMPLE_APPLICATION_DIR)/frontend/frontend.mk
-include $(LOCAL_EXAMPLE_APPLICATION_DIR)/backend/backend.mk
-include $(LOCAL_EXAMPLE_APPLICATION_DIR)/mobile/mobile.mk

APPLICATION_DOCKER_BUILDX_BAKE_IMAGES := \
  backend \
  mobile

local-example-application-docker-images:
	@$(MAKE) -j $(APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:%=local-example-application-%-image)
.PHONY: local-example-application-docker-images

$(APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:%=local-example-application-%-image): docker-buildx-setup
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:%-image=%)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --load $(@:%-image=%)
.PHONY: $(APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:%=local-example-application-%-image)

local-example-application-docker-images-ci:
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print local-example-application-ci
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push local-example-application-ci
.PHONY: local-example-application-docker-images-ci

$(APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:%=local-example-application-%-image-ci): docker-buildx-setup
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:%-image-ci=%-ci)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push $(@:%-image-ci=%-ci)
.PHONY: $(APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:%=local-example-application-%-image-ci)

LOCAL_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES ?= \
  example-application-backend \
  example-application-mobile

local-example-application-containers-rm: $(LOCAL_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-%-container-rm)
.PHONY: local-example-application-containers-rm

local-example-application-containers-up: $(LOCAL_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-%-container-up)
.PHONY: local-example-application-containers-up

$(LOCAL_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-%-container-rm):
	@echo "🗑️  Removing container for $(@:local-%-container-rm=%)..."
	@$(MAKE) $(@:%-rm=%-stop)
	@$(LOCAL_DOCKER_COMPOSE) rm -f $(@:local-%-container-rm=%)
.PHONY: $(LOCAL_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-%-container-rm)

$(LOCAL_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-%-container-rm-ci): 
	@echo "🗑️  Removing container for $(@:local-%-container-rm-ci=%)..."
	@echo $(MAKE) $(@:%-rm-ci=%-stop)
	@echo $(LOCAL_DOCKER_COMPOSE) rm -f $(@:local-%-container-rm-ci=%)
.PHONY: $(LOCAL_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-%-container-rm-ci)

$(LOCAL_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-%-container-start):
	@echo "▶️ Starting $(@:local-%-container-start=%)..."
	@-$(LOCAL_DOCKER_COMPOSE) start $(@:local-%-container-start=%) 2>/dev/null
.PHONY: $(LOCAL_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-%-container-start)

$(LOCAL_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-%-container-stop):
	@echo "🛑 Stopping container for $(@:local-%-container-stop=%)..."
	@-$(LOCAL_DOCKER_COMPOSE) stop $(@:local-%-container-stop=%) 2>/dev/null
.PHONY: $(LOCAL_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-%-container-stop)

$(LOCAL_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-%-container-logs):
	@echo "🗒️ Showing logs for $(@:local-%-container-logs=%)..."
	@$(LOCAL_DOCKER_COMPOSE) logs $(@:local-%-container-logs=%)
.PHONY: $(LOCAL_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-%-container-logs)

$(LOCAL_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-%-container-logs-f):
	@echo "📝 Following logs for $(@:local-%-container-logs-f=%)..."
	@$(LOCAL_DOCKER_COMPOSE) logs --follow $(@:local-%-container-logs-f=%)
.PHONY: $(LOCAL_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-%-container-logs-f)

$(LOCAL_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-%-container-sh):
	@echo "💻 Opening bash shell for $(@:local-%-container-sh=%)..."
	@$(LOCAL_DOCKER_COMPOSE) exec -it $(@:local-%-container-sh=%) bash
.PHONY: $(LOCAL_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-%-container-sh)

$(LOCAL_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-%-image-pull):
	@echo Pulling the container image for $(@:local-%-image-pull=%)
	$(LOCAL_DOCKER_COMPOSE) pull $(@:local-%-image-pull=%)
.PHONY: $(LOCAL_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-%-image-pull)

local-example-application-docker-compose-images-pull: $(LOCAL_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-%-image-pull)
.PHONY: local-example-application-docker-compose-images-pull

local-example-application-docker-images-pull: 
	@$(MAKE) -j local-example-application-docker-compose-images-pull
.PHONY: local-example-application-docker-images-pull

local-example-application-docker-images-pull-parallel: 
	@echo Pulling all application images in parallel...
	@$(MAKE) -j local-example-application-docker-images-pull
.PHONY: local-example-application-docker-images-pull-parallel

$(LOCAL_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-example-application-%-image-push):
	@echo Pushing the container image for $(@:local-%-image-push=%)
	@$(LOCAL_DOCKER_COMPOSE) push $(@:local-%-image-push=%)
.PHONY: $(LOCAL_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-example-application-%-image-push)

local-example-application-docker-compose-images-push: $(LOCAL_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-example-application-%-image-push)
.PHONY: local-example-application-docker-compose-images-push

local-example-application-docker-images-push: 
	@$(MAKE) -j local-example-application-docker-compose-images-push
.PHONY: local-example-application-docker-images-push

LOCAL_CONTAINERS_GROUP_OPERATIONS_CI := up rm

$(LOCAL_CONTAINERS_GROUP_OPERATIONS_CI:%=local-example-application-containers-%-ci): local-dev-container-image-pull
	@echo "Running operation 'local-example-application-containers-$(@:local-example-application-containers-%-ci=%)' for all local containers in CI..."
	@echo "Using builder image: $(LOCAL_BUILDER_IMAGE_VERSION)"
	@LOCAL_BUILDER_IMAGE=$(LOCAL_BUILDER_IMAGE_VERSION) \
	  LOCAL_ANDROID_GPU_MODE=swiftshader_indirect \
	  $(LOCAL_DEV_CONTAINER_RUN) \
	    make local-example-application-containers-$(@:local-example-application-containers-%-ci=%) \
	      LOCAL_ANDROID_CONTAINER_NAME=application-mobile \
	      LOCAL_EXAMPLE_APPLICATION_BACKEND_IMAGE=$(VEGITO_LOCAL_PUBLIC_IMAGES_BASE):application-backend-$(VERSION) \
	      LOCAL_EXAMPLE_APPLICATION_MOBILE_IMAGE=$(VEGITO_LOCAL_PUBLIC_IMAGES_BASE):application-mobile-$(VERSION)
.PHONY: $(LOCAL_CONTAINERS_GROUP_OPERATIONS_CI:%=local-example-application-containers-%-ci)

local-example-application-docker-images-push-parallel: 
	@echo Pushing all application images in parallel...
	@$(MAKE) -j local-example-application-docker-images-push
.PHONY: local-example-application-docker-images-push-parallel
