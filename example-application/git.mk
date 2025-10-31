GIT_SUBTREE_DIRS := gcloud

git-subtree-pull: $(GIT_SUBTREE_DIRS:%=git-subtree-%-pull)
.PHONY: git-subtree-pull

git-subtree-push: $(GIT_SUBTREE_DIRS:%=git-subtree-%-push)
.PHONY: git-subtree-push

git-subtree-status:
	@echo "🔍 Checking the status of subtrees..."
	@git status
.PHONY: git-subtree-status

VEGITO_APP_GIT_SUBTREE_REMOTE_BRANCH := subtree/$(VEGITO_PROJECT_NAME)-$(VEGITO_PROJECT_USER)-$(VERSION)

VEGITO_APP_GIT_SUBTREE_REMOTES := local

$(VEGITO_APP_GIT_SUBTREE_REMOTES:%=git-subtree-%-remote-branch-rm):
	@echo "🗑️ Removing the distribution branch..."
	-git push git@github.com:vegito-app/$(@:git-subtree-%-remote-branch-rm=%).git :$(VEGITO_APP_GIT_SUBTREE_REMOTE_BRANCH)
.PHONY: $(VEGITO_APP_GIT_SUBTREE_REMOTES:%=git-subtree-%-remote-branch-rm)

git-subtree-remote-branch-rm: $(VEGITO_APP_GIT_SUBTREE_REMOTES:%=git-subtree-%-remote-branch-rm)
.PHONY: git-subtree-remote-branch-rm

# ------------------------------------------
# Subtree ./local
# ------------------------------------------
git-subtree-local-pull:
	@echo "⬇︎ Pulling the local subtree..."
	@git subtree pull --prefix local \
	  git@github.com:vegito-app/local.git main --squash
	@echo "Local subtree pulled successfully."
.PHONY: git-subtree-local-pull

git-subtree-local-push:
	@echo "⬆︎ Pushing changes from the local subtree..."
	@git subtree push --prefix local \
	  git@github.com:vegito-app/local.git $(VEGITO_APP_GIT_SUBTREE_REMOTE_BRANCH)
	@echo "Local subtree pushed successfully."
.PHONY: git-subtree-local-push

LOCAL_DIR := $(CURDIR)/local
LOCAL_GO_MODULES := \
	backend \
	$(LOCAL_FIREBASE_EMULATORS_AUTH_FUNCTIONS_DIR)/functions/auth \
	proxy

LOCAL_ROBOTFRAMEWORK_TESTS_DIR := $(VEGITO_EXAMPLE_APPLICATION_TESTS_DIR)
LOCAL_BUILDER_IMAGE_VERSION=$(VEGITO_LOCAL_PUBLIC_IMAGES_BASE):builder-${LOCAL_VERSION}

-include $(LOCAL_DIR)/local.mk

GOOGLE_CLOUD_DIR := $(LOCAL_DIR)/gcloud
-include $(GOOGLE_CLOUD_DIR)/gcloud.mk
# ----------------------------------------------------------
