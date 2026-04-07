GIT_SUBTREE_DIRS := gcloud example-application

git-subtree-pull: $(GIT_SUBTREE_DIRS:%=git-subtree-%-pull)
.PHONY: git-subtree-pull

git-subtree-push: $(GIT_SUBTREE_DIRS:%=git-subtree-%-push)
.PHONY: git-subtree-push

git-subtree-status:
	@echo "🔍 Checking the status of subtrees..."
	@git status
.PHONY: git-subtree-status

VEGITO_APP_GIT_SUBTREE_REMOTE_BRANCH := subtree/$(VEGITO_PROJECT_NAME)-$(VEGITO_PROJECT_USER)-$(VERSION)

VEGITO_APP_GIT_SUBTREE_REMOTES := gcloud example-application

$(VEGITO_APP_GIT_SUBTREE_REMOTES:%=git-subtree-%-remote-branch-rm):
	@echo "🗑️ Removing the distribution branch..."
	-git push git@github.com:vegito-app/$(@:git-subtree-%-remote-branch-rm=%).git :$(VEGITO_APP_GIT_SUBTREE_REMOTE_BRANCH)
.PHONY: $(VEGITO_APP_GIT_SUBTREE_REMOTES:%=git-subtree-%-remote-branch-rm)

git-subtree-remote-branch-rm: $(VEGITO_APP_GIT_SUBTREE_REMOTES:%=git-subtree-%-remote-branch-rm)
.PHONY: git-subtree-remote-branch-rm

# ------------------------------------------
# Subtree ./google-cloud
# ------------------------------------------
git-subtree-gcloud-pull:
	@echo "⬇︎ Pulling the gcloud subtree..."
	@git subtree pull --prefix gcloud \
	  git@github.com:vegito-app/gcloud.git main --squash
	@echo "Gcloud subtree pulled successfully."
.PHONY: git-subtree-gcloud-pull

git-subtree-gcloud-push:
	@echo "⬆︎ Pushing changes from the gcloud subtree..."
	@git subtree push --prefix gcloud \
	  git@github.com:vegito-app/gcloud.git $(VEGITO_APP_GIT_SUBTREE_REMOTE_BRANCH)
	@echo "Gcloud subtree pushed successfully."
.PHONY: git-subtree-gcloud-push

VEGITO_GCLOUD_DIR := $(LOCAL_DIR)/gcloud
-include $(VEGITO_GCLOUD_DIR)/gcloud.mk
# ------------------------------------------

# ------------------------------------------
# Subtree ./example-application
# ------------------------------------------
git-subtree-example-application-pull:
	@echo "⬇︎ Pulling the example-application subtree..."
	@git subtree pull --prefix example-application \
	  git@github.com:vegito-app/example-application.git main --squash
	@echo "Example Application subtree pulled successfully."
.PHONY: git-subtree-example-application-pull

git-subtree-example-application-push:
	@echo "⬆︎ Pushing changes from the example-application subtree..."
	@git subtree push --prefix example-application \
	  git@github.com:vegito-app/example-application.git $(VEGITO_APP_GIT_SUBTREE_REMOTE_BRANCH)
	@echo "Example application subtree pushed successfully."
.PHONY: git-subtree-example-application-push

VEGITO_EXAMPLE_APPLICATION_DIR = $(LOCAL_DIR)/example-application

VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGES_BASE := $(VEGITO_LOCAL_PUBLIC_IMAGES_BASE):example-application-backend
VEGITO_EXAMPLE_APPLICATION_MOBILE_IMAGES_BASE := $(VEGITO_LOCAL_PUBLIC_IMAGES_BASE):example-application-mobile
VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGES_BASE := $(VEGITO_LOCAL_PUBLIC_IMAGES_BASE):example-application-tests

-include $(VEGITO_EXAMPLE_APPLICATION_DIR)/example-application.mk
# ------------------------------------------
