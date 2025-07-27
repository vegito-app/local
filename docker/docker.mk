GOOGLE_CLOUD_REGION ?= europe-west1
REGISTRY ?= $(GOOGLE_CLOUD_REGION)-docker.pkg.dev
LOCAL_IMAGES_BASE ?= $(GOOGLE_CLOUD_PROJECT_ID)

PUBLIC_REPOSITORY ?= $(REGISTRY)/$(GOOGLE_CLOUD_PROJECT_ID)/docker-repository-public
PUBLIC_IMAGES_BASE ?= $(PUBLIC_REPOSITORY)/$(LOCAL_IMAGES_BASE)

PRIVATE_REPOSITORY ?= $(REGISTRY)/$(GOOGLE_CLOUD_PROJECT_ID)/docker-repository-private
PRIVATE_IMAGES_BASE ?= $(PRIVATE_REPOSITORY)/$(LOCAL_IMAGES_BASE)

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
