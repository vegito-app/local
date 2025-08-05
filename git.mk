# This Makefile manages the git subtrees for the Vegito application, allowing for easy pulling and pushing of changes across different sub-projects.

# -------------------------------------------
# Git Subtree Directories Management
# ________________________________________
#
# This section defines the directories that are managed as git subtrees.
# It allows for pulling and pushing changes to and from these directories.
GIT_SUBTREE_DIRS := auth local infra images

git-subtree-pull: $(GIT_SUBTREE_DIRS:%=git-subtree-%-pull)
.PHONY: git-subtree-pull

git-subtree-push: $(GIT_SUBTREE_DIRS:%=git-subtree-%-push)
.PHONY: git-subtree-push

git-subtree-status:
	@echo "🔍 Checking the status of subtrees..."
	@git status
.PHONY: git-subtree-status

# -------------------------------------------
# Remote branch management for subtrees
# ________________________________________
#
# This variable defines the remote branch used for subtree operations.
# It is used to ensure that all subtree pushes and pulls reference the same branch.
VEGITO_APP_GIT_SUBTREE_REMOTE_BRANCH := subtree/$(PROJECT_NAME)-$(VERSION)
VEGITO_APP_GIT_SUBTREE_REMOTES := \
	local \
	vegito-images-vision \
	vegito-run \
	vegito-auth

$(VEGITO_APP_GIT_SUBTREE_REMOTES:%=git-subtree-%-remote-branch-rm):
	@echo "🗑️ Removing the distribution branch..."
	-git push git@github.com:vegito-app/$(@:git-subtree-%-remote-branch-rm=%).git :$(VEGITO_APP_GIT_SUBTREE_REMOTE_BRANCH)
.PHONY: $(VEGITO_APP_GIT_SUBTREE_REMOTES:%=git-subtree-%-remote-branch-rm)

git-subtree-remote-branch-rm: $(VEGITO_APP_GIT_SUBTREE_REMOTES:%=git-subtree-%-remote-branch-rm)
.PHONY: git-subtree-remote-branch-rm

# ------------------------------------------
# Subtree management for ./local directory
# ___________________________________________
#
# This section manages the local subtree, which contains local development tools and configurations.
# It allows for pulling and pushing changes to a separate local repository.
#------------------------------------------
git-subtree-local-pull-remote-branch:
git-subtree-local-pull:
	@echo "⬇︎ Pulling the local subtree..."
	git subtree pull --prefix local \
	  git@github.com:vegito-app/local.git main --squash
.PHONY: git-subtree-local-pull

git-subtree-local-push:
	@echo "⬆︎ Pushing changes from the local subtree..."
	git subtree push --prefix local \
	  git@github.com:vegito-app/local.git $(VEGITO_APP_GIT_SUBTREE_REMOTE_BRANCH)
.PHONY: git-subtree-local-push

LOCAL_DIR = $(CURDIR)/local
LOCAL_IMAGES_BASE := vegito-app
LOCAL_CONTAINERS_CACHE = $(CURDIR)/.containers
LOCAL_DOCKER_BUILDX_CACHE = $(LOCAL_CONTAINERS_CACHE)/docker-buildx-cache

# Local Buildx Caches
LOCAL_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE = $(LOCAL_DOCKER_BUILDX_CACHE)/application-backend
LOCAL_APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE = $(LOCAL_DOCKER_BUILDX_CACHE)/application-tests
LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE = $(LOCAL_DOCKER_BUILDX_CACHE)/android-studio
LOCAL_VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE = $(LOCAL_DOCKER_BUILDX_CACHE)/vault-dev
LOCAL_FIREBASE_EMULATORS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE = $(LOCAL_DOCKER_BUILDX_CACHE)/firebase-emulators
LOCAL_CLARINET_DEVNET_IMAGE_DOCKER_BUILDX_CACHE = $(LOCAL_DOCKER_BUILDX_CACHE)/clarinet-devnet
LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE = $(LOCAL_DOCKER_BUILDX_CACHE)/github-actions-runner

