LOCAL_DOCKER_COMPOSE_VSCODE = $(LOCAL_DOCKER_COMPOSE) \
	-f $(CURDIR)/.devcontainer/docker-compose.yml \
	-f $(CURDIR)/.devcontainer/docker-compose-vscode.yml

local-vscode-devcontainer: ensure-vscode-store-volume
	@echo "🟢 Starting Devcontainer VSCode..."
	  $(MAKE) dev
	@echo "🟢 Devcontainer VSCode is up and running."
.PHONY: local-vscode-devcontainer

LOCAL_DOCKER_COMPOSE_VSCODE_CODESPACES = $(LOCAL_DOCKER_COMPOSE) \
	-f $(CURDIR)/.devcontainer/docker-compose.yml \
	-f $(CURDIR)/.devcontainer/docker-compose-vscode-codespaces.yml

local-vscode-devcontainer-codespaces: 
	@echo "🟢 Starting Github Codespaces VSCode environment..."
	@LOCAL_DOCKER_COMPOSE= $(LOCAL_DOCKER_COMPOSE_VSCODE_CODESPACES) \
	  $(MAKE) dev
	@echo "🟢 Github Codespaces VSCode environment is up and running."
.PHONY: local-codespaces
