variable "VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_IMAGE_VERSION" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:trixie-debian-docker-${VERSION}"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_IMAGE_LATEST" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:trixie-debian-docker-latest"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_CACHE_IMAGES_BASE}/trixie-debian-docker"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/trixie-debian-docker-version"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/trixie-debian-docker-latest"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION" {
  description = "local write cache (version)"
  default     = "type=local,mode=max,dest=${VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST" {
  description = "local write cache (latest)"
  default     = "type=local,mode=max,dest=${VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION" {
  description = "local read cache (version)"
  default     = "type=local,src=${VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST" {
  description = "local read cache (latest)"
  default     = "type=local,src=${VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

target "vegito-trixie-debian-docker-base" {
  inherits = ["vegito-debian-docker-base"]
  args = {
    debian_version         = "trixie"
    docker_buildx_version  = DOCKER_BUILDX_VERSION
    docker_compose_version = DOCKER_COMPOSE_VERSION
    docker_version         = DOCKER_VERSION
  }
}

group "vegito-trixie-debian-docker-ci" {
  targets = [
    "vegito-trixie-debian-docker-version-ci",
    "vegito-trixie-debian-docker-latest-ci",

    "vegito-trixie-debian-docker-desktop-x",
  ]
}


group "vegito-trixie-debian-docker-desktop-x-ci" {
  targets = [
    "vegito-trixie-debian-docker-desktop-x-version-ci",
    "vegito-trixie-debian-docker-desktop-x-latest-ci",
  ]
}

target "vegito-trixie-debian-docker-version-ci" {
  inherits = ["vegito-trixie-debian-docker-base"]
  contexts = {
    debian               = "target:vegito-trixie-debian-version-ci"
    debian_golang        = "docker-image://${VEGITO_DOCKER_HUB_GOLANG_DEBIAN_TRIXIE_IMAGE_VERSION}"
    docker_dind_rootless = "docker-image://${VEGITO_DOCKER_HUB_DIND_ROOTLESS_IMAGE_LATEST}"
  }
  tags = [
    VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION
    ] : [],
    [
      VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_IMAGE_LATEST
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION,
    ] : []
  )
  platforms = platforms
}

target "vegito-trixie-debian-docker-latest-ci" {
  inherits = ["vegito-trixie-debian-docker-base"]
  contexts = {
    debian               = "target:vegito-trixie-debian-latest-ci"
    debian_golang        = "docker-image://${VEGITO_DOCKER_HUB_GOLANG_DEBIAN_TRIXIE_IMAGE_LATEST}"
    docker_dind_rootless = "docker-image://${VEGITO_DOCKER_HUB_DIND_ROOTLESS_IMAGE_LATEST}"
  }
  tags = [
    VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_IMAGE_LATEST,
    ]
  )
  cache-to = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_IMAGE_REGISTRY_CACHE},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : [],
    [
      "type=inline"
    ]
  )
  platforms = platforms
}

target "vegito-trixie-debian-docker" {
  inherits = ["vegito-trixie-debian-docker-base"]
  contexts = {
    debian               = "target:vegito-trixie-debian"
    debian_golang        = "docker-image://${VEGITO_DOCKER_HUB_GOLANG_DEBIAN_TRIXIE_IMAGE_LATEST}"
    docker_dind_rootless = "docker-image://${VEGITO_DOCKER_HUB_DIND_ROOTLESS_IMAGE_LATEST}"
  }
  tags = [
    VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_IMAGE_LATEST,
    VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_IMAGE_VERSION
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_IMAGE_LATEST,
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST,
    ] : []
  )
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_DESKTOP_X_IMAGE_VERSION" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:trixie-debian-docker-desktop-x-${VERSION}"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_DESKTOP_X_IMAGE_LATEST" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:trixie-debian-docker-desktop-x-latest"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_DESKTOP_X_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_CACHE_IMAGES_BASE}/trixie-debian-docker-desktop-x"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/trixie-debian-docker-desktop-x-version"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/trixie-debian-docker-desktop-x-latest"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_DESKTOP_X_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION" {
  description = "local write cache (version)"
  default     = "type=local,mode=max,dest=${VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_DESKTOP_X_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST" {
  description = "local write cache (latest)"
  default     = "type=local,mode=max,dest=${VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION" {
  description = "local read cache (version)"
  default     = "type=local,src=${VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST" {
  description = "local read cache (latest)"
  default     = "type=local,src=${VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

target "vegito-trixie-debian-docker-desktop-x-version-ci" {
  contexts = {
    debian               = "target:vegito-trixie-debian-desktop-x-version-ci"
    debian_golang        = "docker-image://${VEGITO_DOCKER_HUB_GOLANG_DEBIAN_TRIXIE_IMAGE_VERSION}"
    docker_dind_rootless = "docker-image://${VEGITO_DOCKER_HUB_DIND_ROOTLESS_IMAGE_VERSION}"
  }
  inherits = ["vegito-trixie-debian-docker-base"]
  tags = [
    VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_DESKTOP_X_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_DESKTOP_X_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION
    ] : [],
    [
      VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_DESKTOP_X_IMAGE_LATEST
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_DESKTOP_X_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION,
    ] : []
  )
  platforms = platforms
}

target "vegito-trixie-debian-docker-desktop-x-latest-ci" {
  inherits = ["vegito-trixie-debian-docker-base"]
  contexts = {
    debian               = "target:vegito-trixie-debian-desktop-x-latest-ci"
    debian_golang        = "docker-image://${VEGITO_DOCKER_HUB_GOLANG_DEBIAN_TRIXIE_IMAGE_LATEST}"
    docker_dind_rootless = "docker-image://${VEGITO_DOCKER_HUB_DIND_ROOTLESS_IMAGE_LATEST}"
  }
  tags = [
    VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_DESKTOP_X_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_DESKTOP_X_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_DESKTOP_X_IMAGE_LATEST,
    ]
  )
  cache-to = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_DESKTOP_X_IMAGE_REGISTRY_CACHE},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_DESKTOP_X_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : [],
    [
      "type=inline"
    ]
  )
  platforms = platforms
}

target "vegito-trixie-debian-docker-desktop-x" {
  inherits = ["vegito-trixie-debian-docker-base"]
  contexts = {
    debian               = "target:vegito-trixie-debian-desktop-x"
    debian_golang        = "docker-image://${VEGITO_DOCKER_HUB_GOLANG_DEBIAN_TRIXIE_IMAGE_LATEST}"
    docker_dind_rootless = "docker-image://${VEGITO_DOCKER_HUB_DIND_ROOTLESS_IMAGE_LATEST}"
  }
  tags = [
    VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_DESKTOP_X_IMAGE_VERSION,
    VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_DESKTOP_X_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_DESKTOP_X_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_DESKTOP_X_IMAGE_LATEST,
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_DOCKER_DESKTOP_X_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST,
    ] : []
  )
}
