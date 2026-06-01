variable "VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DIR" {
  default = "${VEGITO_DOCKER_DEBIAN_DIR}/golang"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_IMAGE_VERSION" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:trixie-debian-golang-${VERSION}"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_IMAGE_LATEST" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:trixie-debian-golang-latest"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_CACHE_IMAGES_BASE}/debian-go"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/trixie-debian-golang-version"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/trixie-debian-golang-latest"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION" {
  description = "local write cache (version)"
  default     = "type=local,mode=max,dest=${VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST" {
  description = "local write cache (latest)"
  default     = "type=local,mode=max,dest=${VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION" {
  description = "local read cache (version)"
  default     = "type=local,src=${VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST" {
  description = "local read cache (latest)"
  default     = "type=local,src=${VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

target "vegito-trixie-debian-golang-base" {
  args = {
    go_version     = GO_VERSION
    debian_version = "trixie"
  }
  context    = VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DIR
  dockerfile = "Dockerfile"
}

group "vegito-trixie-debian-golang" {
  targets = [
    "vegito-trixie-debian-golang",
    "vegito-trixie-debian-golang-docker",
    "vegito-trixie-debian-golang-desktop-x",
  ]
}

group "vegito-trixie-debian-golang-ci" {
  targets = [
    "vegito-trixie-debian-golang-version-ci",
    "vegito-trixie-debian-golang-latest-ci",

    "vegito-trixie-debian-golang-docker-ci",
    "vegito-trixie-debian-golang-desktop-x-ci",
    "vegito-trixie-debian-golang-ai-docker-desktop-x-ci",
  ]
}

target "vegito-trixie-debian-golang-version-ci" {
  inherits = ["vegito-trixie-debian-golang-base"]
  contexts = {
    dockerhub_golang = "docker-image://${VEGITO_DOCKER_HUB_GOLANG_DEBIAN_TRIXIE_IMAGE_LATEST}"
    debian           = "target:vegito-trixie-debian-version-ci"
  }
  tags = [
    VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION
    ] : [],
    [
      VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_IMAGE_LATEST
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION,
    ] : []
  )
  platforms = platforms
}

target "vegito-trixie-debian-golang-latest-ci" {
  inherits = ["vegito-trixie-debian-golang-base"]
  contexts = {
    debian           = "target:vegito-trixie-debian-version-ci"
    dockerhub_golang = "docker-image://${VEGITO_DOCKER_HUB_GOLANG_DEBIAN_TRIXIE_IMAGE_LATEST}"
  }
  tags = [
    VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_IMAGE_LATEST,
    ]
  )
  cache-to = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_IMAGE_REGISTRY_CACHE},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : [],
    [
      "type=inline"
    ]
  )
  platforms = platforms
}

