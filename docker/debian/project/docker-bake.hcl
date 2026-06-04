variable "VEGITO_DOCKER_DEBIAN_PROJECT_DIR" {
  default = "${VEGITO_DOCKER_DEBIAN_DIR}/project"
}

target "docker-debian-project-builder" {
  contxexts = {
    local = "target:docker-debian-project-local"
  }
}

variable "VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_IMAGE_VERSION" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:debian-project-builder-${VERSION}"
}

variable "VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_X_IMAGE_VERSION" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:debian-project-builder-x-${VERSION}"
}

variable "VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_IMAGE_LATEST" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:debian-project-builder-latest"
}

variable "VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_X_IMAGE_LATEST" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:debian-project-builder-x-latest"
}

variable "VEGITO_LOCAL_CACHE_IMAGES_BASE" {
  default = "${VEGITO_CACHE_REPOSITORY}/vegito-local"
}

variable "VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_LOCAL_CACHE_IMAGES_BASE}/debian-project-builder"
}


variable "VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/debian-project-builder-version"
}

variable "VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/debian-project-builder-latest"
}

variable "VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION" {
  description = "local write cache (version)"
  default     = "type=local,mode=max,dest=${VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST" {
  description = "local write cache (latest)"
  default     = "type=local,mode=max,dest=${VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION" {
  description = "local read cache (version)"
  default     = "type=local,src=${VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST" {
  description = "local read cache (latest)"
  default     = "type=local,src=${VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

group "vegito-debian-project-builders" {
  targets = [
    "vegito-debian-project-builder",
    "vegito-debian-project-builder-x",
  ]
}

group "vegito-debian-project-builders-ci" {
  targets = [
    "vegito-debian-project-builder-ci",
    "vegito-debian-project-builder-x-ci",
  ]
}

group "vegito-debian-project-builder-ci" {
  targets = [
    "vegito-debian-project-builder-version-ci",
    "vegito-debian-project-builder-latest-ci",
  ]
}

group "vegito-debian-project-builder-x-ci" {
  targets = [
    "vegito-debian-project-builder-x-version-ci",
    "vegito-debian-project-builder-x-latest-ci",
  ]
}

group "vegito-debian-golang-project-builder-ci" {
  targets = [
    "vegito-debian-golang-project-builder-version-ci",
    "vegito-debian-golang-project-builder-latest-ci",
  ]
}

group "vegito-debian-golang-project-builder-x-ci" {
  targets = [
    "vegito-debian-golang-project-builder-x-version-ci",
    "vegito-debian-golang-project-builder-x-latest-ci",
  ]
}

target "vegito-debian-project-builder-base" {
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
  context    = VEGITO_DOCKER_DEBIAN_PROJECT_DIR
  dockerfile = "Dockerfile"
}

target "vegito-debian-project-builder-x-version-ci" {
  contexts = {
    debian-golang = "docker-image://${VEGITO_DOCKER_HUB_GOLANG_DEBIAN_IMAGE_VERSION}"
    debian        = "target:vegito-debian-desktop-x-version-ci"
  }
  inherits = ["vegito-debian-project-builder-version-ci"]
  tags = [
    VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_X_IMAGE_VERSION,
  ]
}

target "vegito-debian-project-builder-version-ci" {
  inherits = ["vegito-debian-project-builder-base"]
  contexts = {
    debian-golang = "docker-image://${VEGITO_DOCKER_HUB_GOLANG_DEBIAN_IMAGE_VERSION}"
    debian        = "target:vegito-debian"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION
    ] : [],
    [
      VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_IMAGE_LATEST
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION,
    ] : []
  )
  platforms = platforms
}

target "vegito-debian-project-builder-x-latest-ci" {
  inherits = ["vegito-debian-project-builder-latest-ci"]
  contexts = {
    debian-golang = "docker-image://${VEGITO_DOCKER_DEBIAN_GOLANG_DESKTOP_X_IMAGE_LATEST}"
    debian        = "target:vegito-debian-desktop-x-latest-ci"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_X_IMAGE_LATEST,
  ]
}

target "vegito-debian-project-builder-latest-ci" {
  inherits = ["vegito-debian-project-builder-base"]
  contexts = {
    debian-golang = "docker-image://${VEGITO_DOCKER_HUB_GOLANG_DEBIAN_IMAGE_VERSION}"
    debian        = "target:vegito-debian-latest-ci"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_IMAGE_REGISTR_CACHE}",
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_IMAGE_LATEST,
      VEGITO_DOCKER_DEBIAN_IMAGE_LATEST
    ]
  )
  cache-to = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_IMAGE_REGISTRY_CACHE},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : [],
    [
      "type=inline"
    ]
  )
  platforms = platforms
}

