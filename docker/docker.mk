REGISTRY = $(GOOGLE_CLOUD_REGION)-docker.pkg.dev

PUBLIC_REPOSITORY = $(REGISTRY)/$(GOOGLE_CLOUD_PROJECT_ID)/$(INFRA_ENV)-docker-repository-public
PUBLIC_IMAGES_BASE ?= $(PUBLIC_REPOSITORY)/$(GOOGLE_CLOUD_PROJECT_ID)

BUILDER_IMAGE ?= $(PUBLIC_IMAGES_BASE):builder-$(VERSION)
LATEST_BUILDER_IMAGE ?= $(PUBLIC_IMAGES_BASE):builder-latest

REPOSITORY = $(REGISTRY)/$(GOOGLE_CLOUD_PROJECT_ID)/$(INFRA_ENV)-docker-repository-private
IMAGES_BASE ?= $(REPOSITORY)/$(GOOGLE_CLOUD_PROJECT_ID)

DOCKER_BUILDX_BAKE = docker buildx bake \
	-f docker/docker-bake.hcl \
	-f application/backend/docker-bake.hcl  \
	-f local/docker-bake.hcl \
	-f local/android/docker-bake.hcl \
	-f infra/github/docker-bake.hcl 

DOCKER_BUILDX_TARGETS := \
	backend \
	android-studio \
	github-runner

docker-images-ci-multi-arch: docker-buildx-setup local-builder-image-ci
	@$(DOCKER_BUILDX_BAKE) --print services-push-multi-arch
	@$(DOCKER_BUILDX_BAKE) --push services-push-multi-arch
.PHONY: docker-images-ci-multi-arch

docker-images-local-arch: local-builder-image
	@$(DOCKER_BUILDX_BAKE) --print services-load-local-arch
	@$(DOCKER_BUILDX_BAKE) --load services-load-local-arch
.PHONY: docker-images-local-arch

docker-buildx-setup: $(GOOGLE_APPLICATION_CREDENTIALS)
	@-docker buildx create --name $(GOOGLE_CLOUD_PROJECT_ID)-builder 2>/dev/null 
	@-docker buildx use $(GOOGLE_CLOUD_PROJECT_ID)-builder 2>/dev/null 
.PHONY: docker-buildx-setup

docker-login: gcloud-auth-docker
	@docker login $(REGISTRY)/$(GOOGLE_CLOUD_PROJECT_ID)
.PHONY: docker-login

docker-sock:
	sudo chmod o+rw /var/run/docker.sock
.PHONY: docker-sock
