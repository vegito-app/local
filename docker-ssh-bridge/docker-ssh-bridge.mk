export 

DOCKER_SSH_BRIDGE_PROJECT_DIR ?= $(CURDIR)
DOCKER_SSH_BRIDGE_PROJECT_NAME ?= docker-ssh-bridge

DOCKER_SSH_BRIDGE_DOCKER_REPOSITORY ?= dbndev
IMAGE := $(DOCKER_SSH_BRIDGE_DOCKER_REPOSITORY)/ssh-bridge

docker-ssh-bridge-server-upgrade: docker-ssh-bridge-build docker-ssh-bridge-server-down docker-ssh-bridge-server-up
.PHONY: docker-ssh-bridge-server-upgrade

DOCKER_SSH_BRIDGE_COMPOSE_PROJECT_NAME ?= docker-ssh-bridge

DOCKER_SSH_BRIDGE_SERVER_DOCKER_COMPOSE = \
  COMPOSE_PROJECT_NAME=$(DOCKER_SSH_BRIDGE_COMPOSE_PROJECT_NAME) \
  docker compose

DOCKER_SSH_BRIDGE_DOCKER_ADDRESS ?= localhost

docker-ssh-bridge-server-up: $(DOCKER_SSH_BRIDGE_SSH_PUBLIC_KEY)
	@echo Launching ssh server
	@-$(DOCKER_SSH_BRIDGE_SERVER_DOCKER_COMPOSE) rm -f -s server
	@$(DOCKER_SSH_BRIDGE_SERVER_DOCKER_COMPOSE) up -d server
	@until nc -z $(DOCKER_SSH_BRIDGE_DOCKER_ADDRESS) 22022 ; do echo waiting server ; sleep 1 ; done
	@echo server is running.
	@echo use "make server-logs" or "make server-logs-follow" to view server logs
.PHONY: docker-ssh-bridge-server-up

docker-ssh-bridge-server-up-github-codespaces:
	@echo Launching ssh server in GitHub Codespaces
	@DOCKER_SSH_BRIDGE_GITHUB_ACTIONS_RUNNER_WORK_DIR=/mnt/data/gha-runner \
	DOCKER_SSH_BRIDGE_DOCKER_ADDRESS=172.17.0.1 \
	COMPOSE_PROJECT_NAME=ssh-docker-bridge \
	  $(MAKE) docker-ssh-bridge-server-up
.PHONY: docker-ssh-bridge-server-up-github-codespaces
  
docker-ssh-bridge-server-logs:
	@$(DOCKER_SSH_BRIDGE_SERVER_DOCKER_COMPOSE) logs server
.PHONY: docker-ssh-bridge-server-logs

docker-ssh-bridge-server-logs-follow:
	@$(DOCKER_SSH_BRIDGE_SERVER_DOCKER_COMPOSE) logs --follow server
.PHONY: docker-ssh-bridge-server-logs-follow

docker-ssh-bridge-server-sh:
	@echo Launching ssh server shell
	@$(DOCKER_SSH_BRIDGE_SERVER_DOCKER_COMPOSE) exec -it server bash
.PHONY: docker-ssh-bridge-server-sh

docker-ssh-bridge-server-down:
	@echo Removing ssh server container
	@$(DOCKER_SSH_BRIDGE_SERVER_DOCKER_COMPOSE) down server
.PHONY: docker-ssh-bridge-server-down

docker-ssh-bridge-docker-proxy: $(DOCKER_SSH_BRIDGE_SSH_PRIVATE_KEY)
	@echo Launching ssh proxy
	@-$(DOCKER_SSH_BRIDGE_SERVER_DOCKER_COMPOSE) rm -f -s docker-proxy
	@$(DOCKER_SSH_BRIDGE_SERVER_DOCKER_COMPOSE) up docker-proxy
.PHONY: docker-ssh-bridge-docker-proxy

docker-ssh-bridge-docker-proxy-sh:
	@echo Launching ssh proxy shell
	@$(DOCKER_SSH_BRIDGE_SERVER_DOCKER_COMPOSE) exec -it docker-proxy bash
.PHONY: docker-ssh-bridge-docker-proxy-sh

docker-ssh-bridge-client:
	@echo Launching ssh client
	@-$(DOCKER_SSH_BRIDGE_SERVER_DOCKER_COMPOSE) rm -f -s docker-proxy-client
	@$(DOCKER_SSH_BRIDGE_SERVER_DOCKER_COMPOSE) up consumer
.PHONY: docker-ssh-bridge-client

docker-ssh-bridge-client-sh:
	@echo Launching ssh client shell
	@$(DOCKER_SSH_BRIDGE_SERVER_DOCKER_COMPOSE) exec -it consumer bash
.PHONY: docker-ssh-bridge-client-sh

DOCKER_SSH_BRIDGE_SSH_PRIVATE_KEY ?= $(DOCKER_SSH_BRIDGE_PROJECT_DIR)/id_rsa
DOCKER_SSH_BRIDGE_SSH_PUBLIC_KEY ?= $(DOCKER_SSH_BRIDGE_PROJECT_DIR)/id_rsa.pub

DOCKER_SSH_BRIDGE_SSH_KEYS = $(DOCKER_SSH_BRIDGE_SSH_PRIVATE_KEY) $(DOCKER_SSH_BRIDGE_SSH_PUBLIC_KEY)

$(DOCKER_SSH_BRIDGE_SSH_KEYS): docker-ssh-bridge-generate-ssh-keys

docker-ssh-bridge-generate-ssh-keys: ssh-keys-rm 
	@echo Generating ssh keys
	@ssh-keygen -t rsa -b 4096 -f $(DOCKER_SSH_BRIDGE_SSH_PRIVATE_KEY) -q -N ""
.PHONY: docker-ssh-bridge-generate-ssh-keys

docker-ssh-bridge-build:
	@echo Building image:
	@docker build -t $(IMAGE) .
.PHONY: docker-ssh-bridge-build

docker-ssh-bridge-push:
	@echo pushing image:
	@docker push $(IMAGE)
.PHONY: docker-ssh-bridge-push

docker-ssh-bridge-pull:
	@echo pulling image:
	@docker pull $(IMAGE)
.PHONY: docker-ssh-bridge-pull

docker-ssh-bridge-ssh-keys-rm:
	@rm -rf $(DOCKER_SSH_BRIDGE_SSH_KEYS)
.PHONY: docker-ssh-bridge-ssh-keys-clean