export

NFS_WIREGUARD_BRIDGE_PROJECT_DIR ?= $(CURDIR)
NFS_WIREGUARD_BRIDGE_PROJECT_NAME ?= nfs-wireguard-bridge

NFS_WIREGUARD_BRIDGE_DOCKER_REPOSITORY ?= dbndev
NFS_WIREGUARD_BRIDGE_DOCKER_IMAGE ?= $(NFS_WIREGUARD_BRIDGE_DOCKER_REPOSITORY)/nfs-wireguard-bridge

nfs-wireguard-bridge-image-build:
	@echo Building image:
	@docker build -t $(NFS_WIREGUARD_BRIDGE_DOCKER_IMAGE) .
.PHONY: nfs-wireguard-bridge-image-build

nfs-wireguard-bridge-image-push:
	@echo pushing image:
	@docker push $(NFS_WIREGUARD_BRIDGE_DOCKER_IMAGE)
.PHONY: nfs-wireguard-bridge-image-push

nfs-wireguard-bridge-image-pull:
	@echo pulling image:
	@docker pull $(NFS_WIREGUARD_BRIDGE_DOCKER_IMAGE)
.PHONY: nfs-wireguard-bridge-image-pull

nfs-wireguard-bridge-server-upgrade: nfs-wireguard-bridge-image-build nfs-wireguard-bridge-server-down nfs-wireguard-bridge-server-up
.PHONY: nfs-wireguard-bridge-server-upgrade

NFS_WIREGUARD_BRIDGE_SERVER_HOST ?= 10.5.5.5
NFS_WIREGUARD_BRIDGE_SERVER_PORT ?= 51820

NFS_WIREGUARD_BRIDGE_COMPOSE_PROJECT_NAME ?= $(NFS_WIREGUARD_BRIDGE_PROJECT_NAME)

NFS_WIREGUARD_BRIDGE_SERVER_DOCKER_COMPOSE = \
  COMPOSE_PROJECT_NAME=$(NFS_WIREGUARD_BRIDGE_COMPOSE_PROJECT_NAME) \
  docker compose \
  -f $(NFS_WIREGUARD_BRIDGE_PROJECT_DIR)/docker-compose.yml

nfs-wireguard-bridge-server-up: nfs-wireguard-bridge-server-rm
	@echo Launching wireguard NFS bridge server
	@$(NFS_WIREGUARD_BRIDGE_SERVER_DOCKER_COMPOSE) up -d nfs-wireguard-bridge-server
	@echo server is running.
	@echo use "make server-logs" or "make server-logs-follow" to view server logs
.PHONY: nfs-wireguard-bridge-server-up

nfs-wireguard-bridge-server-down:
	@echo Removing NFS server container
	@$(NFS_WIREGUARD_BRIDGE_SERVER_DOCKER_COMPOSE) down server || $(MAKE) nfs-wireguard-bridge-server-rm
.PHONY: nfs-wireguard-bridge-server-down

nfs-wireguard-bridge-server-rm:
	@echo Removing NFS server container
	-$(NFS_WIREGUARD_BRIDGE_SERVER_DOCKER_COMPOSE) rm -f -s server
.PHONY: nfs-wireguard-bridge-server-rm

nfs-wireguard-bridge-server-up-github-codespaces:
	@echo Launching wireguard NFS bridge server in GitHub Codespaces
	@NFS_WIREGUARD_BRIDGE_GITHUB_ACTIONS_RUNNER_WORK_DIR=/mnt/data/gha-runner \
	  $(MAKE) nfs-wireguard-bridge-server-up
.PHONY: nfs-wireguard-bridge-server-up-github-codespaces

nfs-wireguard-bridge-server-logs:
	@$(NFS_WIREGUARD_BRIDGE_SERVER_DOCKER_COMPOSE) logs server
.PHONY: nfs-wireguard-bridge-server-logs

nfs-wireguard-bridge-server-logs-follow:
	@$(NFS_WIREGUARD_BRIDGE_SERVER_DOCKER_COMPOSE) logs --follow server
.PHONY: nfs-wireguard-bridge-server-logs-follow

nfs-wireguard-bridge-server-bash:
	@echo Launching NFS server shell
	@$(NFS_WIREGUARD_BRIDGE_SERVER_DOCKER_COMPOSE) exec -it server bash
.PHONY: nfs-wireguard-bridge-server-bash