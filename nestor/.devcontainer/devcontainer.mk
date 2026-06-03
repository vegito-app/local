LOCAL_DOCKER_COMPOSE_VSCODE ?= $(LOCAL_DOCKER_COMPOSE) \
	-f $(CURDIR)/.devcontainer/docker-compose-vscode.yml

# 	-f $(CURDIR)/.devcontainer/docker-compose.yml \
# gcloud-auth-serviceaccount-activate \

devcontainer-vscode: \
ensure-vscode-store-volume \
vegito-docker-login
	@echo "🟢 Starting Devcontainer VSCode..."
	LOCAL_DOCKER_COMPOSE="$(LOCAL_DOCKER_COMPOSE_VSCODE)" \
	  $(MAKE) local-container-config-show dev
	@echo "🟢 Devcontainer VSCode is up and running."
.PHONY: devcontainer-vscode

ensure-vscode-store-volume:
	@docker volume inspect vscode-store > /dev/null 2>&1 || docker volume create vscode-store
	@echo "✅ Ensured VSCode store volume exists."
.PHONY: ensure-vscode-store-volume

LOCAL_DOCKER_COMPOSE_VSCODE_CODESPACES ?= $(LOCAL_DOCKER_COMPOSE) \
	-f $(CURDIR)/.devcontainer/docker-compose.yml \
	-f $(CURDIR)/.devcontainer/docker-compose-vscode-codespaces.yml

# gcloud-auth-serviceaccount-activate \

devcontainer-vscode-github-codespaces: \
vegito-docker-login
	@echo "🟢 Starting Github Codespaces VSCode environment..."
	@LOCAL_DOCKER_COMPOSE="$(LOCAL_DOCKER_COMPOSE_VSCODE_CODESPACES)" \
	  $(MAKE) dev
	@echo "🟢 Github Codespaces VSCode environment is up and running."
.PHONY: devcontainer-vscode-github-codespaces

vegito-docker-buildx-setup-github-codespaces:
	@-docker buildx inspect $(LOCAL_DOCKER_BUILDX_NAME) >/dev/null 2>&1 || \
	-docker buildx create \
	  --name $(LOCAL_DOCKER_BUILDX_NAME) \
	  --driver docker-container \
	  --platform linux/amd64 \
	  --driver-opt env.BUILDKIT_STEP_LOG_MAX_SIZE=10485760 \
	  --driver-opt env.BUILDKIT_STEP_LOG_MAX_SPEED=1048576 \
	  --use
	@-docker buildx inspect --bootstrap
.PHONY: vegito-docker-buildx-setup-github-codespaces

LOCAL_DEVCONTAINERS_DOCKER_COMPOSE_SERVICES ?= $(LOCAL_DOCKER_COMPOSE_SERVICES)

# gcloud-auth-serviceaccount-activate \

local-container-config-show:
	@echo "📦 Showing container configuration..."
	$(LOCAL_DOCKER_COMPOSE_VSCODE) config
.PHONY: local-container-config-show

$(LOCAL_DOCKER_COMPOSE_SERVICES):
	@echo "⬆︎ Bringing up container for $(@:%=%)..."
	@$(MAKE) $(@:%=vegito-%-container-up)
.PHONY: $(LOCAL_DOCKER_COMPOSE_SERVICES)

$(LOCAL_DOCKER_COMPOSE_SERVICES:%=vegito-%-container-rm): 
	@echo "🗑️  Removing container for $(@:vegito-%-container-rm=%)..."
	@$(MAKE) $(@:%-rm=%-stop)
	@$(LOCAL_DOCKER_COMPOSE) rm -f $(@:vegito-%-container-rm=%)
.PHONY: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=vegito-%-container-rm)

$(LOCAL_DOCKER_COMPOSE_SERVICES:%=vegito-%-container-start):
	@echo "▶️ Starting $(@:vegito-%-container-start=%)..."
	@-$(LOCAL_DOCKER_COMPOSE) start $(@:vegito-%-container-start=%) 2>/dev/null
.PHONY: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=vegito-%-container-start)

$(LOCAL_DOCKER_COMPOSE_SERVICES:%=vegito-%-container-stop):
	@echo "🛑 Stopping $(@:vegito-%-container-stop=%)..."
	@-$(LOCAL_DOCKER_COMPOSE) stop $(@:vegito-%-container-stop=%) 2>/dev/null
.PHONY: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=vegito-%-container-stop)

$(LOCAL_DOCKER_COMPOSE_SERVICES:%=vegito-%-container-logs):
	@echo "🗒️ Showing logs for $(@:vegito-%-container-logs=%)..."
	@$(LOCAL_DOCKER_COMPOSE) logs $(@:vegito-%-container-logs=%)
.PHONY: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=vegito-%-container-logs)

$(LOCAL_DOCKER_COMPOSE_SERVICES:%=vegito-%-container-logs-f):
	@echo "📝 Following logs for $(@:vegito-%-container-logs-f=%)..."
	@$(LOCAL_DOCKER_COMPOSE) logs --follow $(@:vegito-%-container-logs-f=%)
.PHONY: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=vegito-%-container-logs-f)

$(LOCAL_DOCKER_COMPOSE_SERVICES:%=vegito-%-container-sh):
	@echo "💻 Opening bash shell for $(@:vegito-%-container-sh=%)..."
	@$(LOCAL_DOCKER_COMPOSE) exec $(@:vegito-%-container-sh=%) bash
.PHONY: $(LOCAL_DOCKER_COMPOSE_SERVICES:%=vegito-%-container-sh)

$(LOCAL_DEVCONTAINERS_DOCKER_COMPOSE_SERVICES:%=devcontainer-vscode-%): \
vegito-docker-login
	@echo "🟢 Starting $(@:devcontainer-vscode-%=%) for vscode-server ..."
	LOCAL_DOCKER_COMPOSE="$(LOCAL_DOCKER_COMPOSE_VSCODE)" \
	  $(MAKE) local-container-config-show $(@:devcontainer-vscode-%=%)
	@echo "🟢 $(@:devcontainer-vscode-%=%) for vscode-server is up and running."
.PHONY: $(LOCAL_DEVCONTAINERS_DOCKER_COMPOSE_SERVICES:%=devcontainer-vscode-%)