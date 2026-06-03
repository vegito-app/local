variable "VEGITO_DOCKER_DEBIAN_AI_DIR" {
  default = "${VEGITO_DOCKER_DEBIAN_DIR}/ai"
}

variable "VEGITO_DOCKER_DEBIAN_AI_VERSION" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:debian-ai-${VERSION}"
}

variable "VEGITO_DOCKER_DEBIAN_AI_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_CACHE_IMAGES_BASE}/vegito-debian-ai"
}

variable "VEGITO_DOCKER_DEBIAN_AI_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/debian-ai-version"
}

variable "VEGITO_DOCKER_DEBIAN_AI_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/debian-ai-latest"
}

variable "VEGITO_DOCKER_DEBIAN_AI_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION" {
  description = "local write cache for vegito-debian-ai version image build"
  default     = "type=local,mode=max,dest=${VEGITO_DOCKER_DEBIAN_AI_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_DOCKER_DEBIAN_AI_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST" {
  description = "local write cache for vegito-debian-ai latest image build"
  default     = "type=local,mode=max,dest=${VEGITO_DOCKER_DEBIAN_AI_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "VEGITO_DOCKER_DEBIAN_AI_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION" {
  description = "local read cache for vegito-debian-ai version image build (cannot be used before first write)"
  default     = "type=local,src=${VEGITO_DOCKER_DEBIAN_AI_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_DOCKER_DEBIAN_AI_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST" {
  description = "local read cache for vegito-debian-ai latest image build (cannot be used before first write)"
  default     = "type=local,src=${VEGITO_DOCKER_DEBIAN_AI_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "VEGITO_DOCKER_DEBIAN_AI_IMAGE_LATEST" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:debian-ai-latest"
}

variable "VEGITO_DOCKER_DEBIAN_AI_IMAGE_VERSION" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:debian-ai-${VERSION}"
}

group "vegito-debian-ai-ci" {
  description = "Build and push Android Emmulator images"
  targets = [
    "vegito-debian-ai-version-ci",
    "vegito-debian-ai-latest-ci",
  ]
}

target "vegito-debian-ai-base" {
  context = VEGITO_DOCKER_DEBIAN_AI_DIR
  args = {
    debian_version = "trixie"
  }
}

target "vegito-debian-ai-version-ci" {
  inherits = ["vegito-debian-ai-base"]
  contexts = {
    debian = "target:vegito-debian-python-version-ci"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_AI_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_AI_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_AI_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION
    ] : [],
    [
      VEGITO_DOCKER_DEBIAN_AI_IMAGE_LATEST
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_AI_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION
    ] : []
  )
  platforms = platforms
}

target "vegito-debian-ai-latest-ci" {
  inherits = ["vegito-debian-ai-base"]
  contexts = {
    debian = "target:vegito-debian-python-latest-ci"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_AI_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_AI_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_AI_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      VEGITO_DOCKER_DEBIAN_AI_IMAGE_LATEST,
    ]
  )
  cache-to = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_AI_IMAGE_REGISTRY_CACHE},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_AI_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : [],
    [
      "type=inline"
    ]
  )
  platforms = platforms
}

target "vegito-debian-ai" {

  inherits = ["vegito-debian-ai-base"]
  contexts = {
    debian = "target:vegito-debian-python-version-ci"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_AI_IMAGE_LATEST,
    VEGITO_DOCKER_DEBIAN_AI_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_AI_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_AI_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      VEGITO_DOCKER_DEBIAN_AI_IMAGE_LATEST,
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_AI_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : []
  )
}

variable "VEGITO_DOCKER_DEBIAN_AI_DESKTOP_X_IMAGE_VERSION" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:debian-ai-desktop-x-${VERSION}"
}

variable "VEGITO_DOCKER_DEBIAN_AI_DESKTOP_X_IMAGE_LATEST" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:debian-ai-desktop-x-latest"
}

variable "VEGITO_DOCKER_DEBIAN_AI_DESKTOP_X_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_CACHE_IMAGES_BASE}/debian-ai-desktop-x"
}

variable "VEGITO_DOCKER_DEBIAN_AI_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/debian-ai-desktop-x-version"
}

variable "VEGITO_DOCKER_DEBIAN_AI_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/debian-ai-desktop-x-latest"
}

