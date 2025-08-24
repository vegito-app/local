GOOGLE_CLOUD_REGION ?= europe-west1
REGISTRY ?= $(GOOGLE_CLOUD_REGION)-docker.pkg.dev
LOCAL_IMAGES_BASE ?= vegito-local
LOCAL_DOCKER_BUILDX_NAME ?= vegito-project-builder

VEGITO_PUBLIC_REPOSITORY ?= $(REGISTRY)/$(GOOGLE_CLOUD_PROJECT_ID)/docker-repository-public
VEGITO_LOCAL_PUBLIC_IMAGES_BASE ?= $(VEGITO_PUBLIC_REPOSITORY)/$(LOCAL_IMAGES_BASE)

VEGITO_PRIVATE_REPOSITORY ?= $(REGISTRY)/$(GOOGLE_CLOUD_PROJECT_ID)/docker-repository-private

docker-login: gcloud-auth-docker
	@docker login $(REGISTRY)/$(GOOGLE_CLOUD_PROJECT_ID)
.PHONY: docker-login

docker-sock:
	sudo chmod o+rw /var/run/docker.sock
.PHONY: docker-sock

docker-clean:
	@docker system prune --all --force
.PHONY: docker-clean

docker-buildx-setup: 
	@-docker buildx create --name $(LOCAL_DOCKER_BUILDX_NAME) 2>/dev/null 
	@-docker buildx use $(LOCAL_DOCKER_BUILDX_NAME) 2>/dev/null 
.PHONY: docker-buildx-setup

docker-buildx-clean:
	@docker buildx prune --all --force
.PHONY: docker-buildx-clean

docker-buildx-cache-clean: 
	@echo "🧹 Cleaning up Docker Buildx cache..."
	@bash -c '\
	  for i in `find . -name "docker-buildx-cache" -type d` ; do \
	    echo $$i ; \
	    echo Removing $$(du -sh $$i) ; \
		rm -rf $$i
	  done \
	'
.PHONY: docker-buildx-cache-clean