variable "VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_IMAGE_VERSION" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:debian-kubernetes-${VERSION}"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_IMAGE_LATEST" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:debian-kubernetes-latest"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_CACHE_IMAGES_BASE}/debian-kubernetes"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/debian-kubernetes-version"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/debian-kubernetes-latest"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION" {
  description = "local write cache (version)"
  default     = "type=local,mode=max,dest=${VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST" {
  description = "local write cache (latest)"
  default     = "type=local,mode=max,dest=${VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION" {
  description = "local read cache (version)"
  default     = "type=local,src=${VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST" {
  description = "local read cache (latest)"
  default     = "type=local,src=${VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

target "vegito-trixie-debian-kubernetes-base" {
  inherits = ["vegito-debian-kubernetes-base"]
}

group "vegito-trixie-debian-kubernetes" {
  targets = [
    "vegito-trixie-debian-kubernetes",
    "vegito-trixie-debian-kubernetes-desktop-x",
  ]
}

group "vegito-trixie-debian-kubernetes-ci" {
  targets = [
    "vegito-trixie-debian-kubernetes-version-ci",
    "vegito-trixie-debian-kubernetes-latest-ci",

    "vegito-trixie-debian-kubernetes-desktop-x-version-ci",
    "vegito-trixie-debian-kubernetes-desktop-x-latest-ci",
  ]
}

target "vegito-trixie-debian-kubernetes-version-ci" {
  inherits = ["vegito-trixie-debian-kubernetes-base"]
  contexts = {
    debian = "target:vegito-trixie-debian-version-ci"
  }
  tags = [
    VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION
    ] : [],
    [
      VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_IMAGE_LATEST
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION,
    ] : []
  )
  platforms = platforms
}

target "vegito-trixie-debian-kubernetes-latest-ci" {
  inherits = ["vegito-trixie-debian-kubernetes-base"]
  contexts = {
    debian = "target:vegito-trixie-debian-version-ci"
  }
  tags = [
    VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_IMAGE_LATEST,
    ]
  )
  cache-to = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_IMAGE_REGISTRY_CACHE},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : [],
    [
      "type=inline"
    ]
  )
  platforms = platforms
}

target "vegito-trixie-debian-go" {
  inherits = ["vegito-trixie-debian-kubernetes-base"]
  contexts = {
    debian = "target:vegito-trixie-debian-version-ci"
  }
  tags = [
    VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_IMAGE_LATEST,
    VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_IMAGE_VERSION
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_IMAGE_LATEST,
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST,
    ] : []
  )
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_DESKTOP_X_IMAGE_VERSION" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:debian-kubernetes-desktop-x-${VERSION}"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_DESKTOP_X_IMAGE_LATEST" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:debian-kubernetes-desktop-x-latest"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_DESKTOP_X_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_CACHE_IMAGES_BASE}/debian-kubernetes-desktop-x"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/debian-kubernetes-desktop-x-version"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/debian-kubernetes-desktop-x-latest"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_DESKTOP_X_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION" {
  description = "local write cache (version)"
  default     = "type=local,mode=max,dest=${VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_DESKTOP_X_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST" {
  description = "local write cache (latest)"
  default     = "type=local,mode=max,dest=${VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION" {
  description = "local read cache (version)"
  default     = "type=local,src=${VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST" {
  description = "local read cache (latest)"
  default     = "type=local,src=${VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

target "vegito-trixie-debian-kubernetes-desktop-x-version-ci" {
  contexts = {
    debian = "target:vegito-trixie-debian-desktop-x-version-ci"
  }
  inherits = ["vegito-trixie-debian-kubernetes-base"]
  tags = [
    VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_DESKTOP_X_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_DESKTOP_X_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION
    ] : [],
    [
      VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_DESKTOP_X_IMAGE_LATEST
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_DESKTOP_X_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION,
    ] : []
  )
  platforms = platforms
}

target "vegito-trixie-debian-kubernetes-desktop-x-latest-ci" {
  inherits = ["vegito-trixie-debian-kubernetes-base"]
  contexts = {
    debian = "target:vegito-trixie-debian-desktop-x-latest-ci"
  }
  tags = [
    VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_DESKTOP_X_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_DESKTOP_X_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_DESKTOP_X_IMAGE_LATEST,
    ]
  )
  cache-to = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_DESKTOP_X_IMAGE_REGISTRY_CACHE},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_DESKTOP_X_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : [],
    [
      "type=inline"
    ]
  )
  platforms = platforms
}

target "vegito-trixie-debian-kubernetes-desktop-x" {
  inherits = ["vegito-trixie-debian-kubernetes-base"]
  contexts = {
    debian = "target:vegito-trixie-debian-desktop-x-version-ci"
  }
  tags = [
    VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_DESKTOP_X_IMAGE_VERSION,
    VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_DESKTOP_X_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_DESKTOP_X_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_DESKTOP_X_IMAGE_LATEST,
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_KUBERNETES_DESKTOP_X_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST,
    ] : []
  )
}