target "vegito-debian-project-builder-x" {
  inherits = ["vegito-debian-project-builder"]
  contexts = {
    debian-golang = "docker-image://${VEGITO_DOCKER_HUB_GOLANG_DEBIAN_IMAGE_VERSION}"
    debian        = "target:vegito-debian-desktop-x"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_X_IMAGE_VERSION,
    VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_X_IMAGE_LATEST,
  ]
}

target "vegito-debian-project-builder" {
  inherits = ["vegito-debian-project-builder-base"]
  contexts = {
    debian-golang = "docker-image://${VEGITO_DOCKER_HUB_GOLANG_DEBIAN_IMAGE_VERSION}"
    debian        = "target:vegito-debian"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_IMAGE_LATEST,
    VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_IMAGE_VERSION
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_IMAGE_REGISTRY_CACHE}",
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_IMAGE_LATEST,
      VEGITO_DOCKER_DEBIAN_IMAGE_LATEST
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST,
    ] : []
  )
}

variable "VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_DOCKER_IMAGE_VERSION" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:debian-project-builder-docker-${VERSION}"
}

variable "VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_DOCKER_X_IMAGE_VERSION" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:debian-project-builder-docker-x-${VERSION}"
}

variable "VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_DOCKER_IMAGE_LATEST" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:debian-project-builder-docker-latest"
}

variable "VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_DOCKER_X_IMAGE_LATEST" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:debian-project-builder-docker-x-latest"
}

variable "VEGITO_LOCAL_CACHE_IMAGES_BASE" {
  default = "${VEGITO_CACHE_REPOSITORY}/vegito-local"
}

variable "VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_DOCKER_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_LOCAL_CACHE_IMAGES_BASE}/debian-project-builder-docker"
}


variable "VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/debian-project-builder-docker-version"
}

variable "VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/debian-project-builder-docker-latest"
}

variable "VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_DOCKER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION" {
  description = "local write cache (version)"
  default     = "type=local,mode=max,dest=${VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_DOCKER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST" {
  description = "local write cache (latest)"
  default     = "type=local,mode=max,dest=${VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION" {
  description = "local read cache (version)"
  default     = "type=local,src=${VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST" {
  description = "local read cache (latest)"
  default     = "type=local,src=${VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

group "vegito-debian-project-builder-docker-ci" {
  targets = [
    "vegito-debian-project-builder-docker-version-ci",
    "vegito-debian-project-builder-docker-latest-ci",
  ]
}

group "vegito-debian-project-builder-docker-x-ci" {
  targets = [
    "vegito-debian-project-builder-docker-x-version-ci",
    "vegito-debian-project-builder-docker-x-latest-ci",
  ]
}

target "vegito-debian-project-builder-docker-x-version-ci" {
  contexts = {
    debian-golang = "docker-image://${VEGITO_DOCKER_HUB_GOLANG_DEBIAN_IMAGE_VERSION}"
    debian        = "target:vegito-debian-docker-desktop-x-version-ci"
  }
  inherits = ["vegito-debian-project-builder-version-ci"]
  tags = [
    VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_DOCKER_X_IMAGE_VERSION,
  ]
}

target "vegito-debian-project-builder-docker-version-ci" {
  inherits = ["vegito-debian-project-builder-base"]
  contexts = {
    debian-golang = "docker-image://${VEGITO_DOCKER_HUB_GOLANG_DEBIAN_IMAGE_VERSION}"
    debian        = "target:vegito-debian-docker-version-ci"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_DOCKER_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_DOCKER_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION
    ] : [],
    [
      VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_DOCKER_IMAGE_LATEST
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_DOCKER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION,
    ] : []
  )
  platforms = platforms
}

target "vegito-debian-project-builder-docker-x-latest-ci" {
  inherits = ["vegito-debian-project-builder-latest-ci"]
  contexts = {
    debian-golang = "docker-image://${VEGITO_DOCKER_DEBIAN_GOLANG_DESKTOP_X_IMAGE_LATEST}"
    debian        = "target:vegito-debian-docker-desktop-x-latest-ci"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_DOCKER_X_IMAGE_LATEST,
  ]
}

target "vegito-debian-project-builder-docker-latest-ci" {
  inherits = ["vegito-debian-project-builder-base"]
  contexts = {
    debian-golang = "docker-image://${VEGITO_DOCKER_HUB_GOLANG_DEBIAN_IMAGE_VERSION}"
    debian        = "target:vegito-debian-docker-latest-ci"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_DOCKER_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_DOCKER_IMAGE_REGISTR_CACHE}",
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_DOCKER_IMAGE_LATEST,
      VEGITO_DOCKER_DEBIAN_IMAGE_LATEST
    ]
  )
  cache-to = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_DOCKER_IMAGE_REGISTRY_CACHE},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_DOCKER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : [],
    [
      "type=inline"
    ]
  )
  platforms = platforms
}

