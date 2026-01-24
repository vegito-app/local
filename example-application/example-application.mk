VEGITO_EXAMPLE_APPLICATION_DIR ?= $(CURDIR)

-include $(VEGITO_EXAMPLE_APPLICATION_DIR)/frontend/frontend.mk
-include $(VEGITO_EXAMPLE_APPLICATION_DIR)/backend/backend.mk
-include $(VEGITO_EXAMPLE_APPLICATION_DIR)/mobile/mobile.mk
-include $(VEGITO_EXAMPLE_APPLICATION_DIR)/tests/tests.mk

APPLICATION_DOCKER_BUILDX_BAKE_IMAGES := \
  backend \
  mobile \
  tests

example-application-docker-images:
	@$(MAKE) -j $(APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:%=example-application-%-image)
.PHONY: example-application-docker-images

$(APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:%=example-application-%-image): docker-buildx-setup
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:%-image=%)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --load $(@:%-image=%)
.PHONY: $(APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:%=example-application-%-image)

example-application-docker-images-ci:
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print example-application-ci
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push example-application-ci
.PHONY: example-application-docker-images-ci

$(APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:%=example-application-%-image-ci): docker-buildx-setup
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:%-image-ci=%-ci)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push $(@:%-image-ci=%-ci)
.PHONY: $(APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:%=example-application-%-image-ci)

example-application-docker-tags-list-ci: $(APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:%=example-application-%-docker-tags-list-ci)
.PHONY: example-application-docker-tags-list-ci

$(APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:%=example-application-%-docker-tags-ci): docker-buildx-setup
	@$($(LOCAL_DOCKER_BUILDX_BAKE)) --print $(@:%-docker-tags=%-ci) 2>/dev/null \
	| jq -r '.target | to_entries[] | .value.tags[]'
.PHONY: $(APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:%=example-application-%-docker-group-tags-ci)

VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES ?= \
  example-application-backend \
  example-application-mobile \
  example-application-tests

example-application-containers-rm: $(VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=%-container-rm)
.PHONY: example-application-containers-rm

example-application-containers-up: $(VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=%-container-up)
.PHONY: example-application-containers-up

$(VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES):
	@$(MAKE) $(@:%=%-container-up)
.PHONY: $(VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES)

$(VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=%-container-up-ci): local-dev-container-image-pull
	@echo "Running operation 'example-application-containers-$(@:example-application-containers-%-container-up-ci=%)' for all local containers in CI..."
	@echo "Using builder image: $(LOCAL_BUILDER_IMAGE_VERSION)"
	@LOCAL_BUILDER_IMAGE=$(LOCAL_BUILDER_IMAGE_VERSION) \
	  LOCAL_ANDROID_GPU_MODE=swiftshader_indirect \
	  $(LOCAL_DEV_CONTAINER_RUN) \
	    make $(@:%-ci=%) \
	      LOCAL_ANDROID_CONTAINER_NAME=$(LOCAL_ANDROID_CONTAINER_NAME) \
	      VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE=$(VEGITO_LOCAL_PUBLIC_IMAGES_BASE):example-application-backend-$(VERSION) \
	      VEGITO_EXAMPLE_APPLICATION_MOBILE_IMAGE=$(VEGITO_LOCAL_PUBLIC_IMAGES_BASE):example-application-mobile-$(VERSION)
.PHONY: $(VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=%-container-up-ci)

example-application-containers-logs: $(VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=%-container-logs)
.PHONY: example-application-containers-logs

$(VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=%-container-rm):
	@echo "🗑️  Removing container for $(@:%-container-rm=%)..."
	@$(MAKE) $(@:%-rm=%-stop)
	@$(LOCAL_DOCKER_COMPOSE) rm -f $(@:%-container-rm=%)
.PHONY: $(VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=%-container-rm)

$(VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=%-container-rm-ci): 
	@echo "🗑️  Removing container for $(@:%-container-rm-ci=%)..."
	@echo $(MAKE) $(@:%-rm-ci=%-stop)
	@echo $(LOCAL_DOCKER_COMPOSE) rm -f $(@:%-container-rm-ci=%)
.PHONY: $(VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=%-container-rm-ci)

$(VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=%-container-start):
	@echo "▶️ Starting $(@:%-container-start=%)..."
	@-$(LOCAL_DOCKER_COMPOSE) start $(@:%-container-start=%) 2>/dev/null
