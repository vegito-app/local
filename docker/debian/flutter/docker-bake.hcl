
variable "FLUTTER_VERSION" {
  default = "3.41.0"
}

group "vegito-debian-flutter-ci" {
  targets = [
    "vegito-debian-flutter-version-ci",
    "vegito-debian-flutter-latest-ci",

    "vegito-debian-flutter-desktop-x-ci",
  ]
}

group "vegito-debian-flutter-desktop-x-ci" {
  targets = [
    "vegito-debian-flutter-desktop-x-version-ci",
    "vegito-debian-flutter-desktop-x-latest-ci"
  ]
}

target "vegito-debian-flutter-base" {
  args = {
    vegito-debian-flutter_version = FLUTTER_VERSION
    non_root_user                 = "vegito-debian-flutter"
  }
  context = VEGITO_DOCKER_DEBIAN_FLUTTER_DIR
}

target "vegito-debian-flutter-base-ci" {
  inherits  = ["vegito-debian-flutter-base"]
  platforms = platforms
}

# -------------------------------------------------------------------
# ###################################################################
# LOCAL FLUTTER DEBIAN
# ###################################################################
variable "VEGITO_DOCKER_DEBIAN_FLUTTER_DIR" {
  default = "${VEGITO_DOCKER_DIR}/debian/flutter"
}

variable "VEGITO_DOCKER_DEBIAN_FLUTTER_REGISTRY_CACHE_IMAGE" {
  default = "${VEGITO_CACHE_IMAGES_BASE}/debian-flutter"
}

variable "VEGITO_DOCKER_DEBIAN_FLUTTER_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_CACHE_IMAGES_BASE}/debian-flutter"
}
variable "VEGITO_DOCKER_DEBIAN_FLUTTER_VERSION" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:debian-flutter-${VERSION}"
}

variable "VEGITO_DOCKER_DEBIAN_FLUTTER_IMAGE_LATEST" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:debian-flutter-latest"
}

variable "VEGITO_DOCKER_DEBIAN_FLUTTER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/debian-flutter-version"
}

variable "VEGITO_DOCKER_DEBIAN_FLUTTER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/debian-flutter-latest"
}

variable "VEGITO_DOCKER_DEBIAN_FLUTTER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION" {
  description = "local write cache (version) for debian-flutter image build"
  default     = "type=local,mode=max,dest=${VEGITO_DOCKER_DEBIAN_FLUTTER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_DOCKER_DEBIAN_FLUTTER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST" {
  description = "local write cache (latest) for debian-flutter image build"
  default     = "type=local,mode=max,dest=${VEGITO_DOCKER_DEBIAN_FLUTTER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "VEGITO_DOCKER_DEBIAN_FLUTTER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION" {
  description = "local read cache (version)"
  default     = "type=local,src=${VEGITO_DOCKER_DEBIAN_FLUTTER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_DOCKER_DEBIAN_FLUTTER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST" {
  description = "local read cache (latest)"
  default     = "type=local,src=${VEGITO_DOCKER_DEBIAN_FLUTTER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

target "vegito-debian-flutter-latest-ci" {
  inherits = ["vegito-debian-flutter-base"]
  contexts = {
    debian = "target:vegito-debian-latest-ci"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_FLUTTER_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_FLUTTER_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_FLUTTER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      VEGITO_DOCKER_DEBIAN_FLUTTER_IMAGE_LATEST,
    ]
  )
  cache-to = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_FLUTTER_IMAGE_REGISTRY_CACHE},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_FLUTTER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : [],
    [
      "type=inline"
    ]
  )
  platforms = platforms
}

target "vegito-debian-flutter-version-ci" {
  inherits = ["vegito-debian-flutter-base-ci"]
  contexts = {
    debian = "target:vegito-debian-version-ci"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_FLUTTER_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_FLUTTER_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_FLUTTER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION
    ] : [],
    [
      VEGITO_DOCKER_DEBIAN_FLUTTER_IMAGE_LATEST,
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_FLUTTER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION
    ] : []
  )
}

