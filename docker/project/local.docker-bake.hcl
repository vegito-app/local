variable "VEGITO_DOCKER_PROJECT_DIR" {
  default = "${VEGITO_DOCKER_DIR}/project"

}

target "docker-project-local-builder" {
  contxexts = {
    local = "target:docker-project-local"
  }

}

variable "VEGITO_DOCKER_LOCAL_BUILDER_IMAGE_VERSION" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME}:builder-${VERSION}"
}

variable "VEGITO_DOCKER_LOCAL_BUILDER_X_IMAGE_VERSION" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME}:builder-x-${VERSION}"
}

variable "VEGITO_DOCKER_LOCAL_BUILDER_IMAGE_LATEST" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME}:builder-latest"
}

variable "VEGITO_DOCKER_LOCAL_BUILDER_X_IMAGE_LATEST" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME}:builder-x-latest"
}

variable "VEGITO_LOCAL_CACHE_IMAGES_BASE" {
  default = "${VEGITO_CACHE_REPOSITORY}/vegito-local"
}

variable "VEGITO_DOCKER_LOCAL_BUILDER_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_LOCAL_CACHE_IMAGES_BASE}/builder"
}


variable "VEGITO_DOCKER_LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/builder-version"
}

variable "VEGITO_DOCKER_LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/builder-latest"
}

variable "VEGITO_DOCKER_LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION" {
  description = "local write cache (version)"
  default     = "type=local,mode=max,dest=${VEGITO_DOCKER_LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_DOCKER_LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST" {
  description = "local write cache (latest)"
  default     = "type=local,mode=max,dest=${VEGITO_DOCKER_LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "VEGITO_DOCKER_LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION" {
  description = "local read cache (version)"
  default     = "type=local,src=${VEGITO_DOCKER_LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_DOCKER_LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST" {
  description = "local read cache (latest)"
  default     = "type=local,src=${VEGITO_DOCKER_LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "LOCAL_DIR" {
  default = "."
}

group "local-project-builders" {
  targets = [
    "local-project-builder",
    "local-project-builder-x",
  ]
}

group "local-project-builders-ci" {
  targets = [
    "local-project-builder-ci",
    "local-project-builder-x-ci",
  ]
}

group "local-project-builder-ci" {
  targets = [
    "local-project-builder-version-ci",
    "local-project-builder-latest-ci",
  ]
}

group "local-project-builder-x-ci" {
  targets = [
    "local-project-builder-x-version-ci",
    "local-project-builder-x-latest-ci",
  ]
}

target "local-project-builder-x-version-ci" {
  contexts = {
    debian = "docker-image://${VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DESKTOP_X_IMAGE_VERSION}"
  }
  inherits = ["local-project-builder-version-ci"]
  tags = [
    VEGITO_DOCKER_LOCAL_BUILDER_X_IMAGE_VERSION,
  ]
}

target "local-project-builder-version-ci" {
  inherits = ["local-project-builder-base"]
  contexts = {
    debian-golang = "docker-image://${VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DESKTOP_X_IMAGE_VERSION}"
  }
  tags = [
    VEGITO_DOCKER_LOCAL_BUILDER_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_LOCAL_BUILDER_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION
    ] : [],
    [
      VEGITO_DOCKER_LOCAL_BUILDER_IMAGE_LATEST
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION,
    ] : []
  )
  platforms = platforms
}

target "local-project-builder-x-latest-ci" {
  inherits = ["local-project-builder-latest-ci"]
  contexts = {
    debian-golang = "docker-image://${VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DESKTOP_X_IMAGE_LATEST}"
  }
  tags = [
    VEGITO_DOCKER_LOCAL_BUILDER_X_IMAGE_LATEST,
  ]
}

target "local-project-builder-latest-ci" {
  inherits = ["local-project-builder-base"]
  contexts = {
    debian-golang = "docker-image://${VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DESKTOP_X_IMAGE_VERSION}"
  }
  tags = [
    VEGITO_DOCKER_LOCAL_BUILDER_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_LOCAL_BUILDER_IMAGE_REGISTR_CACHE}",
      "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      VEGITO_DOCKER_LOCAL_BUILDER_IMAGE_LATEST,
      VEGITO_DOCKER_TRIXIE_DEBIAN_IMAGE_LATEST
    ]
  )
  cache-to = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_LOCAL_BUILDER_IMAGE_REGISTRY_CACHE},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : [],
    [
      "type=inline"
    ]
  )
  platforms = platforms
}

target "local-project-builder-x" {
  inherits = ["local-project-builder"]
  contexts = {
    debian-golang = "docker-image://${VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DESKTOP_X_IMAGE_VERSION}"
  }
  tags = [
    VEGITO_DOCKER_LOCAL_BUILDER_X_IMAGE_VERSION,
    VEGITO_DOCKER_LOCAL_BUILDER_X_IMAGE_LATEST,
  ]
}

target "local-project-builder" {
  inherits = ["local-project-builder-base"]
  contexts = {
    debian-golang = "docker-image://${VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DESKTOP_X_IMAGE_VERSION}"
  }
  tags = [
    VEGITO_DOCKER_LOCAL_BUILDER_IMAGE_LATEST,
    VEGITO_DOCKER_LOCAL_BUILDER_IMAGE_VERSION
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_LOCAL_BUILDER_IMAGE_REGISTRY_CACHE}",
      "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      VEGITO_DOCKER_LOCAL_BUILDER_IMAGE_LATEST,
      VEGITO_DOCKER_TRIXIE_DEBIAN_IMAGE_LATEST
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST,
    ] : []
  )
}

target "local-project-builder-base" {
  args = {
    debian_version         = "trixie"
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
}
