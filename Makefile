CODESPACES_HUB_PROJECT_NAME ?= codespaces-hub

CODESPACES_DEVELOPMENT_HUB_DIR ?= $(CURDIR)

-include $(CODESPACES_DEVELOPMENT_HUB_DIR)/git.mk

server-up-github-codespaces: 
	@echo Launching Github Codespaces development Hub
	@$(MAKE) \
	  docker-ssh-bridge-server-up-github-codespaces \
	  nfs-wireguard-bridge-server-up-github-codespaces		
.PHONY: server-up-github-codespaces