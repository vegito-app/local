GIT_SUBTREE_DIRS ?= \
  docker-ssh-bridge \
  nfs-wireguard-bridge

git-subtree-pull: $(GIT_SUBTREE_DIRS:%=git-subtree-%-pull)
.PHONY: git-subtree-pull

git-subtree-push: $(GIT_SUBTREE_DIRS:%=git-subtree-%-push)
.PHONY: git-subtree-push

git-subtree-status:
	@echo "🔍 Checking the status of subtrees..."
	@git status
.PHONY: git-subtree-status

GIT_SUBTREE_REMOTE_BRANCH := subtree/$(CODESPACES_HUB_PROJECT_NAME)-$(CODESPACES_HUB_PROJECT_USER)-$(VERSION)

GIT_SUBTREE_REMOTES := gcloud example-application

$(GIT_SUBTREE_REMOTES:%=git-subtree-%-remote-branch-rm):
	@echo "🗑️ Removing the distribution branch..."
	-git push git@github.com:7d4b9/$(@:git-subtree-%-remote-branch-rm=%).git :$(GIT_SUBTREE_REMOTE_BRANCH)
.PHONY: $(GIT_SUBTREE_REMOTES:%=git-subtree-%-remote-branch-rm)

git-subtree-remote-branch-rm: $(GIT_SUBTREE_REMOTES:%=git-subtree-%-remote-branch-rm)
.PHONY: git-subtree-remote-branch-rm

# ------------------------------------------
# Subtree ./docker-ssh-bridge
# ------------------------------------------
git-subtree-docker-ssh-bridge-pull:
	@echo "⬇︎ Pulling the docker-ssh-bridge subtree..."
	@git subtree pull --prefix docker-ssh-bridge \
	  git@github.com:7d4b9/docker-ssh-bridge.git main --squash
	@echo "Docker SSH Bridge subtree pulled successfully."
.PHONY: git-subtree-docker-ssh-bridge-pull

git-subtree-docker-ssh-bridge-push:
	@echo "⬆︎ Pushing changes from the docker-ssh-bridge subtree..."
	@git subtree push --prefix docker-ssh-bridge \
	  git@github.com:7d4b9/docker-ssh-bridge.git $(GIT_SUBTREE_REMOTE_BRANCH)
	@echo "Docker SSH Bridge subtree pushed successfully."
.PHONY: git-subtree-docker-ssh-bridge-push

DOCKER_SSH_BRIDGE_PROJECT_DIR := $(CODESPACES_DEVELOPMENT_HUB_DIR)/docker-ssh-bridge
-include $(DOCKER_SSH_BRIDGE_PROJECT_DIR)/docker-ssh-bridge.mk
# ------------------------------------------

# ------------------------------------------
# Subtree ./nfs-wireguard-bridge
# ------------------------------------------
git-subtree-nfs-wireguard-bridge-pull:
	@echo "⬇︎ Pulling the nfs-wireguard-bridge subtree..."
	@git subtree pull --prefix nfs-wireguard-bridge \
	  git@github.com:7d4b9/nfs-wireguard-bridge.git main --squash
	@echo "NFS Wireguard Bridge subtree pulled successfully."
.PHONY: git-subtree-nfs-wireguard-bridge-pull

git-subtree-nfs-wireguard-bridge-push:
	@echo "⬆︎ Pushing changes from the nfs-wireguard-bridge subtree..."
	@git subtree push --prefix nfs-wireguard-bridge \
	  git@github.com:7d4b9/nfs-wireguard-bridge.git $(GIT_SUBTREE_REMOTE_BRANCH)
	@echo "NFS Wireguard Bridge subtree pushed successfully."
.PHONY: git-subtree-nfs-wireguard-bridge-push

NFS_WIREGUARD_BRIDGE_PROJECT_DIR = $(CODESPACES_DEVELOPMENT_HUB_DIR)/nfs-wireguard-bridge
-include $(NFS_WIREGUARD_BRIDGE_PROJECT_DIR)/nfs-wireguard-bridge.mk
# ------------------------------------------
