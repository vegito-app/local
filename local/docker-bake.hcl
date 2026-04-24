variable "VEGITO_LOCAL_PUBLIC_IMAGES_BASE" {
  default = "${VEGITO_PUBLIC_REPOSITORY}/vegito-local"
}

variable "VEGITO_LOCAL_PRIVATE_IMAGES_BASE" {
  default = "${VEGITO_PRIVATE_REPOSITORY}/vegito-local"
}

variable "LOCAL_BUILDER_IMAGE_VERSION" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:builder-${VERSION}"
}

variable "LOCAL_BUILDER_IMAGE_LATEST" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:builder-latest"
}

variable "LOCAL_BUILDER_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_LOCAL_CACHE_IMAGES_BASE}/builder"
}

variable "LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/builder-version"
}

variable "LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/builder-latest"
}

variable "LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION" {
  description = "local write cache (version)"
  default     = "type=local,mode=max,dest=${LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST" {
  description = "local write cache (latest)"
  default     = "type=local,mode=max,dest=${LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION" {
  description = "local read cache (version)"
  default     = "type=local,src=${LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST" {
  description = "local read cache (latest)"
  default     = "type=local,src=${LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "LOCAL_DIR" {
  default = "."
}

group "local-project-builder-ci" {
  targets = [
    "local-project-builder-version-ci",
    "local-project-builder-latest-ci",
  ]
}

target "local-project-builder-version-ci" {
  contexts = {
    debian = "docker-image://${LOCAL_DEBIAN_IMAGE_VERSION}"
    go     = "docker-image://${LOCAL_GO_IMAGE_VERSION}"
  }
  args = {
    docker_buildx_version  = DOCKER_BUILDX_VERSION
    docker_compose_version = DOCKER_COMPOSE_VERSION
    docker_version         = DOCKER_VERSION
    gitleaks_version       = GITLEAKS_VERSION
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
    LOCAL_BUILDER_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_BUILDER_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION
    ] : [],
    [
      "type=inline,ref=${LOCAL_BUILDER_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION,
    ] : []
  )
  platforms = platforms
}

target "local-project-builder-latest-ci" {
  contexts = {
    debian = "docker-image://${LOCAL_DEBIAN_IMAGE_LATEST}"
    go     = "docker-image://${LOCAL_GO_IMAGE_LATEST}"
  }
  args = {
    docker_buildx_version  = DOCKER_BUILDX_VERSION
    docker_compose_version = DOCKER_COMPOSE_VERSION
    docker_version         = DOCKER_VERSION
    gitleaks_version       = GITLEAKS_VERSION
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
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_BUILDER_IMAGE_REGISTRY_CACHE}",
      "type=registry,ref=${LOCAL_DEBIAN_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      "type=inline,ref=${LOCAL_BUILDER_IMAGE_LATEST}",
      "type=inline,ref=${LOCAL_DEBIAN_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_BUILDER_IMAGE_REGISTRY_CACHE},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : [],
    [
      "type=inline"
    ]
  )
  platforms = platforms
}

target "local-project-builder" {
  contexts = {
    debian = "docker-image://${LOCAL_DEBIAN_IMAGE_VERSION}"
    go     = "docker-image://${LOCAL_GO_IMAGE_VERSION}"
  }
  args = {
    docker_buildx_version  = DOCKER_BUILDX_VERSION
    docker_compose_version = DOCKER_COMPOSE_VERSION
    docker_version         = DOCKER_VERSION
    gitleaks_version       = GITLEAKS_VERSION
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
    LOCAL_BUILDER_IMAGE_VERSION
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_BUILDER_IMAGE_REGISTRY_CACHE}",
      "type=registry,ref=${LOCAL_DEBIAN_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      "type=inline,ref=${LOCAL_BUILDER_IMAGE_LATEST}",
      "type=inline,ref=${LOCAL_DEBIAN_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST,
    ] : []
  )
}