.PHONY: $(VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=%-container-start)

$(VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=%-container-stop):
	@echo "🛑 Stopping container for $(@:%-container-stop=%)..."
	@-$(LOCAL_DOCKER_COMPOSE) stop $(@:%-container-stop=%) 2>/dev/null
.PHONY: $(VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=%-container-stop)

$(VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=%-container-logs):
	@echo "🗒️ Showing logs for $(@:%-container-logs=%)..."
	@$(LOCAL_DOCKER_COMPOSE) logs $(@:%-container-logs=%)
.PHONY: $(VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=%-container-logs)

$(VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=%-container-logs-f):
	@echo "📝 Following logs for $(@:%-container-logs-f=%)..."
	@$(LOCAL_DOCKER_COMPOSE) logs --follow $(@:%-container-logs-f=%)
.PHONY: $(VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=%-container-logs-f)

$(VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=%-container-sh):
	@echo "💻 Opening bash shell for $(@:%-container-sh=%)..."
	@$(LOCAL_DOCKER_COMPOSE) exec -it $(@:%-container-sh=%) bash
.PHONY: $(VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=%-container-sh)

$(VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=%-image-pull):
	@echo Pulling the container image for $(@:%-image-pull=%)
	$(LOCAL_DOCKER_COMPOSE) pull $(@:%-image-pull=%)
.PHONY: $(VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=%-image-pull)

example-application-docker-compose-images-pull: $(VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=%-image-pull)
.PHONY: example-application-docker-compose-images-pull

example-application-docker-images-pull: 
	@$(MAKE) -j example-application-docker-compose-images-pull
.PHONY: example-application-docker-images-pull

example-application-docker-images-pull-parallel: 
	@echo Pulling all application images in parallel...
	@$(MAKE) -j example-application-docker-images-pull
.PHONY: example-application-docker-images-pull-parallel

$(VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=example-application-%-image-push):
	@echo Pushing the container image for $(@:%-image-push=%)
	@$(LOCAL_DOCKER_COMPOSE) push $(@:%-image-push=%)
.PHONY: $(VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=example-application-%-image-push)

example-application-docker-compose-images-push: $(VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=example-application-%-image-push)
.PHONY: example-application-docker-compose-images-push

example-application-docker-images-push: 
	@$(MAKE) -j example-application-docker-compose-images-push
.PHONY: example-application-docker-images-push

LOCAL_CONTAINERS_GROUP_OPERATIONS_CI := up rm logs

$(LOCAL_CONTAINERS_GROUP_OPERATIONS_CI:%=example-application-containers-%-ci): local-dev-container-image-pull
	@echo "Running operation 'example-application-containers-$(@:example-application-containers-%-ci=%)' for all local containers in CI..."
	@echo "Using builder image: $(LOCAL_BUILDER_IMAGE_VERSION)"
	@LOCAL_BUILDER_IMAGE=$(LOCAL_BUILDER_IMAGE_VERSION) \
	  LOCAL_ANDROID_GPU_MODE=swiftshader_indirect \
	  $(LOCAL_DEV_CONTAINER_RUN) \
	    make example-application-containers-$(@:example-application-containers-%-ci=%) \
	      LOCAL_ANDROID_CONTAINER_NAME=$(LOCAL_ANDROID_CONTAINER_NAME) \
	      VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE=$(VEGITO_LOCAL_PUBLIC_IMAGES_BASE):example-application-backend-$(VERSION) \
	      VEGITO_EXAMPLE_APPLICATION_MOBILE_IMAGE=$(VEGITO_LOCAL_PUBLIC_IMAGES_BASE):example-application-mobile-$(VERSION)
.PHONY: $(LOCAL_CONTAINERS_GROUP_OPERATIONS_CI:%=example-application-containers-%-ci)

example-application-docker-images-push-parallel: 
	@echo Pushing all application images in parallel...
	@$(MAKE) -j example-application-docker-images-push
.PHONY: example-application-docker-images-push-parallel

example-application-docker-group-tags-list-ci: 
	@echo "Listing all tags for example-application docker images in CI..." >&2
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print example-application-ci | jq -r '.target | to_entries[] | .value.tags[]'
.PHONY: example-application-docker-group-tags-list-ci
