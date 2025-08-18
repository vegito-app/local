GOOGLE_CLOUD_REGION ?= europe-west1
REGISTRY ?= $(GOOGLE_CLOUD_REGION)-docker.pkg.dev
LOCAL_IMAGES_BASE ?= vegito-local
LOCAL_DOCKER_BUILDX_NAME ?= vegito-project-builder

VEGITO_PUBLIC_REPOSITORY ?= $(REGISTRY)/$(GOOGLE_CLOUD_PROJECT_ID)/docker-repository-public
VEGITO_LOCAL_PUBLIC_IMAGES_BASE ?= $(VEGITO_PUBLIC_REPOSITORY)/$(LOCAL_IMAGES_BASE)

VEGITO_PRIVATE_REPOSITORY ?= $(REGISTRY)/$(GOOGLE_CLOUD_PROJECT_ID)/docker-repository-private

docker-buildx-setup: 
	@-docker buildx create --name $(LOCAL_DOCKER_BUILDX_NAME) 2>/dev/null 
	@-docker buildx use $(LOCAL_DOCKER_BUILDX_NAME) 2>/dev/null 
.PHONY: docker-buildx-setup

docker-login: gcloud-auth-docker
	@docker login $(REGISTRY)/$(GOOGLE_CLOUD_PROJECT_ID)
.PHONY: docker-login

docker-sock:
	sudo chmod o+rw /var/run/docker.sock
.PHONY: docker-sock
