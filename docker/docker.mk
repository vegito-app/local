REGISTRY = $(GOOGLE_CLOUD_REGION)-docker.pkg.dev

PUBLIC_REPOSITORY = $(REGISTRY)/$(GOOGLE_CLOUD_PROJECT_ID)/docker-repository-public
PUBLIC_IMAGES_BASE = $(PUBLIC_REPOSITORY)/$(GOOGLE_CLOUD_PROJECT_ID)

REPOSITORY = $(REGISTRY)/$(GOOGLE_CLOUD_PROJECT_ID)/docker-repository-private
IMAGES_BASE = $(REPOSITORY)/$(GOOGLE_CLOUD_PROJECT_ID)

# DOCKER_VERSION = 28.0.2

DOCKER_BUILDX_BAKE = docker buildx bake \
	-f application/backend/docker-bake.hcl \
	-f docker/docker-bake.hcl \
	-f clarinet/docker-bake.hcl \
	-f dev/docker-bake.hcl \
	-f android-studio/docker-bake.hcl \
	-f firebase/emulators/docker-bake.hcl \
	-f infra/github/docker-bake.hcl 

DOCKER_BUILDX_TARGETS := \
	backend \
	android-studio \
	github-runner

docker-images-ci-multi-arch: docker-buildx-setup dev-builder-image-ci
	@$(DOCKER_BUILDX_BAKE) --print services-push-multi-arch
	@$(DOCKER_BUILDX_BAKE) --push services-push-multi-arch
.PHONY: docker-images-ci-multi-arch

docker-images-local-arch: dev-builder-image
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
