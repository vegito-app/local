variable "BUILDER_IMAGE_VERSION" {
  default = notequal("dev", LOCAL_VERSION) ? "${PUBLIC_IMAGES_BASE}:builder-${LOCAL_VERSION}" : ""
}

variable "LATEST_BUILDER_IMAGE" {
  default = "${PUBLIC_IMAGES_BASE}:builder-latest"
}
variable "LOCAL_DIR" {
  default = "."
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
    LATEST_BUILDER_IMAGE,
    notequal("", LOCAL_VERSION) ? BUILDER_IMAGE_VERSION : "",
  ]
  cache-from = [LATEST_BUILDER_IMAGE]
  cache-to   = ["type=inline"]
  platforms  = platforms
}

variable "LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE" {
  description = "local write cache for builder image build"
}

variable "LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  description = "local read cache for builder image build (cannot be used before first write)"
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
    LATEST_BUILDER_IMAGE,
    notequal("", LOCAL_VERSION) ? BUILDER_IMAGE_VERSION : "",
  ]
  cache-from = [
    LATEST_BUILDER_IMAGE,
    LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
  ]
  cache-to = [
    LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE
  ]
}
