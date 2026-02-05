CODESPACES_HUB_PROJECT_NAME ?= codespaces-hub

CODESPACES_DEVELOPMENT_HUB_DIR ?= $(CURDIR)

-include $(CODESPACES_DEVELOPMENT_HUB_DIR)/git.mk
-include $(CODESPACES_DEVELOPMENT_HUB_DIR)/.devcontainer/devcontainer.mk

codespaces-hub-server-up: 
	@echo Launching Github Codespaces development Hub
	@$(MAKE) \
	  docker-ssh-bridge-server-up-github-codespaces \
	  nfs-wireguard-bridge-server-up-github-codespaces		
.PHONY: codespaces-hub-server-up