target "vegito-trixie-debian-golang" {
  inherits = ["vegito-trixie-debian-golang-base"]
  contexts = {
    debian           = "target:vegito-trixie-debian-version-ci"
    dockerhub_golang = "docker-image://${VEGITO_DOCKER_HUB_GOLANG_DEBIAN_TRIXIE_IMAGE_LATEST}"
  }
  tags = [
    VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_IMAGE_LATEST,
    VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_IMAGE_VERSION
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_IMAGE_LATEST,
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST,
    ] : []
  )
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DOCKER_IMAGE_VERSION" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:trixie-debian-golang-docker-${VERSION}"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DOCKER_IMAGE_LATEST" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:trixie-debian-golang-docker-latest"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DOCKER_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_CACHE_IMAGES_BASE}/trixie-debian-golang-docker"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/trixie-debian-golang-docker-version"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/trixie-debian-golang-docker-latest"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DOCKER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION" {
  description = "local write cache (version)"
  default     = "type=local,mode=max,dest=${VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DOCKER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST" {
  description = "local write cache (latest)"
  default     = "type=local,mode=max,dest=${VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION" {
  description = "local read cache (version)"
  default     = "type=local,src=${VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST" {
  description = "local read cache (latest)"
  default     = "type=local,src=${VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

group "vegito-trixie-debian-golang-docker-ci" {
  targets = [
    "vegito-trixie-debian-golang-docker-version-ci",
    "vegito-trixie-debian-golang-docker-latest-ci",

    "vegito-trixie-debian-golang-docker-desktop-x-ci",
  ]
}

target "vegito-trixie-debian-golang-docker-version-ci" {
  contexts = {
    dockerhub_golang = "docker-image://${VEGITO_DOCKER_HUB_GOLANG_DEBIAN_TRIXIE_IMAGE_VERSION}"
    debian           = "target:vegito-trixie-debian-docker-version-ci"
  }
  inherits = ["vegito-trixie-debian-golang-base"]
  tags = [
    VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DOCKER_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DOCKER_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION
    ] : [],
    [
      VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DOCKER_IMAGE_LATEST
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DOCKER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION,
    ] : []
  )
  platforms = platforms
}

target "vegito-trixie-debian-golang-docker-latest-ci" {
  inherits = ["vegito-trixie-debian-golang-base"]
  contexts = {
    dockerhub_golang = "docker-image://${VEGITO_DOCKER_HUB_GOLANG_DEBIAN_TRIXIE_IMAGE_LATEST}"
    debian           = "target:vegito-trixie-debian-docker-latest-ci"
  }
  tags = [
    VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DOCKER_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DOCKER_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DOCKER_IMAGE_LATEST,
    ]
  )
  cache-to = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DOCKER_IMAGE_REGISTRY_CACHE},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DOCKER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : [],
    [
      "type=inline"
    ]
  )
  platforms = platforms
}

target "vegito-trixie-debian-golang-docker" {
  inherits = ["vegito-trixie-debian-golang-base"]
  contexts = {
    dockerhub_golang = "docker-image://${VEGITO_DOCKER_HUB_GOLANG_DEBIAN_TRIXIE_IMAGE_LATEST}"
    debian           = "target:vegito-trixie-debian-docker"
  }
  tags = [
    VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DOCKER_IMAGE_VERSION,
    VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DOCKER_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DOCKER_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DOCKER_IMAGE_LATEST,
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DOCKER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST,
    ] : []
  )
}


variable "VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DESKTOP_X_IMAGE_VERSION" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:trixie-debian-golang-desktop-x-${VERSION}"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DESKTOP_X_IMAGE_LATEST" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:trixie-debian-golang-desktop-x-latest"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DESKTOP_X_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_CACHE_IMAGES_BASE}/trixie-debian-golang-desktop-x"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/trixie-debian-golang-desktop-x-version"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/trixie-debian-golang-desktop-x-latest"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DESKTOP_X_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION" {
  description = "local write cache (version)"
  default     = "type=local,mode=max,dest=${VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DESKTOP_X_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST" {
  description = "local write cache (latest)"
  default     = "type=local,mode=max,dest=${VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION" {
  description = "local read cache (version)"
  default     = "type=local,src=${VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST" {
  description = "local read cache (latest)"
  default     = "type=local,src=${VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

group "vegito-trixie-debian-golang-desktop-x-ci" {
  targets = [
    "vegito-trixie-debian-golang-desktop-x-version-ci",
    "vegito-trixie-debian-golang-desktop-x-latest-ci",

  ]
}

target "vegito-trixie-debian-golang-desktop-x-version-ci" {
  contexts = {
    dockerhub_golang = "docker-image://${VEGITO_DOCKER_HUB_GOLANG_DEBIAN_TRIXIE_IMAGE_VERSION}"
    debian           = "target:vegito-trixie-debian-desktop-x-version-ci"
  }
  inherits = ["vegito-trixie-debian-golang-base"]
  tags = [
    VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DESKTOP_X_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DESKTOP_X_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION
    ] : [],
    [
      VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DESKTOP_X_IMAGE_LATEST
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DESKTOP_X_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION,
    ] : []
  )
  platforms = platforms
}

target "vegito-trixie-debian-golang-desktop-x-latest-ci" {
  inherits = ["vegito-trixie-debian-golang-base"]
  contexts = {
    dockerhub_golang = "docker-image://${VEGITO_DOCKER_HUB_GOLANG_DEBIAN_TRIXIE_IMAGE_LATEST}"
    debian           = "target:vegito-trixie-debian-desktop-x-latest-ci"
  }
  tags = [
    VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DESKTOP_X_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DESKTOP_X_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DESKTOP_X_IMAGE_LATEST,
    ]
  )
  cache-to = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DESKTOP_X_IMAGE_REGISTRY_CACHE},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DESKTOP_X_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : [],
    [
      "type=inline"
    ]
  )
  platforms = platforms
}

