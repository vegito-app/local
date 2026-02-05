CODESPACES_HUB_PROJECT_NAME ?= codespaces-hub

CODESPACES_DEVELOPMENT_HUB_DIR ?= $(CURDIR)

NFS_WIREGUARD_BRIDGE_PROJECT_DIR ?= $(CODESPACES_DEVELOPMENT_HUB_DIR)/nfs-wireguard-bridge
DOCKER_SSH_BRIDGE_PROJECT_DIR ?= $(CODESPACES_DEVELOPMENT_HUB_DIR)/docker-ssh-bridge

-include $(CODESPACES_DEVELOPMENT_HUB_DIR)/git.mk
-include $(CODESPACES_DEVELOPMENT_HUB_DIR)/.devcontainer/devcontainer.mk
-include $(CODESPACES_DEVELOPMENT_HUB_DIR)/nfs-wireguard-bridge/nfs-wireguard-bridge.mk
-include $(CODESPACES_DEVELOPMENT_HUB_DIR)/docker-ssh-bridge/docker-ssh-bridge.mk

codespaces-hub-server-up: 
	@echo Launching Github Codespaces development Hub
	@$(MAKE) \
	  docker-ssh-bridge-server-up-github-codespaces \
	  nfs-wireguard-bridge-server-up-github-codespaces		
.PHONY: codespaces-hub-server-up