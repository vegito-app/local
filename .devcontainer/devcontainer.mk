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

local-docker-buildx-setup-github-codespaces:
	@-docker buildx inspect $(LOCAL_DOCKER_BUILDX_NAME) >/dev/null 2>&1 || \
	-docker buildx create \
	  --name $(LOCAL_DOCKER_BUILDX_NAME) \
	  --driver docker-container \
	  --platform linux/amd64 \
	  --driver-opt env.BUILDKIT_STEP_LOG_MAX_SIZE=10485760 \
	  --driver-opt env.BUILDKIT_STEP_LOG_MAX_SPEED=1048576 \
	  --use
	@-docker buildx inspect --bootstrap
.PHONY: local-docker-buildx-setup-github-codespaces