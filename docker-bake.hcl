variable "USE_REGISTRY_CACHE" {
  default = false
}
variable "ENABLE_LOCAL_CACHE" {
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
  default = "${VEGITO_LOCAL_CACHE_IMAGES_BASE}/builder"
}

variable "LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/builder"
}

variable "LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_CACHE_WRITE" {
  description = "local write cache for clarinet image build"
  default     = "type=local,mode=max,dest=${LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  description = "local read cache for clarinet image build (cannot be used before first write)"
  default     = "type=local,src=${LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "LOCAL_DIR" {
  default = "."
}

target "local-builder-ci" {
  contexts = {
    debian = "target:local-debian-ci"
    go     = "target:local-golang-alpine-ci"
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
    [
      "type=inline,ref=${LOCAL_BUILDER_IMAGE_LATEST}"
    ]
  )
  cache-to  = []
  platforms = platforms
}

target "local-builder-latest-ci" {
  contexts = {
    debian = "target:local-debian-latest-ci"
    go     = "target:local-golang-alpine-latest-ci"
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
    [
      "type=inline,ref=${LOCAL_BUILDER_IMAGE_LATEST}",
      "type=inline,ref=${LOCAL_DEBIAN_IMAGE_LATEST}"
    ]
  )
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_BUILDER_IMAGE_REGISTRY_CACHE},mode=max" : "type=inline",
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_DEBIAN_IMAGE_REGISTRY_CACHE},mode=max" : "type=inline"
  ]
  platforms = platforms
}

target "local-builder" {
  contexts = {
    debian = "target:local-debian"
    go     = "target:local-golang-alpine"
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
    ENABLE_LOCAL_CACHE ? [
      LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_BUILDER_IMAGE_REGISTRY_CACHE}",
      "type=registry,ref=${LOCAL_DEBIAN_IMAGE_REGISTRY_CACHE}"
    ] : [],
    [
      "type=inline,ref=${LOCAL_BUILDER_IMAGE_LATEST}",
      "type=inline,ref=${LOCAL_DEBIAN_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE,
      LOCAL_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE
    ] : []
  )
}
