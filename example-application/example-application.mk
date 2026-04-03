VEGITO_EXAMPLE_APPLICATION_DIR ?= $(CURDIR)

VEGITO_EXAMPLE_APPLICATION_PUBLIC_IMAGES_BASE ?= $(VEGITO_PUBLIC_REPOSITORY)/example-application

-include $(VEGITO_EXAMPLE_APPLICATION_DIR)/frontend/frontend.mk
-include $(VEGITO_EXAMPLE_APPLICATION_DIR)/backend/backend.mk
-include $(VEGITO_EXAMPLE_APPLICATION_DIR)/mobile/mobile.mk
-include $(VEGITO_EXAMPLE_APPLICATION_DIR)/tests/tests.mk

VEGITO_EXAMPLE_APPLICATION_DOTENV_FILE ?= $(VEGITO_EXAMPLE_APPLICATION_DIR)/.env

example-application-dotenv: $(VEGITO_EXAMPLE_APPLICATION_DOTENV_FILE)
.PHONY: example-application-dotenv

$(VEGITO_EXAMPLE_APPLICATION_DOTENV_FILE):
	@echo "📝 Generating .env file for local development..."
	@$(VEGITO_EXAMPLE_APPLICATION_DIR)/dotenv.sh
	@echo ".env file generated at $@"

EXAMPLE_APPLICATION_DOCKER_BUILDX_BAKE_IMAGES_GROUPS ?= \
  builders \
  services \
  applications

example-application-docker-images-host-arch: $(EXAMPLE_APPLICATION_DOCKER_BUILDX_BAKE_IMAGES_GROUPS:%=vegito-example-application-%)
.PHONY: example-application-docker-images-host-arch

$(EXAMPLE_APPLICATION_DOCKER_BUILDX_BAKE_IMAGES_GROUPS:%=example-application-%): local-docker-buildx-setup
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:%=vegito-%)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push $(@:%=vegito-%)
.PHONY: $(EXAMPLE_APPLICATION_DOCKER_BUILDX_BAKE_IMAGES_GROUPS:%=example-application-%)

EXAMPLE_APPLICATION_DOCKER_BUILDX_BAKE_IMAGES_GROUPS_CI ?= \
  builders \
  services \
  applications

$(EXAMPLE_APPLICATION_DOCKER_BUILDX_BAKE_IMAGES_GROUPS_CI:%=vegito-example-application-%-ci): local-docker-buildx-setup
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $@
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push $@
.PHONY: $(EXAMPLE_APPLICATION_DOCKER_BUILDX_BAKE_IMAGES_GROUPS_CI:%=vegito-example-application-%-ci)

example-application-docker-images-multi-arch: $(EXAMPLE_APPLICATION_DOCKER_BUILDX_BAKE_IMAGES_GROUPS_CI:%=vegito-example-application-%-ci)
.PHONY: example-application-docker-images-multi-arch

EXAMPLE_APPLICATION_DOCKER_BUILDX_BAKE_IMAGES ?= \
  backend \
  mobile \
  tests

example-application-docker-images: $(EXAMPLE_APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:%=example-application-%-image)
.PHONY: example-application-docker-images

$(EXAMPLE_APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:%=example-application-%-image): local-docker-buildx-setup
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:%-image=vegito-%)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --load $(@:%-image=vegito-%)
.PHONY: $(EXAMPLE_APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:%=example-application-%-image)

example-application-docker-images-ci: $(EXAMPLE_APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:%=example-application-%-image-ci)
.PHONY: example-application-docker-images-ci

$(EXAMPLE_APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:%=example-application-%-image-ci): local-docker-buildx-setup
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:%-image-ci=vegito-%-ci)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push $(@:%-image-ci=vegito-%-ci)
.PHONY: $(EXAMPLE_APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:%=example-application-%-image-ci)

example-application-release-ci:
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print vegito-example-application-release-ci
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push vegito-example-application-release-ci
.PHONY: example-application-release-ci

example-application-docker-tags-list-ci: $(EXAMPLE_APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:%=example-application-%-docker-tags-list-ci)
.PHONY: example-application-docker-tags-list-ci

$(EXAMPLE_APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:%=example-application-%-docker-tags-ci): local-docker-buildx-setup
	@$($(LOCAL_DOCKER_BUILDX_BAKE)) --print $(@:vegito-%-docker-tags=%-ci) 2>/dev/null \
	| jq -r '.target | to_entries[] | .value.tags[]'
.PHONY: $(EXAMPLE_APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:%=example-application-%-docker-group-tags-ci)

example-application-docker-scan-tags-ci: $(EXAMPLE_APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:%=example-application-%-docker-scan-tags-ci)
.PHONY: example-application-docker-scan-tags-ci