target "vegito-trixie-debian-golang-desktop-x" {
  inherits = ["vegito-trixie-debian-golang-base"]
  contexts = {
    dockerhub_golang = "docker-image://${VEGITO_DOCKER_HUB_GOLANG_DEBIAN_TRIXIE_IMAGE_LATEST}"
    debian           = "target:vegito-trixie-debian-desktop-x"
  }
  tags = [
    VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DESKTOP_X_IMAGE_VERSION,
    VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DESKTOP_X_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DESKTOP_X_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DESKTOP_X_IMAGE_LATEST,
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DESKTOP_X_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST,
    ] : []
  )
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DOCKER_DESKTOP_X_IMAGE_VERSION" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:trixie-debian-docker-golang-desktop-x-${VERSION}"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DOCKER_DESKTOP_X_IMAGE_LATEST" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:trixie-debian-docker-golang-desktop-x-latest"
}

group "vegito-trixie-debian-golang-docker-desktop-x-ci" {
  targets = [
    "vegito-trixie-debian-golang-docker-desktop-x-version-ci",
    "vegito-trixie-debian-golang-docker-desktop-x-latest-ci",
  ]
}

target "vegito-trixie-debian-golang-docker-desktop-x-version-ci" {
  inherits = ["vegito-trixie-debian-golang-base"]
  contexts = {
    debian           = "target:vegito-trixie-debian-docker-desktop-x-version-ci"
    dockerhub_golang = "docker-image://${VEGITO_DOCKER_HUB_GOLANG_DEBIAN_TRIXIE_IMAGE_VERSION}"
  }
  tags = [
    VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DOCKER_DESKTOP_X_IMAGE_VERSION,
  ]
}

target "vegito-trixie-debian-golang-docker-desktop-x-latest-ci" {
  inherits = ["vegito-trixie-debian-golang-base"]
  contexts = {
    debian           = "target:vegito-trixie-debian-docker-desktop-x-latest-ci"
    dockerhub_golang = "docker-image://${VEGITO_DOCKER_HUB_GOLANG_DEBIAN_TRIXIE_IMAGE_LATEST}"
  }
  tags = [
    VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DOCKER_DESKTOP_X_IMAGE_LATEST,
  ]
}

