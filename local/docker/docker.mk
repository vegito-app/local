REGISTRY = $(GOOGLE_CLOUD_REGION)-docker.pkg.dev

PUBLIC_REPOSITORY = $(REGISTRY)/$(GOOGLE_CLOUD_PROJECT_ID)/docker-repository-public
PUBLIC_IMAGES_BASE = $(PUBLIC_REPOSITORY)/$(GOOGLE_CLOUD_PROJECT_ID)

REPOSITORY = $(REGISTRY)/$(GOOGLE_CLOUD_PROJECT_ID)/docker-repository-private
IMAGES_BASE = $(REPOSITORY)/$(GOOGLE_CLOUD_PROJECT_ID)

DOCKER_BUILDX_BAKE = docker buildx bake \
	-f local/docker/docker-bake.hcl \
	-f local/docker-bake.hcl \
	-f application/backend/docker-bake.hcl \
	-f local/clarinet/docker-bake.hcl \
	-f local/android-studio/docker-bake.hcl \
	-f local/firebase-emulators/docker-bake.hcl \
	-f local/github/docker-bake.hcl \
	-f local/vault/docker-bake.hcl 

docker-images-ci-multi-arch: docker-buildx-setup local-builder-image-ci
	@$(DOCKER_BUILDX_BAKE) --print services-push-multi-arch
	@$(DOCKER_BUILDX_BAKE) --push services-push-multi-arch
.PHONY: docker-images-ci-multi-arch

docker-images-local-arch: local-builder-image
	@$(DOCKER_BUILDX_BAKE) --print services-load-local-arch
	@$(DOCKER_BUILDX_BAKE) --load services-load-local-arch
.PHONY: docker-images-local-arch

docker-buildx-setup: 
	@-docker buildx create --name $(GOOGLE_CLOUD_PROJECT_ID)-builder 2>/dev/null 
	@-docker buildx use $(GOOGLE_CLOUD_PROJECT_ID)-builder 2>/dev/null 
.PHONY: docker-buildx-setup

docker-login: gcloud-auth-docker
	@docker login $(REGISTRY)/$(GOOGLE_CLOUD_PROJECT_ID)
.PHONY: docker-login

docker-sock:
	sudo chmod o+rw /var/run/docker.sock
.PHONY: docker-sock

DEV_DOCKER_COMPOSE_SERVICES = \
  android-studio \
  application-backend \
  vault \
  firebase-emulators \
  clarinet-devnet

local-docker-compose: $(DEV_DOCKER_COMPOSE_SERVICES)
.PHONY: local-docker-compose

local-docker-compose-rm: $(DEV_DOCKER_COMPOSE_SERVICES:%=%-docker-compose-rm)
.PHONY: local-docker-compose-rm

$(DEV_DOCKER_COMPOSE_SERVICES):
	@$(MAKE) $(@:%=%-docker-compose-up)
.PHONY: $(DEV_DOCKER_COMPOSE_SERVICES)

$(DEV_DOCKER_COMPOSE_SERVICES:%=%-docker-compose-rm): 
	@$(MAKE) $(@:%-rm=%-stop)
	@$(DOCKER_COMPOSE) rm -f $(@:%-docker-compose-rm=%)
.PHONY: $(DEV_DOCKER_COMPOSE_SERVICES:%=%-docker-compose-rm))

$(DEV_DOCKER_COMPOSE_SERVICES:%=%-image): docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print $(@:%-image=%)
	@$(DOCKER_BUILDX_BAKE) --load $(@:%-image=%)
.PHONY: $(DEV_DOCKER_COMPOSE_SERVICES:%=%-image)

$(DEV_DOCKER_COMPOSE_SERVICES:%=%-image-push): docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print $(@:%-image-push=%)
	@$(DOCKER_BUILDX_BAKE) --push $(@:%-image-push=%)
.PHONY: $(DEV_DOCKER_COMPOSE_SERVICES:%=%-image-push)

$(DEV_DOCKER_COMPOSE_SERVICES:%=%-image-ci): docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print $(@:%-image-ci=%-ci)
	@$(DOCKER_BUILDX_BAKE) --push $(@:%-image-ci=%-ci)
.PHONY: $(DEV_DOCKER_COMPOSE_SERVICES:%=%-image-ci)

$(DEV_DOCKER_COMPOSE_SERVICES:%=%-docker-compose-start):
	@-$(DOCKER_COMPOSE) start $(@:%-docker-compose-start=%) 2>/dev/null
.PHONY: $(DEV_DOCKER_COMPOSE_SERVICES:%=%-docker-compose-start)

$(DEV_DOCKER_COMPOSE_SERVICES:%=%-docker-compose-stop):
	@-$(DOCKER_COMPOSE) stop $(@:%-docker-compose-stop=%) 2>/dev/null
.PHONY: $(DEV_DOCKER_COMPOSE_SERVICES:%=%-docker-compose-stop)

$(DEV_DOCKER_COMPOSE_SERVICES:%=%-docker-compose-logs):
	@$(DOCKER_COMPOSE) logs --follow $(@:%-docker-compose-logs=%)
.PHONY: $(DEV_DOCKER_COMPOSE_SERVICES:%=%-docker-compose-logs)

$(DEV_DOCKER_COMPOSE_SERVICES:%=%-docker-compose-sh):
	@$(DOCKER_COMPOSE) exec -it $(@:%-docker-compose-sh=%) bash
.PHONY: $(DEV_DOCKER_COMPOSE_SERVICES:%=%-docker-compose-sh)
