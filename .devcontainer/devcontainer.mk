LOCAL_DOCKER_COMPOSE_VSCODE = $(LOCAL_DOCKER_COMPOSE) \
	-f $(CURDIR)/.devcontainer/docker-compose.yml \
	-f $(CURDIR)/.devcontainer/docker-compose-vscode.yml

devcontainer-vscode: \
ensure-vscode-store-volume \
gcloud-auth-serviceaccount-activate \
docker-login
	@echo "🟢 Starting Devcontainer VSCode..."
	@LOCAL_DOCKER_COMPOSE="$(LOCAL_DOCKER_COMPOSE_VSCODE)" \
	  $(MAKE) dev
	@echo "🟢 Devcontainer VSCode is up and running."
.PHONY: devcontainer-vscode

ensure-vscode-store-volume:
	@docker volume inspect vscode-store > /dev/null 2>&1 || docker volume create vscode-store
	@echo "✅ Ensured VSCode store volume exists."
.PHONY: ensure-vscode-store-volume

LOCAL_DOCKER_COMPOSE_VSCODE_CODESPACES = $(LOCAL_DOCKER_COMPOSE) \
	-f $(CURDIR)/.devcontainer/docker-compose.yml \
	-f $(CURDIR)/.devcontainer/docker-compose-vscode-codespaces.yml

devcontainer-vscode-github-codespaces: \
gcloud-auth-serviceaccount-activate \
docker-login
	@echo "🟢 Starting Github Codespaces VSCode environment..."
	@LOCAL_DOCKER_COMPOSE="$(LOCAL_DOCKER_COMPOSE_VSCODE_CODESPACES)" \
	  $(MAKE) dev
	@echo "🟢 Github Codespaces VSCode environment is up and running."
.PHONY: devcontainer-vscode-github-codespaces

docker-buildx-setup-github-codespaces:
	@-docker buildx inspect $(LOCAL_DOCKER_BUILDX_NAME) >/dev/null 2>&1 || \
	-docker buildx create \
	  --name $(LOCAL_DOCKER_BUILDX_NAME) \
	  --driver docker-container \
	  --platform linux/amd64 \
	  --driver-opt env.BUILDKIT_STEP_LOG_MAX_SIZE=10485760 \
	  --driver-opt env.BUILDKIT_STEP_LOG_MAX_SPEED=1048576 \
	  --use
	@-docker buildx inspect --bootstrap
.PHONY: docker-buildx-setup-github-codespaces

LOCAL_DEVCONTAINERS_DOCKER_COMPOSE_SERVICES ?= $(LOCAL_DOCKER_COMPOSE_SERVICES)

$(LOCAL_DEVCONTAINERS_DOCKER_COMPOSE_SERVICES:%=devcontainer-vscode-%): \
gcloud-auth-serviceaccount-activate \
docker-login
	@echo "🟢 Starting $(@:devcontainer-vscode-%=%) for vscode-server ..."
	@LOCAL_DOCKER_COMPOSE="$(LOCAL_DOCKER_COMPOSE_VSCODE)" \
	  $(MAKE) local-container-config-show $(@:devcontainer-vscode-%=%)
	@echo "🟢 $(@:devcontainer-vscode-%=%) for vscode-server is up and running."
.PHONY: $(LOCAL_DEVCONTAINERS_DOCKER_COMPOSE_SERVICES:%=devcontainer-vscode-%)