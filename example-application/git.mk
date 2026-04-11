GIT_SUBTREE_DIRS := local

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
