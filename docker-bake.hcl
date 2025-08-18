variable "LOCAL_BUILDER_IMAGE_VERSION" {
  default = notequal("latest", LOCAL_VERSION) ? "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:builder-${LOCAL_VERSION}" : ""
}

variable "LOCAL_BUILDER_IMAGE_LATEST" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:builder-latest"
}

variable "LOCAL_DIR" {
  default = "."
}

variable "LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_CACHE_WRITE" {
  description = "local write cache for builder image build"
}

variable "LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  description = "local read cache for builder image build (cannot be used before first write)"
}

variable "LOCAL_BUILDER_REGISTRY_CACHE_IMAGE" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}/cache/builder"
}

target "builder-ci" {
  args = {
    docker_buildx_version  = DOCKER_BUILDX_VERSION
    docker_compose_version = DOCKER_COMPOSE_VERSION
    docker_version         = DOCKER_VERSION
    go_version             = GO_VERSION
    k9s_version            = K9S_VERSION
    kubectl_version        = KUBECTL_VERSION
    node_version           = NODE_VERSION
    nvm_version            = NVM_VERSION
    oh_my_zsh_version      = OH_MY_ZSH_VERSION
    terraform_version      = TERRAFORM_VERSION
  }
  context = LOCAL_DIR
  dockerfile = "Dockerfile"
  tags = [
    LOCAL_BUILDER_IMAGE_LATEST,
    notequal("", LOCAL_VERSION) ? LOCAL_BUILDER_IMAGE_VERSION : "",
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_BUILDER_REGISTRY_CACHE_IMAGE}" : LOCAL_BUILDER_IMAGE_LATEST,
    LOCAL_BUILDER_IMAGE_LATEST,
    LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_BUILDER_REGISTRY_CACHE_IMAGE},mode=max" : "type=inline"
  ]
  platforms  = platforms
}

target "builder" {
  args = {
    docker_buildx_version  = DOCKER_BUILDX_VERSION
    docker_compose_version = DOCKER_COMPOSE_VERSION
    docker_version         = DOCKER_VERSION
    go_version             = GO_VERSION
    k9s_version            = K9S_VERSION
    kubectl_version        = KUBECTL_VERSION
    oh_my_zsh_version      = OH_MY_ZSH_VERSION
    node_version           = NODE_VERSION
    nvm_version            = NVM_VERSION
    terraform_version      = TERRAFORM_VERSION
  }
  context = LOCAL_DIR
  dockerfile = "Dockerfile"
  tags = [
    LOCAL_BUILDER_IMAGE_LATEST,
    notequal("", LOCAL_VERSION) ? LOCAL_BUILDER_IMAGE_VERSION : "",
  ]
  cache-from = [
    LOCAL_BUILDER_IMAGE_LATEST,
    LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
  ]
  cache-to = [
    LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_CACHE_WRITE
  ]
}