target "vegito-trixie-debian-golang-docker-desktop-x" {
  inherits = ["vegito-trixie-debian-golang-base"]
  contexts = {
    debian           = "target:vegito-trixie-debian-docker-desktop-x"
    dockerhub_golang = "docker-image://${VEGITO_DOCKER_HUB_GOLANG_DEBIAN_TRIXIE_IMAGE_LATEST}"
  }
  tags = [
    VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DOCKER_DESKTOP_X_IMAGE_LATEST,
    VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_DOCKER_DESKTOP_X_IMAGE_VERSION,
  ]
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_AI_DOCKER_DESKTOP_X_IMAGE_VERSION" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:trixie-debian-golang-ai-docker-desktop-x-${VERSION}"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_AI_DOCKER_DESKTOP_X_IMAGE_LATEST" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:trixie-debian-golang-ai-docker-desktop-x-latest"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_AI_DOCKER_DESKTOP_X_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_CACHE_IMAGES_BASE}/trixie-debian-golang-ai-docker-desktop-x"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_AI_DOCKER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/trixie-debian-golang-ai-docker-desktop-x-version"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_AI_DOCKER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/trixie-debian-golang-ai-docker-desktop-x-latest"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_AI_DOCKER_DESKTOP_X_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION" {
  description = "local write cache (version)"
  default     = "type=local,mode=max,dest=${VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_AI_DOCKER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_AI_DOCKER_DESKTOP_X_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST" {
  description = "local write cache (latest)"
  default     = "type=local,mode=max,dest=${VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_AI_DOCKER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_AI_DOCKER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION" {
  description = "local read cache (version)"
  default     = "type=local,src=${VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_AI_DOCKER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_AI_DOCKER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST" {
  description = "local read cache (latest)"
  default     = "type=local,src=${VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_AI_DOCKER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

group "vegito-trixie-debian-golang-ai-docker-desktop-x-ci" {
  description = "Build and push Android Emmulator images"
  targets = [
    "vegito-trixie-debian-golang-ai-docker-desktop-x-version-ci",
    "vegito-trixie-debian-golang-ai-docker-desktop-x-latest-ci",
  ]
}

target "vegito-trixie-debian-golang-ai-docker-desktop-x-version-ci" {
  inherits = ["vegito-trixie-debian-golang-base"]
  contexts = {
    debian           = "target:vegito-trixie-debian-ai-docker-desktop-x-version-ci"
    dockerhub_golang = "docker-image://${VEGITO_DOCKER_HUB_GOLANG_DEBIAN_TRIXIE_IMAGE_LATEST}"
  }
  tags = [
    VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_AI_DOCKER_DESKTOP_X_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_AI_DOCKER_DESKTOP_X_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_AI_DOCKER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION
    ] : [],
    [
      VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_AI_DOCKER_DESKTOP_X_IMAGE_LATEST
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_AI_DOCKER_DESKTOP_X_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION,
    ] : []
  )
  platforms = platforms
}

target "vegito-trixie-debian-golang-ai-docker-desktop-x-latest-ci" {
  inherits = ["vegito-trixie-debian-golang-base"]
  contexts = {
    debian           = "target:vegito-trixie-debian-ai-docker-desktop-x-latest-ci"
    dockerhub_golang = "docker-image://${VEGITO_DOCKER_HUB_GOLANG_DEBIAN_TRIXIE_IMAGE_LATEST}"
  }
  tags = [
    VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_AI_DOCKER_DESKTOP_X_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_AI_DOCKER_DESKTOP_X_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_AI_DOCKER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_AI_DOCKER_DESKTOP_X_IMAGE_LATEST,
    ]
  )
  cache-to = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_AI_DOCKER_DESKTOP_X_IMAGE_REGISTRY_CACHE},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_AI_DOCKER_DESKTOP_X_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : [],
    [
      "type=inline"
    ]
  )
  platforms = platforms
}

target "vegito-trixie-debian-golang-ai-docker-desktop-x" {
  inherits = ["vegito-trixie-debian-golang-base"]
  contexts = {
    debian           = "target:vegito-trixie-debian-ai-docker-desktop-x"
    dockerhub_golang = "docker-image://${VEGITO_DOCKER_HUB_GOLANG_DEBIAN_TRIXIE_IMAGE_LATEST}"
  }
  tags = [
    VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_AI_DOCKER_DESKTOP_X_IMAGE_VERSION,
    VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_AI_DOCKER_DESKTOP_X_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_AI_DOCKER_DESKTOP_X_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_AI_DOCKER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_AI_DOCKER_DESKTOP_X_IMAGE_LATEST,
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_AI_DOCKER_DESKTOP_X_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST,
    ] : []
  )
}
