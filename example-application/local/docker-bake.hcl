variable "USE_REGISTRY_CACHE" {
  default = false
}
variable "VEGITO_LOCAL_PUBLIC_IMAGES_BASE" {
  default = "${VEGITO_PUBLIC_REPOSITORY}/vegito-local"
}

variable "VEGITO_LOCAL_PRIVATE_IMAGES_BASE" {
  default = "${VEGITO_PRIVATE_REPOSITORY}/vegito-local"
}

variable "LOCAL_BUILDER_IMAGE_VERSION" {
  default = notequal("latest", VERSION) ? "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:builder-${VERSION}" : ""
}

variable "LOCAL_BUILDER_IMAGE_LATEST" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:builder-latest"
}

variable "LOCAL_BUILDER_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}/cache/builder"
}

variable "LOCAL_BUILDER_IMAGE_REGISTRY_CACHE_CI" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}/cache/builder/ci"
}

variable "LOCAL_VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/vault-dev"
}

variable "LOCAL_VAULT_DEV_IMAGE_DOCKER_BUILDX_CACHE_WRITE" {
  description = "local write cache for clarinet image build"
  default     = "type=local,mode=max,dest=${LOCAL_VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "LOCAL_VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  description = "local read cache for clarinet image build (cannot be used before first write)"
  default     = "type=local,src=${LOCAL_VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "LOCAL_DIR" {
  default = "."
}

target "local-project-builder-ci" {
  args = {
    debian_image           = DEBIAN_IMAGE_VERSION
    docker_buildx_version  = DOCKER_BUILDX_VERSION
    docker_compose_version = DOCKER_COMPOSE_VERSION
    docker_version         = DOCKER_VERSION
    gitleaks_version       = GITLEAKS_VERSION
    go_image               = GO_IMAGE_VERSION
    go_version             = GO_VERSION
    k9s_version            = K9S_VERSION
    kubectl_version        = KUBECTL_VERSION
    node_version           = NODE_VERSION
    nvm_version            = NVM_VERSION
    oh_my_zsh_version      = OH_MY_ZSH_VERSION
    terraform_version      = TERRAFORM_VERSION
  }
  context    = LOCAL_DIR
  dockerfile = "Dockerfile"
  tags = [
    LOCAL_BUILDER_IMAGE_LATEST,
    notequal("", VERSION) ? LOCAL_BUILDER_IMAGE_VERSION : "",
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_BUILDER_IMAGE_REGISTRY_CACHE_CI}" : "",
    "type=inline,ref=${LOCAL_BUILDER_IMAGE_LATEST}",
    LOCAL_VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
  ]
  cache-to = [
    # USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_BUILDER_IMAGE_REGISTRY_CACHE_CI},mode=max" : "type=inline"
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_BUILDER_IMAGE_REGISTRY_CACHE_CI},mode=max" : LOCAL_VAULT_DEV_IMAGE_DOCKER_BUILDX_CACHE_WRITE
  ]
  platforms = platforms
}

target "local-project-builder" {
  args = {
    docker_buildx_version  = DOCKER_BUILDX_VERSION
    docker_compose_version = DOCKER_COMPOSE_VERSION
    docker_version         = DOCKER_VERSION
    gitleaks_version       = GITLEAKS_VERSION
    debian_image           = DEBIAN_IMAGE_LATEST
    go_image               = GO_IMAGE_LATEST
    go_version             = GO_VERSION
    k9s_version            = K9S_VERSION
    kubectl_version        = KUBECTL_VERSION
    node_version           = NODE_VERSION
    nvm_version            = NVM_VERSION
    oh_my_zsh_version      = OH_MY_ZSH_VERSION
    terraform_version      = TERRAFORM_VERSION
  }
  context    = LOCAL_DIR
  dockerfile = "Dockerfile"
  tags = [
    LOCAL_BUILDER_IMAGE_LATEST,
    notequal("", VERSION) ? LOCAL_BUILDER_IMAGE_VERSION : "",
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_BUILDER_IMAGE_REGISTRY_CACHE}" : "",
    LOCAL_VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
    "type=inline,ref=${LOCAL_BUILDER_IMAGE_LATEST}",
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_BUILDER_IMAGE_REGISTRY_CACHE},mode=max" : LOCAL_VAULT_DEV_IMAGE_DOCKER_BUILDX_CACHE_WRITE
  ]
}