target "vegito-debian-project-builder-docker-x" {
  inherits = ["vegito-debian-project-builder"]
  contexts = {
    debian-golang = "docker-image://${VEGITO_DOCKER_HUB_GOLANG_DEBIAN_IMAGE_VERSION}"
    debian        = "target:vegito-debian-docker-desktop-x"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_DOCKER_X_IMAGE_VERSION,
    VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_DOCKER_X_IMAGE_LATEST,
  ]
}

target "vegito-debian-project-builder-docker" {
  inherits = ["vegito-debian-project-builder-base"]
  contexts = {
    debian-golang = "docker-image://${VEGITO_DOCKER_HUB_GOLANG_DEBIAN_IMAGE_VERSION}"
    debian        = "target:vegito-debian-docker"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_DOCKER_IMAGE_LATEST,
    VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_DOCKER_IMAGE_VERSION
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_DOCKER_IMAGE_REGISTRY_CACHE}",
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_DOCKER_IMAGE_LATEST,
      VEGITO_DOCKER_DEBIAN_IMAGE_LATEST
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_DOCKER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST,
    ] : []
  )
}

variable "VEGITO_DOCKER_DEBIAN_GOLANG_PROJECT_BUILDER_DOCKER_IMAGE_VERSION" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:debian-golang-project-builder-docker-${VERSION}"
}

variable "VEGITO_DOCKER_DEBIAN_GOLANG_PROJECT_BUILDER_DOCKER_X_IMAGE_VERSION" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:debian-golang-project-builder-docker-x-${VERSION}"
}

variable "VEGITO_DOCKER_DEBIAN_GOLANG_PROJECT_BUILDER_DOCKER_IMAGE_LATEST" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:debian-golang-project-builder-docker-latest"
}

variable "VEGITO_DOCKER_DEBIAN_GOLANG_PROJECT_BUILDER_DOCKER_X_IMAGE_LATEST" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:debian-golang-project-builder-docker-x-latest"
}

variable "VEGITO_LOCAL_CACHE_IMAGES_BASE" {
  default = "${VEGITO_CACHE_REPOSITORY}/vegito-local"
}

variable "VEGITO_DOCKER_DEBIAN_GOLANG_PROJECT_BUILDER_DOCKER_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_LOCAL_CACHE_IMAGES_BASE}/debian-golang-project-builder-docker"
}


variable "VEGITO_DOCKER_DEBIAN_GOLANG_PROJECT_BUILDER_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/debian-golang-project-builder-docker-version"
}

variable "VEGITO_DOCKER_DEBIAN_GOLANG_PROJECT_BUILDER_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/debian-golang-project-builder-docker-latest"
}

