
VEGITO_DOCKER_HUB_REGISTRY ?= docker.io/dbndev

DOCKERHUB_USERNAME ?= $(VEGITO_DOCKERHUB_USERNAME)
DOCKERHUB_PAT ?= $(VEGITO_DOCKERHUB_PAT)

# VEGITO_DOCKER_DEBIAN_IMAGE_LATEST ?= debian:bookworm
# VEGITO_DOCKER_DEBIAN_IMAGE_VERSION ?= debian:bookworm
# VEGITO_GO_IMAGE_LATEST ?= golang:alpine
# VEGITO_GO_IMAGE_VERSION ?= golang:alpine
# VEGITO_DOCKER_ALPINE_RUST_IMAGE_LATEST ?=rust:1-alpine3.20
# VEGITO_DOCKER_ALPINE_RUST_IMAGE_VERSION ?=rust:1-alpine3.20
# VEGITO_DOCKER_HUB_DIND_ROOTLESS_IMAGE_LATEST ?= docker:dind-rootless
# VEGITO_DOCKER_HUB_DIND_ROOTLESS_IMAGE_VERSION ?= docker:dind-rootless

export VEGITO_DOCKER_DEBIAN_IMAGE_LATEST          ?= dbndev/vegito-public:bookworm-debian-latest
export VEGITO_DOCKER_DEBIAN_IMAGE_VERSION         ?= dbndev/vegito-public:bookworm-debian-latest
export VEGITO_DOCKER_TRIXIE_DEBIAN_IMAGE_LATEST   ?= dbndev/vegito-public:trixie-debian-latest
export VEGITO_DOCKER_TRIXIE_DEBIAN_IMAGE_VERSION  ?= dbndev/vegito-public:trixie-debian-latest

export VEGITO_GO_IMAGE_LATEST  ?= dbndev/vegito-public:docker-golang-alpine-latest
export VEGITO_GO_IMAGE_VERSION ?= dbndev/vegito-public:docker-golang-alpine-latest

export VEGITO_DOCKER_DEBIAN_PYTHON_IMAGE_LATEST   ?= dbndev/vegito-public:debian-python-latest
export VEGITO_DOCKER_DEBIAN_PYTHON_IMAGE_VERSION  ?= dbndev/vegito-public:debian-python-latest

export VEGITO_DOCKER_ALPINE_GOLANG_IMAGE_LATEST   ?= dbndev/vegito-public:golang-alpine-latest
export VEGITO_DOCKER_ALPINE_GOLANG_IMAGE_VERSION  ?= dbndev/vegito-public:golang-alpine-latest

export VEGITO_DOCKER_ALPINE_RUST_IMAGE_LATEST    ?= dbndev/vegito-public:rust-alpine-latest
export VEGITO_DOCKER_ALPINE_RUST_IMAGE_VERSION   ?= dbndev/vegito-public:rust-alpine-latest

export VEGITO_DOCKER_DEBIAN_GOLANG_IMAGE_LATEST   ?= dbndev/vegito-public:debian-golang-latest
export VEGITO_DOCKER_DEBIAN_GOLANG_IMAGE_VERSION  ?= dbndev/vegito-public:debian-golang-latest
export VEGITO_DOCKER_DEBIAN_GOLANG_DESKTOP_X_IMAGE_LATEST  ?= dbndev/vegito-public:debian-golang-desktop-x-latest
export VEGITO_DOCKER_DEBIAN_GOLANG_DESKTOP_X_IMAGE_VERSION ?= dbndev/vegito-public:debian-golang-desktop-x-latest

export VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_IMAGE_LATEST             ?= dbndev/vegito-public:trixie-debian-golang-latest
export VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_IMAGE_VERSION            ?= dbndev/vegito-public:trixie-debian-golang-latest
export VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DESKTOP_X_IMAGE_LATEST   ?= dbndev/vegito-public:trixie-debian-golang-desktop-x-latest
export VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DESKTOP_X_IMAGE_VERSION  ?= dbndev/vegito-public:trixie-debian-golang-desktop-x-latest

export VEGITO_DOCKER_DEBIAN_PYTHON_IMAGE_LATEST             ?= dbndev/vegito-public:debian-python-latest
export VEGITO_DOCKER_DEBIAN_PYTHON_IMAGE_VERSION            ?= dbndev/vegito-public:debian-python-latest
export VEGITO_DOCKER_DEBIAN_PYTHON_DESKTOP_X_IMAGE_LATEST   ?= dbndev/vegito-public:debian-python-desktop-x-latest
export VEGITO_DOCKER_DEBIAN_PYTHON_DESKTOP_X_IMAGE_VERSION  ?= dbndev/vegito-public:debian-python-desktop-x-latest

export VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_IMAGE_LATEST             ?= dbndev/vegito-public:debian-python-latest
export VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_IMAGE_VERSION            ?= dbndev/vegito-public:debian-python-latest
export VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_DESKTOP_X_IMAGE_LATEST   ?= dbndev/vegito-public:debian-python-desktop-x-latest
export VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_DESKTOP_X_IMAGE_VERSION  ?= dbndev/vegito-public:debian-python-desktop-x-latest