$(EXAMPLE_APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:%=example-application-%-docker-scan-tags-ci): local-docker-buildx-setup
	@echo "Running Trivy scan for image: $(VEGITO_LOCAL_PUBLIC_IMAGES_BASE):$(@:%-docker-scan-tags-ci=%)-$(VERSION)"
	@echo "Report: $(@:%-docker-scan-tags-ci=%)-$(VERSION)-trivy-report.html"
	@$(MAKE) local-trivy-image-scan \
	  LOCAL_TRIVY_IMAGE_SCAN_INPUT=$(VEGITO_LOCAL_PUBLIC_IMAGES_BASE):$(@:%-docker-scan-tags-ci=%)-$(VERSION) \
	  LOCAL_TRIVY_IMAGE_SCAN_OUTPUT_REPORT_HTML=$(@:%-docker-scan-tags-ci=%)-$(VERSION)-trivy-report.html
.PHONY: $(EXAMPLE_APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:%=example-application-%-docker-group-tags-ci)

VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES ?= \
  backend \
  mobile \
  tests

example-application-containers-rm: $(VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=example-application-%-container-rm)
.PHONY: example-application-containers-rm

example-application-containers-up: $(VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=example-application-%-container-up)
.PHONY: example-application-containers-up

$(VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES):
	@$(MAKE) $(@:%=example-application-%-container-up)
.PHONY: $(VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES)

$(VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=example-application-%-container-up-ci): local-dev-container-image-pull
	@echo "Running operation 'example-application-containers-$(@:example-application-containers-%-container-up-ci=%)' for all local containers in CI..."
	@echo "Using builder image: $(LOCAL_BUILDER_IMAGE_VERSION)"
	@LOCAL_BUILDER_IMAGE=$(LOCAL_BUILDER_IMAGE_VERSION) \
	  LOCAL_ANDROID_GPU_MODE=swiftshader_indirect \
	  $(LOCAL_DEV_CONTAINER_RUN_CI) \
	    make $(@:%-ci=%) \
	      VERSION=$(VERSION)
.PHONY: $(VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=example-application-%-container-up-ci)

example-application-containers-logs: $(VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=example-application-%-container-logs)
.PHONY: example-application-containers-logs

$(VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=example-application-%-container-rm):
	@echo "🗑️ Removing container for $(@:%-container-rm=%)..."
	@$(MAKE) $(@:%-rm=%-stop)
	@$(LOCAL_DOCKER_COMPOSE) rm -f $(@:%-container-rm=%)
.PHONY: $(VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=example-application-%-container-rm)

$(VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=example-application-%-container-rm-ci): 
	@echo "🗑️ Removing container for $(@:%-container-rm-ci=%)..."
	@echo $(MAKE) $(@:%-rm-ci=%-stop)
	@echo $(LOCAL_DOCKER_COMPOSE) rm -f $(@:%-container-rm-ci=%)
.PHONY: $(VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=example-application-%-container-rm-ci)

$(VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=example-application-%-container-start):
	@echo "▶️ Starting $(@:%-container-start=%)..."
	@-$(LOCAL_DOCKER_COMPOSE) start $(@:%-container-start=%) 2>/dev/null
.PHONY: $(VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=example-application-%-container-start)

$(VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=example-application-%-container-stop):
	@echo "🛑 Stopping container for $(@:%-container-stop=%)..."
	@-$(LOCAL_DOCKER_COMPOSE) stop $(@:%-container-stop=%) 2>/dev/null
.PHONY: $(VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=example-application-%-container-stop)

$(VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=example-application-%-container-logs):
	@echo "🗒️ Showing logs for $(@:%-container-logs=%)..."
	@$(LOCAL_DOCKER_COMPOSE) logs $(@:%-container-logs=%)
.PHONY: $(VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=example-application-%-container-logs)

$(VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=example-application-%-container-logs-f):
	@echo "📝 Following logs for $(@:%-container-logs-f=%)..."
	@$(LOCAL_DOCKER_COMPOSE) logs --follow $(@:%-container-logs-f=%)
.PHONY: $(VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=example-application-%-container-logs-f)

$(VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=example-application-%-container-sh):
	@echo "💻 Opening bash shell for $(@:%-container-sh=%)..."
	@$(LOCAL_DOCKER_COMPOSE) exec -it $(@:%-container-sh=%) bash
.PHONY: $(VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=example-application-%-container-sh)

$(VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=example-application-%-image-pull):
	@echo Pulling the container image for $(@:%-image-pull=%)
	@$(LOCAL_DOCKER_COMPOSE) pull $(@:%-image-pull=%)
.PHONY: $(VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=example-application-%-image-pull)

example-application-docker-compose-images-pull: $(VEGITO_EXAMPLE_APPLICATION_DOCKER_COMPOSE_SERVICES:%=example-application-%-image-pull)
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
	  $(LOCAL_DEV_CONTAINER_RUN_CI) \
	    make example-application-containers-$(@:example-application-containers-%-ci=%) \
	      VERSION=$(VERSION)
.PHONY: $(LOCAL_CONTAINERS_GROUP_OPERATIONS_CI:%=example-application-containers-%-ci)

example-application-docker-images-push-parallel: 
	@echo Pushing all application images in parallel...
	@$(MAKE) -j example-application-docker-images-push
.PHONY: example-application-docker-images-push-parallel

example-application-docker-group-tags-list-ci: 
	@echo "Listing all tags for example-application docker images in CI..." >&2
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print vegito-example-application-ci | jq -r '.target | to_entries[] | .value.tags[]'
.PHONY: example-application-docker-group-tags-list-ci
