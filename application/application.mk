LOCAL_APPLICATION_DIR ?= $(CURDIR)/application

-include $(LOCAL_APPLICATION_DIR)/frontend/frontend.mk
-include $(LOCAL_APPLICATION_DIR)/backend/backend.mk
-include $(LOCAL_APPLICATION_DIR)/mobile/mobile.mk

APPLICATION_DOCKER_BUILDX_BAKE_IMAGES := \
  backend \
  mobile

local-application-docker-images:
	@$(MAKE) -j $(APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:%=local-application-%-image)
.PHONY: local-application-docker-images

$(APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:%=local-application-%-image): docker-buildx-setup
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:%-image=%)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --load $(@:%-image=%)
.PHONY: $(APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:%=local-application-%-image)

local-application-docker-images-ci:
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print local-application-ci
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push local-application-ci
.PHONY: local-application-docker-images-ci

$(APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:%=local-application-%-image-ci): docker-buildx-setup
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:%-image-ci=%-ci)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push $(@:%-image-ci=%-ci)
.PHONY: $(APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:%=local-application-%-image-ci)

LOCAL_APPLICATION_DOCKER_COMPOSE_SERVICES ?= \
  backend \
  mobile

local-application-containers-rm: $(LOCAL_APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-application-%-container-rm)
.PHONY: local-application-containers-rm

# local-application-containers-rm-ci: $(LOCAL_APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-application-%-container-rm-ci)
# .PHONY: local-application-containers-rm-ci

local-application-containers-up: $(LOCAL_APPLICATION_DOCKER_COMPOSE_SERVICES:%=application-%)
.PHONY: local-application-containers-up

$(LOCAL_APPLICATION_DOCKER_COMPOSE_SERVICES:%=application-%):
	@echo "Starting container for application service $(@:application-%=local-%-container-up)"
	@$(MAKE) $(@:%=local-%-container-up)
.PHONY: $(LOCAL_APPLICATION_DOCKER_COMPOSE_SERVICES:%=application-%)

LOCAL_APPLICATION_DOCKER_COMPOSE_SERVICES_CI ?= \
  application-backend \
  application-mobile

# LOCAL_BUILDER_CONTAINER_DOCKER_COMPOSE_NAME = dev

# LOCAL_BUILDER_CONTAINER_RUN = $(LOCAL_DOCKER_COMPOSE) run --rm $(LOCAL_BUILDER_CONTAINER_DOCKER_COMPOSE_NAME)

# LOCAL_CONTAINERS_OPERATIONS_CI = up rm

$(LOCAL_CONTAINERS_OPERATIONS_CI:%=local-application-containers-%-ci): local-project-builder-image-pull
	@echo "Running operation 'local-application-containers-$(@:local-application-containers-%-ci=%)' for all local containers in CI..."
	@echo "Using builder image: $(LOCAL_BUILDER_IMAGE_VERSION)"
	LOCAL_BUILDER_IMAGE=$(LOCAL_BUILDER_IMAGE_VERSION) \
	  $(LOCAL_BUILDER_CONTAINER_RUN) \
	    make local-application-containers-$(@:local-application-containers-%-ci=%) \
	      LOCAL_ANDROID_CONTAINER_NAME=application-mobile \
	      LOCAL_APPLICATION_BACKEND_IMAGE=$(VEGITO_LOCAL_PUBLIC_IMAGES_BASE):application-backend-$(VERSION) \
	      LOCAL_APPLICATION_MOBILE_IMAGE=$(VEGITO_LOCAL_PUBLIC_IMAGES_BASE):application-mobile-$(VERSION)
.PHONY: $(LOCAL_CONTAINERS_OPERATIONS_CI:%=local-application-containers-%-ci)

$(LOCAL_APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-application-%-container-rm): 
	@echo "Removing container for $(@:local-%-container-rm=%)"
	@$(MAKE) $(@:%-rm=%-stop)
	$(LOCAL_DOCKER_COMPOSE) rm -f $(@:local-%-container-rm=%)
.PHONY: $(LOCAL_APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-application-%-container-rm)

$(LOCAL_APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-application-%-container-rm-ci): 
	@echo "Removing container for $(@:local-%-container-rm-ci=%)"
	echo $(MAKE) $(@:%-rm-ci=%-stop)
	echo $(LOCAL_DOCKER_COMPOSE) rm -f $(@:local-%-container-rm-ci=%)
.PHONY: $(LOCAL_APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-application-%-container-rm-ci)

$(LOCAL_APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-application-%-container-start):
	@echo "Starting container for $(@:local-%-container-start=%)"
	@-$(LOCAL_DOCKER_COMPOSE) start $(@:local-%-container-start=%) 2>/dev/null
.PHONY: $(LOCAL_APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-application-%-container-start)

$(LOCAL_APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-application-%-container-stop):
	@echo "Stopping container for $(@:local-%-container-stop=%)"
	@-$(LOCAL_DOCKER_COMPOSE) stop $(@:local-%-container-stop=%) 2>/dev/null
.PHONY: $(LOCAL_APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-application-%-container-stop)

$(LOCAL_APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-application-%-container-logs):
	@echo "Viewing container logs for $(@:local-%-container-logs=%)"
	@$(LOCAL_DOCKER_COMPOSE) logs $(@:local-%-container-logs=%)
.PHONY: $(LOCAL_APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-application-%-container-logs)

$(LOCAL_APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-application-%-container-logs-f):
	@echo "Following container logs for $(@:local-%-container-logs-f=%)"
	@$(LOCAL_DOCKER_COMPOSE) logs --follow $(@:local-%-container-logs-f=%)
.PHONY: $(LOCAL_APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-application-%-container-logs-f)

$(LOCAL_APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-application-%-container-sh):
	@echo "Opening container shell for $(@:local-%-container-sh=%)"
	@$(LOCAL_DOCKER_COMPOSE) exec -it $(@:local-%-container-sh=%) bash
.PHONY: $(LOCAL_APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-application-%-container-sh)

$(LOCAL_APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-application-%-image-pull):
	@echo Pulling the container image for $(@:local-%-image-pull=%)
	@$(LOCAL_DOCKER_COMPOSE) pull $(@:local-%-image-pull=%)
.PHONY: $(LOCAL_APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-application-%-image-pull)

local-application-dockercompose-images-pull: $(LOCAL_APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-application-%-image-pull)
.PHONY: local-application-dockercompose-images-pull

local-application-docker-images-pull: 
	@$(MAKE) -j local-application-dockercompose-images-pull
.PHONY: local-application-docker-images-pull

local-application-docker-images-pull-parallel: 
	@echo Pulling all application images in parallel...
	@$(MAKE) -j local-application-docker-images-pull
.PHONY: local-application-docker-images-pull-parallel

$(LOCAL_APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-application-%-image-push):
	@$(LOCAL_DOCKER_COMPOSE) push $(@:local-%-image-push=%)
.PHONY: $(LOCAL_APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-application-%-image-push)

local-application-dockercompose-images-push: $(LOCAL_APPLICATION_DOCKER_COMPOSE_SERVICES:%=local-application-%-image-push)
.PHONY: local-application-dockercompose-images-push

local-application-docker-images-push: 
	@$(MAKE) -j local-application-dockercompose-images-push
.PHONY: local-application-docker-images-push

local-application-docker-images-push-parallel: 
	@echo Pushing all application images in parallel...
	@$(MAKE) -j local-application-docker-images-push
.PHONY: local-application-docker-images-push-parallel

