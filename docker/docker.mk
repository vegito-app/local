GOOGLE_CLOUD_REGION ?= europe-west1
GOOGLE_CLOUD_DOCKER_REGISTRY ?= $(GOOGLE_CLOUD_REGION)-docker.pkg.dev
LOCAL_IMAGES_BASE ?= $(GOOGLE_CLOUD_PROJECT_ID)
LOCAL_DOCKER_BUILDX_NAME ?= vegito-project-builder

PUBLIC_REPOSITORY ?= $(GOOGLE_CLOUD_DOCKER_REGISTRY)/$(GOOGLE_CLOUD_PROJECT_ID)/docker-repository-public
PUBLIC_IMAGES_BASE ?= $(PUBLIC_REPOSITORY)/$(LOCAL_IMAGES_BASE)

PRIVATE_REPOSITORY ?= $(GOOGLE_CLOUD_DOCKER_REGISTRY)/$(GOOGLE_CLOUD_PROJECT_ID)/docker-repository-private
PRIVATE_IMAGES_BASE ?= $(PRIVATE_REPOSITORY)/$(LOCAL_IMAGES_BASE)

docker-buildx-setup: 
	@-docker buildx create --name $(LOCAL_DOCKER_BUILDX_NAME) 2>/dev/null 
	@-docker buildx use $(LOCAL_DOCKER_BUILDX_NAME) 2>/dev/null 
.PHONY: docker-buildx-setup

docker-login: gcloud-auth-docker
	@docker login $(GOOGLE_CLOUD_DOCKER_REGISTRY)/$(GOOGLE_CLOUD_PROJECT_ID)
.PHONY: docker-login

docker-sock:
	sudo chmod o+rw /var/run/docker.sock
.PHONY: docker-sock