# Individual Container Caches
LOCAL_DEV_CONTAINER_CACHE = $(LOCAL_CONTAINERS_CACHE)/dev
LOCAL_ANDROID_STUDIO_CONTAINER_CACHE = $(LOCAL_CONTAINERS_CACHE)/android-studio
LOCAL_CLARINET_DEVNET_CONTAINER_CACHE = $(LOCAL_CONTAINERS_CACHE)/clarinet-devnet
LOCAL_FIREBASE_EMULATORS_CONTAINER_CACHE = $(LOCAL_CONTAINERS_CACHE)/firebase-emulators
LOCAL_VAULT_DEV_CONTAINER_CACHE = $(LOCAL_CONTAINERS_CACHE)/vault-dev
LOCAL_APPLICATION_TESTS_CONTAINER_CACHE = $(LOCAL_CONTAINERS_CACHE)/e2e-tests
LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_CACHE = $(LOCAL_DOCKER_BUILDX_CACHE)/builder

LOCAL_APPLICATION_TESTS_IMAGE = $(PUBLIC_IMAGES_BASE):application-tests-latest
LOCAL_ANDROID_STUDIO_IMAGE = $(PUBLIC_IMAGES_BASE):android-studio-latest
LOCAL_CLARINET_DEVNET_IMAGE = $(PUBLIC_IMAGES_BASE):clarinet-latest
LOCAL_FIREBASE_EMULATORS_IMAGE = $(PUBLIC_IMAGES_BASE):firebase-emulators-latest
LOCAL_VAULT_DEV_IMAGE = $(PUBLIC_IMAGES_BASE):vault-dev-latest
# LATEST_BUILDER_IMAGE = $(PUBLIC_IMAGES_BASE):builder-latest
LOCAL_APPLICATION_BACKEND_IMAGE=$(APPLICATION_BACKEND_IMAGE)

LOCAL_FIREBASE_EMULATORS_PUBSUB_VEGETABLE_IMAGES_VALIDATED_SUBSCRIPTIONS = \
  $(LOCAL_FIREBASE_EMULATORS_PUBSUB_VEGETABLE_IMAGES_VALIDATED_BACKEND_SUBSCRIPTION) \
  $(LOCAL_FIREBASE_EMULATORS_PUBSUB_VEGETABLE_IMAGES_VALIDATED_BACKEND_SUBSCRIPTION_DEBUG)

LOCAL_VERSION = $(VERSION)

APPLICATION_IMAGES_WORKERS_DOCKER_BUILDX_BAKE_IMAGES = \
  application-images-cleaner  \
  application-images-moderator

APPLICATION_DOCKER_BUILDX_BAKE_IMAGES = \
  application-backend \
  application-mobile

LOCAL_DOCKER_BUILDX_BAKE = docker buildx bake \
	-f $(LOCAL_DIR)/docker/docker-bake.hcl \
	-f $(LOCAL_DIR)/docker-bake.hcl \
	$(LOCAL_DOCKER_BUILDX_BAKE_IMAGES:%=-f $(LOCAL_DIR)/%/docker-bake.hcl) \
	-f $(APPLICATION_DIR)/docker-bake.hcl \
	$(APPLICATION_IMAGES_WORKERS_DOCKER_BUILDX_BAKE_IMAGES:application-images-%=-f $(APPLICATION_DIR)/images/%/docker-bake.hcl) \
	$(APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:application-%=-f $(APPLICATION_DIR)/%/docker-bake.hcl) \
	-f $(LOCAL_DIR)/github/docker-bake.hcl

LOCAL_FIREBASE_EMULATORS_AUTH_FUNCTIONS_DIR:=../../firebase/functions

LOCAL_APPLICATION_TESTS_MOBILE_IMAGES_DIR := $(CURDIR)/tests/mobile_images
LOCAL_FIREBASE_EMULATORS_AUTH_FUNCTIONS_DIR := $(CURDIR)/firebase/functions
LOCAL_APPLICATION_TESTS_DIR := $(CURDIR)/tests