target "vegito-debian-flutter-debian" {
  inherits = ["vegito-debian-flutter-base"]
  contexts = {
    debian = "target:debian"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_FLUTTER_IMAGE_LATEST,
    VEGITO_DOCKER_DEBIAN_FLUTTER_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_FLUTTER_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_FLUTTER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      VEGITO_DOCKER_DEBIAN_FLUTTER_IMAGE_LATEST,
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_FLUTTER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : []
  )
}

# -------------------------------------------------------------------
# ###################################################################
# Desktop X
# ###################################################################
variable "VEGITO_DOCKER_DEBIAN_FLUTTER_DESKTOP_X_REGISTRY_CACHE_IMAGE" {
  default = "${VEGITO_CACHE_IMAGES_BASE}/debian-flutter-desktop-x"
}

variable "VEGITO_DOCKER_DEBIAN_FLUTTER_DESKTOP_X_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_CACHE_IMAGES_BASE}/debian-flutter-desktop-x"
}

variable "VEGITO_DOCKER_DEBIAN_FLUTTER_DESKTOP_X_IMAGE_VERSION" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:debian-flutter-desktop-x-${VERSION}"
}

variable "VEGITO_DOCKER_DEBIAN_FLUTTER_DESKTOP_X_IMAGE_LATEST" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:debian-flutter-desktop-x-latest"
}

variable "VEGITO_DOCKER_DEBIAN_FLUTTER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/debian-flutter-desktop-x-version"
}

variable "VEGITO_DOCKER_DEBIAN_FLUTTER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/debian-flutter-desktop-x-latest"
}

variable "VEGITO_DOCKER_DEBIAN_FLUTTER_DESKTOP_X_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION" {
  description = "local write cache (version) for debian-flutter image build"
  default     = "type=local,mode=max,dest=${VEGITO_DOCKER_DEBIAN_FLUTTER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_DOCKER_DEBIAN_FLUTTER_DESKTOP_X_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST" {
  description = "local write cache (latest) for debian-flutter image build"
  default     = "type=local,mode=max,dest=${VEGITO_DOCKER_DEBIAN_FLUTTER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "VEGITO_DOCKER_DEBIAN_FLUTTER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION" {
  description = "local read cache (version)"
  default     = "type=local,src=${VEGITO_DOCKER_DEBIAN_FLUTTER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_DOCKER_DEBIAN_FLUTTER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST" {
  description = "local read cache (latest)"
  default     = "type=local,src=${VEGITO_DOCKER_DEBIAN_FLUTTER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

target "vegito-debian-flutter-desktop-x-latest-ci" {
  inherits = ["vegito-debian-flutter-base-ci"]
  contexts = {
    debian = "target:vegito-debian-desktop-x-latest-ci"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_FLUTTER_DESKTOP_X_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_FLUTTER_DESKTOP_X_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_FLUTTER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      VEGITO_DOCKER_DEBIAN_FLUTTER_DESKTOP_X_IMAGE_LATEST,
    ]
  )
  cache-to = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_FLUTTER_DESKTOP_X_IMAGE_REGISTRY_CACHE},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_FLUTTER_DESKTOP_X_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : [],
    [
      "type=inline"
    ]
  )
}

target "vegito-debian-flutter-desktop-x-version-ci" {
  inherits = ["vegito-debian-flutter-base-ci"]
  contexts = {
    debian = "target:vegito-debian-desktop-x-version-ci"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_FLUTTER_DESKTOP_X_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_FLUTTER_DESKTOP_X_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_FLUTTER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION
    ] : [],
    [
      VEGITO_DOCKER_DEBIAN_FLUTTER_DESKTOP_X_IMAGE_LATEST,
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_FLUTTER_DESKTOP_X_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION
    ] : []
  )
}

target "vegito-debian-flutter-desktop-x" {
  contexts = {
    debian = "target:vegito-debian-desktop-x"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_FLUTTER_DESKTOP_X_IMAGE_LATEST,
    VEGITO_DOCKER_DEBIAN_FLUTTER_DESKTOP_X_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_FLUTTER_DESKTOP_X_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_FLUTTER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      VEGITO_DOCKER_DEBIAN_FLUTTER_DESKTOP_X_IMAGE_LATEST,
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_FLUTTER_DESKTOP_X_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : []
  )
}
