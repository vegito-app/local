NFS_WIREGUARD_BRIDGE_PROJECT_DIR ?= $(CURDIR)
NFS_WIREGUARD_BRIDGE_PROJECT_NAME ?= nfs-wireguard-bridge

export 

-include $(NFS_WIREGUARD_BRIDGE_PROJECT_DIR)/nfs-wireguard-bridge.mk

build: nfs-wireguard-bridge-image-build
.PHONY: build

push: nfs-wireguard-bridge-image-push
.PHONY: push

pull: nfs-wireguard-bridge-image-pull
.PHONY: pull

server-upgrade: nfs-wireguard-bridge-server-upgrade
.PHONY: server-upgrade

server-up: nfs-wireguard-bridge-server-up
.PHONY: server-up

server-down: nfs-wireguard-bridge-server-down
.PHONY: server-down

server-rm: nfs-wireguard-bridge-server-rm
.PHONY: server-rm

server-up-github-codespaces: nfs-wireguard-bridge-server-up-github-codespaces
.PHONY: server-up-github-codespaces

server-logs: nfs-wireguard-bridge-server-logs
.PHONY: server-logs

server-logs-follow: nfs-wireguard-bridge-server-logs-follow
.PHONY: server-logs-follow

server-bash: nfs-wireguard-bridge-server-bash
.PHONY: server-bash