LOCAL_DOCKER_COMPOSE = docker compose \
    -f $(CURDIR)/docker-compose.yml \
    -f $(LOCAL_DIR)/docker-compose.yml \
    -f $(CURDIR)/.docker-compose-override.yml \
    -f $(CURDIR)/.docker-compose-networks-override.yml \
    -f $(CURDIR)/.docker-compose-gpu-override.yml

LOCAL_APPLICATION_MOBILE_ANDROID_PACKAGE_NAME = $(INFRA_ENV).vegito.app.android

-include $(LOCAL_DIR)/local.mk
#------------------------------------------
# Subtree management for ./images directory
#__________________________________________
#
# This section manages the application images subtree, which contains the images filtering workers application code.
# This subtree allows for pulling and pushing changes to a separate images repository.
# It is used to manage the images filtering workers application code separately from the main application code.
#------------------------------------------
git-subtree-application-images-pull:
	@echo "⬇︎ Pulling the application-images subtree..."
	git subtree pull --prefix images \
	  git@github.com:vegito-app/vegito-images-vision.git main --squash
.PHONY: git-subtree-application-images-pull

git-subtree-images-push:
	@echo "⬆︎ Pushing changes from the application-images subtree..."
	git subtree push --prefix images \
	  git@github.com:vegito-app/vegito-images-vision.git $(VEGITO_APP_GIT_SUBTREE_REMOTE_BRANCH)
.PHONY: git-subtree-application-images-push

APPLICATION_IMAGES_DIR = $(CURDIR)/images

#------------------------------------------ 
# Subtree management for ./run directory
#__________________________________________
#
# This section manages the run subtree, which contains the project's run configurations.
# It allows for pulling and pushing changes to a separate run repository.
#------------------------------------------
git-subtree-infra-pull:
	@echo "⬇︎ Pulling the infra subtree..."
	git subtree pull --prefix infra \
	  git@github.com:vegito-app/vegito-run.git main --squash
.PHONY: git-subtree-infra-pull

git-subtree-infra-push:
	@echo "⬆︎ Pushing changes from the infra subtree..."
	git subtree push --prefix infra \
	  git@github.com:vegito-app/vegito-run.git $(VEGITO_APP_GIT_SUBTREE_REMOTE_BRANCH)
.PHONY: git-subtree-infra-push

APPLICATION_RUN_INFRA_DIR = $(CURDIR)/infra
APPLICATION_RUN_APPLICATION_DIR = $(APPLICATION_RUN_INFRA_DIR)
GOOGLE_APPLICATION_CREDENTIALS = $(APPLICATION_RUN_INFRA_DIR)/environments/$(INFRA_ENV)/google-credentials.json

-include $(CURDIR)/infra/infra.mk
INFRA_DIR := $(APPLICATION_RUN_INFRA_DIR)
#------------------------------------------
# Subtree management for ./auth directory
#__________________________________________
#
# This section manages the auth subtree, which contains the project's auth configurations.
# It allows for pulling and pushing changes to a separate auth repository.
#------------------------------------------
git-subtree-auth-pull:
	@echo "⬇︎ Pulling the auth subtree..."
	git subtree pull --prefix firebase/functions/auth \
	  git@github.com:vegito-app/vegito-auth.git main --squash
.PHONY: git-subtree-auth-pull

git-subtree-auth-push:
	@echo "⬆︎ Pushing changes from the auth subtree..."
	git subtree push --prefix firebase/functions/auth \
	  git@github.com:vegito-app/vegito-auth.git $(VEGITO_APP_GIT_SUBTREE_REMOTE_BRANCH)
.PHONY: git-subtree-auth-push

APPLICATION_AUTH_INFRA_DIR := $(CURDIR)/auth

-include $(CURDIR)/auth/infra.mk
APPLICATION_AUTH_APPLICATION_DIR := $(APPLICATION_AUTH_INFRA_DIR)
LOCAL_FIREBASE_EMULATORS_AUTH_FUNCTIONS_DIR ?= application/firebase/functions