variable "VEGITO_DOCKER_DEBIAN_GOLANG_PROJECT_BUILDER_DOCKER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION" {
  description = "local write cache (version)"
  default     = "type=local,mode=max,dest=${VEGITO_DOCKER_DEBIAN_GOLANG_PROJECT_BUILDER_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_DOCKER_DEBIAN_GOLANG_PROJECT_BUILDER_DOCKER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST" {
  description = "local write cache (latest)"
  default     = "type=local,mode=max,dest=${VEGITO_DOCKER_DEBIAN_GOLANG_PROJECT_BUILDER_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "VEGITO_DOCKER_DEBIAN_GOLANG_PROJECT_BUILDER_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION" {
  description = "local read cache (version)"
  default     = "type=local,src=${VEGITO_DOCKER_DEBIAN_GOLANG_PROJECT_BUILDER_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_DOCKER_DEBIAN_GOLANG_PROJECT_BUILDER_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST" {
  description = "local read cache (latest)"
  default     = "type=local,src=${VEGITO_DOCKER_DEBIAN_GOLANG_PROJECT_BUILDER_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

group "vegito-debian-golang-project-builder-docker-ci" {
  targets = [
    "vegito-debian-golang-project-builder-docker-version-ci",
    "vegito-debian-golang-project-builder-docker-latest-ci",

    "vegito-debian-golang-project-builder-docker-version-ci",
    "vegito-debian-golang-project-builder-docker-latest-ci"
  ]
}

group "vegito-debian-golang-project-builder-docker-x-ci" {
  targets = [
    "vegito-debian-golang-project-builder-docker-x-version-ci",
    "vegito-debian-golang-project-builder-docker-x-latest-ci",
  ]
}

target "vegito-debian-golang-project-builder-docker-x-version-ci" {
  contexts = {
    debian-golang = "docker-image://${VEGITO_DOCKER_HUB_GOLANG_DEBIAN_IMAGE_VERSION}"
    debian        = "target:vegito-debian-golang-docker-desktop-x-version-ci"
  }
  inherits = ["vegito-debian-project-builder-version-ci"]
  tags = [
    VEGITO_DOCKER_DEBIAN_GOLANG_PROJECT_BUILDER_DOCKER_X_IMAGE_VERSION,
  ]
}

target "vegito-debian-golang-project-builder-docker-version-ci" {
  inherits = ["vegito-debian-project-builder-base"]
  contexts = {
    debian-golang = "docker-image://${VEGITO_DOCKER_HUB_GOLANG_DEBIAN_IMAGE_VERSION}"
    debian        = "target:vegito-debian-golang-docker-version-ci"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_GOLANG_PROJECT_BUILDER_DOCKER_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_GOLANG_PROJECT_BUILDER_DOCKER_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_GOLANG_PROJECT_BUILDER_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION
    ] : [],
    [
      VEGITO_DOCKER_DEBIAN_GOLANG_PROJECT_BUILDER_DOCKER_IMAGE_LATEST
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_GOLANG_PROJECT_BUILDER_DOCKER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION,
    ] : []
  )
  platforms = platforms
}

target "vegito-debian-golang-project-builder-docker-x-latest-ci" {
  inherits = ["vegito-debian-project-builder-latest-ci"]
  contexts = {
    debian-golang = "docker-image://${VEGITO_DOCKER_DEBIAN_GOLANG_DESKTOP_X_IMAGE_LATEST}"
    debian        = "target:vegito-debian-golang-docker-desktop-x-latest-ci"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_GOLANG_PROJECT_BUILDER_DOCKER_X_IMAGE_LATEST,
  ]
}

target "vegito-debian-golang-project-builder-docker-latest-ci" {
  inherits = ["vegito-debian-project-builder-base"]
  contexts = {
    debian-golang = "docker-image://${VEGITO_DOCKER_HUB_GOLANG_DEBIAN_IMAGE_VERSION}"
    debian        = "target:vegito-debian-golang-docker-latest-ci"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_GOLANG_PROJECT_BUILDER_DOCKER_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_GOLANG_PROJECT_BUILDER_DOCKER_IMAGE_REGISTR_CACHE}",
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_GOLANG_PROJECT_BUILDER_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      VEGITO_DOCKER_DEBIAN_GOLANG_PROJECT_BUILDER_DOCKER_IMAGE_LATEST,
      VEGITO_DOCKER_DEBIAN_IMAGE_LATEST
    ]
  )
  cache-to = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_GOLANG_PROJECT_BUILDER_DOCKER_IMAGE_REGISTRY_CACHE},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_GOLANG_PROJECT_BUILDER_DOCKER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : [],
    [
      "type=inline"
    ]
  )
  platforms = platforms
}

target "vegito-debian-golang-project-builder-docker-x" {
  inherits = ["vegito-debian-project-builder"]
  contexts = {
    debian-golang = "docker-image://${VEGITO_DOCKER_HUB_GOLANG_DEBIAN_IMAGE_VERSION}"
    debian        = "target:vegito-debian-golang-docker-desktop-x"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_GOLANG_PROJECT_BUILDER_DOCKER_X_IMAGE_VERSION,
    VEGITO_DOCKER_DEBIAN_GOLANG_PROJECT_BUILDER_DOCKER_X_IMAGE_LATEST,
  ]
}

target "vegito-debian-golang-project-builder-docker" {
  inherits = ["vegito-debian-project-builder-base"]
  contexts = {
    debian-golang = "docker-image://${VEGITO_DOCKER_HUB_GOLANG_DEBIAN_IMAGE_VERSION}"
    debian        = "target:vegito-debian-golang-docker"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_GOLANG_PROJECT_BUILDER_DOCKER_IMAGE_LATEST,
    VEGITO_DOCKER_DEBIAN_GOLANG_PROJECT_BUILDER_DOCKER_IMAGE_VERSION
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_GOLANG_PROJECT_BUILDER_DOCKER_IMAGE_REGISTRY_CACHE}",
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_GOLANG_PROJECT_BUILDER_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      VEGITO_DOCKER_DEBIAN_GOLANG_PROJECT_BUILDER_DOCKER_IMAGE_LATEST,
      VEGITO_DOCKER_DEBIAN_IMAGE_LATEST
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_GOLANG_PROJECT_BUILDER_DOCKER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST,
    ] : []
  )
}
