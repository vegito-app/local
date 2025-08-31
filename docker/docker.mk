GOOGLE_CLOUD_REGION ?= europe-west1
GOOGLE_CLOUD_DOCKER_REGISTRY ?= $(GOOGLE_CLOUD_REGION)-docker.pkg.dev
VEGITO_LOCAL_IMAGES_BASE ?= vegito-local

VEGITO_LOCAL_PUBLIC_REPOSITORY ?= $(GOOGLE_CLOUD_DOCKER_REGISTRY)/$(GOOGLE_CLOUD_PROJECT_ID)/docker-repository-public
VEGITO_LOCAL_PUBLIC_IMAGES_BASE ?= $(VEGITO_LOCAL_PUBLIC_REPOSITORY)/$(VEGITO_LOCAL_IMAGES_BASE)

VEGITO_LOCAL_PRIVATE_REPOSITORY ?= $(GOOGLE_CLOUD_DOCKER_REGISTRY)/$(GOOGLE_CLOUD_PROJECT_ID)/docker-repository-private

docker-login: gcloud-auth-docker
	@docker login $(GOOGLE_CLOUD_DOCKER_REGISTRY)/$(GOOGLE_CLOUD_PROJECT_ID)
.PHONY: docker-login

docker-sock:
	sudo chmod o+rw /var/run/docker.sock
.PHONY: docker-sock

docker-clean: 
	@docker system prune --all --force
.PHONY: docker-clean

LOCAL_DOCKER_BUILDX_NAME ?= vegito-project-builder
LOCAL_DOCKER_BUILDX_ARM_BUILDER_SSH_HOST ?= container.mac-m1.local
LOCAL_DOCKER_BUILDX_ARM_BUILDER_NAME ?= mac-m1

# Ajout d'un context docker distant pour le Mac
docker-context-arm:
	@docker context inspect $(LOCAL_DOCKER_BUILDX_ARM_BUILDER_NAME) >/dev/null 2>&1 || \
	docker context create $(LOCAL_DOCKER_BUILDX_ARM_BUILDER_NAME) --docker "host=ssh://$(LOCAL_DOCKER_BUILDX_ARM_BUILDER_SSH_HOST)"
.PHONY: docker-context-arm

docker-context-arm-rm:
	@docker context rm $(LOCAL_DOCKER_BUILDX_ARM_BUILDER_NAME) || true
.PHONY: docker-context-arm-rm

docker-clean-all:
	@$(MAKE) -j \
	  docker-clean \
	  docker-buildx-clean \
	  docker-local-buildx-cache-clean
.PHONY: docker-clean-all

docker-buildx-setup: #docker-context-arm
	@-docker buildx create --name $(LOCAL_DOCKER_BUILDX_NAME) --driver docker-container --use --platform linux/amd64
# 	@-docker buildx create --name $(LOCAL_DOCKER_BUILDX_NAME) --append $(LOCAL_DOCKER_BUILDX_ARM_BUILDER_NAME) --platform linux/arm64
	@-docker buildx inspect --bootstrap
.PHONY: docker-buildx-setup

docker-buildx-rm:
	@-docker buildx rm $(LOCAL_DOCKER_BUILDX_NAME)
.PHONY: docker-buildx-rm

docker-buildx-clean:
	@docker buildx prune --all --force
.PHONY: docker-buildx-clean

docker-local-buildx-cache-clean: 
	@echo "🧹 Cleaning up Docker Buildx cache..."
	@bash -c '\
	  for i in `find . -name "docker-local-buildx-cache" -type d` ; do \
	    echo $$i ; \
	    echo Removing $$(du -sh $$i) ; \
		rm -rf $$i
	  done \
	'
.PHONY: docker-local-buildx-cache-clean