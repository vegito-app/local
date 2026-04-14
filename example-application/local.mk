# Version of the vegito-app/local development environment images to use:
LOCAL_VERSION ?= v1.20.1
# ------------------------------------------
# Subtree ./local
# ___________________________________________
#
# This section manages the local subtree, which contains local development tools and configurations.
# It allows for pulling and pushing changes to a separate local repository.
#------------------------------------------
git-subtree-local-pull:
	@echo "⬇︎ Pulling the local subtree..."
	@git subtree pull --prefix local \
	  git@github.com:vegito-app/local.git $(LOCAL_VERSION) --squash
	@echo "Local subtree pulled successfully."
.PHONY: git-subtree-local-pull

git-subtree-local-push:
	@echo "⬆︎ Pushing changes from the local subtree..."
	@git subtree push --prefix local \
	  git@github.com:vegito-app/local.git $(VEGITO_APP_GIT_SUBTREE_REMOTE_BRANCH)
	@echo "Local subtree pushed successfully."
.PHONY: git-subtree-local-push
# ------------------------------------------

LOCAL_DIR ?= $(CURDIR)/local

LOCAL_GO_MODULES ?= \
	$(LOCAL_FIREBASE_EMULATORS_AUTH_FUNCTIONS_DIR) \
	proxy \
	$(VEGITO_EXAMPLE_APPLICATION_BACKEND_DIR)


LOCAL_GO_MODULES = \
LOCAL_ROBOTFRAMEWORK_IMAGE_VERSION ?= $(VEGITO_LOCAL_PUBLIC_IMAGES_BASE):robotframework-$(LOCAL_VERSION)
LOCAL_ROBOTFRAMEWORK_TESTS_DIR ?= $(VEGITO_EXAMPLE_APPLICATION_TESTS_DIR)
LOCAL_BUILDER_IMAGE_VERSION=$(VEGITO_LOCAL_PUBLIC_IMAGES_BASE):builder-${LOCAL_VERSION}

LOCAL_DOCKER_BUILDX_BAKE = docker buildx bake \
	-f $(LOCAL_DIR)/docker/docker-bake.hcl \
	-f $(LOCAL_DIR)/docker-bake.hcl \
	$(LOCAL_DOCKER_BUILDX_BAKE_IMAGES:%=-f $(LOCAL_DIR)/%/docker-bake.hcl) \
	-f $(LOCAL_ANDROID_DIR)/docker-bake.hcl \
	$(LOCAL_ANDROID_DOCKER_BUILDX_BAKE_IMAGES:%=-f $(LOCAL_ANDROID_DIR)/%/docker-bake.hcl) \
	-f $(CURDIR)/docker-bake.hcl \
	-f $(VEGITO_EXAMPLE_APPLICATION_DIR)/docker-bake.hcl \
	$(EXAMPLE_APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:%=-f $(VEGITO_EXAMPLE_APPLICATION_DIR)/%/docker-bake.hcl) \
	-f $(LOCAL_DIR)/github-actions/docker-bake.hcl

LOCAL_DOCKER_COMPOSE = docker compose \
    -f $(CURDIR)/docker-compose.yml \
    -f $(LOCAL_DIR)/docker-compose.yml \
    -f $(LOCAL_DIR)/trivy/docker-compose.yml \
    -f $(CURDIR)/.docker-compose-services-override.yml \
    -f $(CURDIR)/.docker-compose-networks-override.yml \
    -f $(CURDIR)/.docker-compose-gpu-override.yml

LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES = \
  studio


LOCAL_DOCKER_COMPOSE_SERVICES ?= \
  firebase-emulators \
  robotframework \
#   vault-dev \
#   trivy
#   clarinet-devnet \

-include $(LOCAL_DIR)/local.mk
# Android High-Level targets
-include $(LOCAL_DIR)/android.mk

VEGITO_GCLOUD_DIR ?= $(LOCAL_DIR)/gcloud
-include $(VEGITO_GCLOUD_DIR)/gcloud.mk
# ----------------------------------------------------------