variable "VEGITO_DOCKER_DEBIAN_AI_DESKTOP_X_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION" {
  description = "local write cache (version)"
  default     = "type=local,mode=max,dest=${VEGITO_DOCKER_DEBIAN_AI_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_DOCKER_DEBIAN_AI_DESKTOP_X_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST" {
  description = "local write cache (latest)"
  default     = "type=local,mode=max,dest=${VEGITO_DOCKER_DEBIAN_AI_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "VEGITO_DOCKER_DEBIAN_AI_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION" {
  description = "local read cache (version)"
  default     = "type=local,src=${VEGITO_DOCKER_DEBIAN_AI_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_DOCKER_DEBIAN_AI_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST" {
  description = "local read cache (latest)"
  default     = "type=local,src=${VEGITO_DOCKER_DEBIAN_AI_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

target "vegito-debian-ai-desktop-x-version-ci" {
  inherits = ["vegito-debian-ai-base"]
  contexts = {
    debian = "target:vegito-debian-python-desktop-x-version-ci"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_AI_DESKTOP_X_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_AI_DESKTOP_X_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_AI_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION
    ] : [],
    [
      VEGITO_DOCKER_DEBIAN_AI_DESKTOP_X_IMAGE_LATEST
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_AI_DESKTOP_X_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION,
    ] : []
  )
  platforms = platforms
}

target "vegito-debian-ai-desktop-x-latest-ci" {
  inherits = ["vegito-debian-ai-base"]
  contexts = {
    debian = "target:vegito-debian-python-desktop-x-latest-ci"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_AI_DESKTOP_X_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_AI_DESKTOP_X_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_AI_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      VEGITO_DOCKER_DEBIAN_AI_DESKTOP_X_IMAGE_LATEST,
    ]
  )
  cache-to = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_AI_DESKTOP_X_IMAGE_REGISTRY_CACHE},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_AI_DESKTOP_X_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : [],
    [
      "type=inline"
    ]
  )
  platforms = platforms
}

target "vegito-debian-ai-desktop-x" {
  inherits = ["vegito-debian-ai-base"]
  contexts = {
    debian = "target:vegito-debian-python-desktop-x"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_AI_DESKTOP_X_IMAGE_VERSION,
    VEGITO_DOCKER_DEBIAN_AI_DESKTOP_X_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_AI_DESKTOP_X_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_AI_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      VEGITO_DOCKER_DEBIAN_AI_DESKTOP_X_IMAGE_LATEST,
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_AI_DESKTOP_X_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST,
    ] : []
  )
}

variable "VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_VERSION" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:debian-ai-docker-${VERSION}"
}

variable "VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_LATEST" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:debian-ai-docker-latest"
}

variable "VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_CACHE_IMAGES_BASE}/debian-ai-docker"
}

variable "VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/debian-ai-docker-version"
}

variable "VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/debian-ai-docker-latest"
}

variable "VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION" {
  description = "local write cache (version)"
  default     = "type=local,mode=max,dest=${VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST" {
  description = "local write cache (latest)"
  default     = "type=local,mode=max,dest=${VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION" {
  description = "local read cache (version)"
  default     = "type=local,src=${VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST" {
  description = "local read cache (latest)"
  default     = "type=local,src=${VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

target "vegito-debian-ai-docker-version-ci" {
  inherits = ["vegito-debian-ai-base"]
  contexts = {
    debian = "target:vegito-debian-python-desktop-x-version-ci"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION
    ] : [],
    [
      VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_LATEST
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION,
    ] : []
  )
  platforms = platforms
}

target "vegito-debian-ai-docker-latest-ci" {
  inherits = ["vegito-debian-ai-base"]
  contexts = {
    debian = "target:vegito-debian-python-desktop-x-latest-ci"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_LATEST,
    ]
  )
  cache-to = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_REGISTRY_CACHE},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : [],
    [
      "type=inline"
    ]
  )
  platforms = platforms
}

target "vegito-debian-ai-docker" {
  inherits = ["vegito-debian-ai-base"]
  contexts = {
    debian = "target:vegito-debian-python-docker"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_VERSION,
    VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_LATEST,
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST,
    ] : []
  )
}

variable "VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_VERSION" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:debian-ai-docker-desktop-x-${VERSION}"
}

variable "VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_LATEST" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:debian-ai-docker-desktop-x-latest"
}

variable "VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_CACHE_IMAGES_BASE}/debian-ai-docker-desktop-x"
}

variable "VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/debian-ai-docker-desktop-x-version"
}

variable "VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/debian-ai-docker-desktop-x-latest"
}

variable "VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION" {
  description = "local write cache (version)"
  default     = "type=local,mode=max,dest=${VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST" {
  description = "local write cache (latest)"
  default     = "type=local,mode=max,dest=${VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION" {
  description = "local read cache (version)"
  default     = "type=local,src=${VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST" {
  description = "local read cache (latest)"
  default     = "type=local,src=${VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

target "vegito-debian-ai-docker-desktop-x-version-ci" {
  inherits = ["vegito-debian-ai-base"]
  contexts = {
    debian = "target:vegito-debian-python-docker-desktop-x-version-ci"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION
    ] : [],
    [
      VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_LATEST
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION,
    ] : []
  )
  platforms = platforms
}

target "vegito-debian-ai-docker-desktop-x-latest-ci" {
  inherits = ["vegito-debian-ai-base"]
  contexts = {
    debian = "target:vegito-debian-python-docker-desktop-x-latest-ci"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_LATEST,
    ]
  )
  cache-to = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_REGISTRY_CACHE},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : [],
    [
      "type=inline"
    ]
  )
  platforms = platforms
}

target "vegito-debian-ai-docker-desktop-x" {
  inherits = ["vegito-debian-ai-base"]
  contexts = {
    debian = "target:vegito-debian-python-docker-desktop-x"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_VERSION,
    VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_LATEST,
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_AI_DOCKER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST,
    ] : []
  )
}
