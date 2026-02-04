DOCKER_SSH_BRIDGE_PROJECT_DIR ?= $(CURDIR)

-include $(DOCKER_SSH_BRIDGE_PROJECT_DIR)/docker-ssh-bridge.mk

server-upgrade: build server-down server-up
.PHONY: server-upgrade

server-up: docker-ssh-bridge-server-up
.PHONY: server-up

server-up-github-codespaces: docker-ssh-bridge-server-up-github-codespaces
.PHONY: server-up-github-codespaces

server-logs: docker-ssh-bridge-server-logs
.PHONY: server-logs

server-logs-follow: docker-ssh-bridge-server-logs-follow
.PHONY: server-logs-follow

server-sh: docker-ssh-bridge-server-sh
.PHONY: server-sh

server-down: docker-ssh-bridge-server-down
.PHONY: server-down

docker-proxy: docker-ssh-bridge-docker-proxy
.PHONY: docker-proxy

docker-proxy-sh: docker-ssh-bridge-docker-proxy-sh
.PHONY: docker-proxy-sh

docker-proxy-rm: docker-ssh-bridge-docker-proxy-rm
.PHONY: docker-proxy-rm

client: docker-ssh-bridge-client
	@docker compose up consumer
.PHONY: client

client-sh: docker-ssh-bridge-client-sh
.PHONY: client-sh

generate-ssh-keys: docker-ssh-bridge-generate-ssh-keys
.PHONY: generate-ssh-keys

build: docker-ssh-bridge-build
.PHONY: build

push: docker-ssh-bridge-push
.PHONY: push

pull: docker-ssh-bridge-pull
.PHONY: pull

server-rm: docker-ssh-bridge-server-rm
.PHONY: server-rm
