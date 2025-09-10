GIT_SUBTREE_DIRS := gcloud

git-subtree-pull: $(GIT_SUBTREE_DIRS:%=git-subtree-%-pull)
.PHONY: git-subtree-pull

git-subtree-push: $(GIT_SUBTREE_DIRS:%=git-subtree-%-push)
.PHONY: git-subtree-push

git-subtree-status:
	@echo "🔍 Checking the status of subtrees..."
	@git status
.PHONY: git-subtree-status

GIT_SUBTREE_REMOTE_BRANCH := subtree/$(VEGITO_PROJECT_NAME)-$(VERSION)

VEGITO_APP_GIT_SUBTREE_REMOTES := gcloud

$(VEGITO_APP_GIT_SUBTREE_REMOTES:%=git-subtree-%-remote-branch-rm):
	@echo "🗑️ Removing the distribution branch..."
	-git push git@github.com:vegito-app/$(@:git-subtree-%-remote-branch-rm=%).git :$(GIT_SUBTREE_REMOTE_BRANCH)
.PHONY: $(VEGITO_APP_GIT_SUBTREE_REMOTES:%=git-subtree-%-remote-branch-rm)

git-subtree-remote-branch-rm: $(VEGITO_APP_GIT_SUBTREE_REMOTES:%=git-subtree-%-remote-branch-rm)
.PHONY: git-subtree-remote-branch-rm

# ------------------------------------------
# Subtree ./gcloud
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
	  git@github.com:vegito-app/gcloud.git $(GIT_SUBTREE_REMOTE_BRANCH)
	@echo "Gcloud subtree pushed successfully."
.PHONY: git-subtree-gcloud-push

GCLOUD_DIR := $(CURDIR)/gcloud
-include $(GCLOUD_DIR)/gcloud.mk
# ------------------------------------------

# ------------------------------------------
# Subtree ./application
# ------------------------------------------
git-subtree-application-pull:
	@echo "⬇︎ Pulling the application subtree..."
	@git subtree pull --prefix application \
	  git@github.com:vegito-app/application.git main --squash
	@echo "Application subtree pulled successfully."
.PHONY: git-subtree-application-pull

git-subtree-application-push:
	@echo "⬆︎ Pushing changes from the application subtree..."
	@git subtree push --prefix application \
	  git@github.com:vegito-app/application.git $(GIT_SUBTREE_REMOTE_BRANCH)
	@echo "Application subtree pushed successfully."
.PHONY: git-subtree-application-push

-include $(CURDIR)/application/application.mk
# ------------------------------------------