export VEGITO_DOCKER_DEBIAN_RUST_IMAGE_LATEST             ?= dbndev/vegito-public:debian-rust-latest
export VEGITO_DOCKER_DEBIAN_RUST_IMAGE_VERSION            ?= dbndev/vegito-public:debian-rust-latest
export VEGITO_DOCKER_DEBIAN_RUST_DESKTOP_X_IMAGE_LATEST   ?= dbndev/vegito-public:debian-rust-desktop-x-latest
export VEGITO_DOCKER_DEBIAN_RUST_DESKTOP_X_IMAGE_VERSION  ?= dbndev/vegito-public:debian-rust-desktop-x-latest

export VEGITO_DOCKER_TRIXIE_DEBIAN_RUST_IMAGE_LATEST            ?= dbndev/vegito-public:debian-rust-latest
export VEGITO_DOCKER_TRIXIE_DEBIAN_RUST_IMAGE_VERSION           ?= dbndev/vegito-public:debian-rust-latest
export VEGITO_DOCKER_TRIXIE_DEBIAN_RUST_DESKTOP_X_IMAGE_LATEST  ?= dbndev/vegito-public:debian-rust-desktop-x-latest
export VEGITO_DOCKER_TRIXIE_DEBIAN_RUST_DESKTOP_X_IMAGE_VERSION ?= dbndev/vegito-public:debian-rust-desktop-x-latest

export LOCAL_BUILDER_X_IMAGE_LATEST  ?= dbndev/vegito-local-public:builder-x-latest
export LOCAL_BUILDER_X_IMAGE_VERSION ?= dbndev/vegito-local-public:builder-x-latest

# Dockerhub replica
export VEGITO_DOCKER_HUB_DEBIAN_IMAGE_LATEST  ?= dbndev/vegito-public:hub-debian-latest
export VEGITO_DOCKER_HUB_DEBIAN_IMAGE_VERSION  ?= dbndev/vegito-public:hub-debian-latest
export VEGITO_DOCKER_HUB_TRIXIE_DEBIAN_IMAGE_LATEST  ?= dbndev/vegito-public:hub-trixie-debian-latest
export VEGITO_DOCKER_HUB_TRIXIE_DEBIAN_IMAGE_VERSION  ?= dbndev/vegito-public:hub-trixie-debian-latest
export VEGITO_DOCKER_HUB_GOLANG_DEBIAN_IMAGE_LATEST  ?= dbndev/vegito-public:hub-debian-golang-latest
export VEGITO_DOCKER_HUB_GOLANG_DEBIAN_IMAGE_VERSION  ?= dbndev/vegito-public:hub-debian-golang-latest
export VEGITO_DOCKER_HUB_GOLANG_DEBIAN_TRIXIE_IMAGE_LATEST  ?= dbndev/vegito-public:hub-trixie-debian-golang-latest
export VEGITO_DOCKER_HUB_GOLANG_DEBIAN_TRIXIE_IMAGE_VERSION ?= dbndev/vegito-public:hub-trixie-debian-golang-latest
export VEGITO_DOCKER_HUB_DIND_ROOTLESS_IMAGE_LATEST  ?= dbndev/vegito-public:hub-docker-dind-rootless-latest
export VEGITO_DOCKER_HUB_DIND_ROOTLESS_IMAGE_VERSION  ?= dbndev/vegito-public:hub-docker-dind-rootless-latest

vegito-docker-login-dockerhub:
	@echo "Logging into Docker Hub"
	@printf '%s' "$$VEGITO_DOCKERHUB_PAT" | docker login \
	  --username "$$VEGITO_DOCKERHUB_USERNAME" \
	  --password-stdin
.PHONY: vegito-docker-login-dockerhub

VEGITO_DOCKERHUB_DOCKER_BUILDX_BUILD_GROUPS ?= \
  tools \
  runners \
  builders \
  services \
  applications

vegito-docker-images-dockerhub-release:
	@echo "🚀 Building for $(@:vegito-docker-images-%=%)"
	@$(MAKE) vegito-docker-images-release \
	  VEGITO_DOCKER_BUILDX_BUILD_GROUPS="$(VEGITO_DOCKERHUB_DOCKER_BUILDX_BUILD_GROUPS)" \
	  VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME=$(VEGITO_DOCKER_HUB_REGISTRY)/$(VEGITO_DOCKER_IMAGES_BASE)-public \
	  VEGITO_DOCKER_PRIVATE_IMAGES_BASE=$(VEGITO_DOCKER_HUB_REGISTRY)/$(VEGITO_DOCKER_IMAGES_BASE)-private \
.PHONY: vegito-docker-images-dockerhub-release

vegito-docker-images-dockerhub-release-ci:
	@echo "🚀 Building for $(@:vegito-docker-images-%-ci=%)"
	@$(MAKE) vegito-docker-images-release-ci \
	  VEGITO_DOCKER_BUILDX_BUILD_GROUPS="$(VEGITO_DOCKERHUB_DOCKER_BUILDX_BUILD_GROUPS)" \
	  VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME=$(VEGITO_DOCKER_HUB_REGISTRY)/$(VEGITO_DOCKER_IMAGES_BASE)-public \
	  VEGITO_DOCKER_PRIVATE_IMAGES_BASE=$(VEGITO_DOCKER_HUB_REGISTRY)/$(VEGITO_DOCKER_IMAGES_BASE)-private \
.PHONY: vegito-docker-images-dockerhub-release-ci
