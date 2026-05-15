
variable "FLUTTER_VERSION" {
  default = "3.41.0"
}

group "local-flutter-ci" {
  targets = [
    "local-flutter-version-ci",
    "local-flutter-latest-ci"
  ]
}

target "local-flutter-base" {
  args = {
    flutter_version = FLUTTER_VERSION
  }
  context = LOCAL_FLUTTER_DEBIAN_DIR
}

target "local-flutter-base-ci" {
  inherits  = ["local-flutter-base"]
  platforms = platforms
}

# -------------------------------------------------------------------
# ###################################################################
# LOCAL FLUTTER DEBIAN
# ###################################################################
variable "LOCAL_FLUTTER_DEBIAN_DIR" {
  default = "${LOCAL_DOCKER_DIR}/flutter"
}

variable "LOCAL_FLUTTER_DEBIAN_REGISTRY_CACHE_IMAGE" {
  default = "${VEGITO_LOCAL_CACHE_IMAGES_BASE}/flutter"
}

variable "LOCAL_FLUTTER_DEBIAN_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_LOCAL_CACHE_IMAGES_BASE}/flutter"
}
variable "LOCAL_FLUTTER_DEBIAN_VERSION" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME}:flutter-debian-${VERSION}"
}

variable "LOCAL_FLUTTER_DEBIAN_IMAGE_LATEST" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME}:flutter-debian-latest"
}

variable "LOCAL_FLUTTER_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/flutter-debian-version"
}

variable "LOCAL_FLUTTER_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/flutter-debian-latest"
}

variable "LOCAL_FLUTTER_DEBIAN_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION" {
  description = "local write cache (version) for local-flutter image build"
  default     = "type=local,mode=max,dest=${LOCAL_FLUTTER_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "LOCAL_FLUTTER_DEBIAN_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST" {
  description = "local write cache (latest) for local-flutter image build"
  default     = "type=local,mode=max,dest=${LOCAL_FLUTTER_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "LOCAL_FLUTTER_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION" {
  description = "local read cache (version)"
  default     = "type=local,src=${LOCAL_FLUTTER_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "LOCAL_FLUTTER_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST" {
  description = "local read cache (latest)"
  default     = "type=local,src=${LOCAL_FLUTTER_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

target "local-flutter-debian-latest-ci" {
  inherits = ["local-flutter-base"]
  contexts = {
    debian = "target:local-debian-latest-ci"
  }
  tags = [
    LOCAL_FLUTTER_DEBIAN_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_FLUTTER_DEBIAN_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_FLUTTER_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      "type=inline,ref=${LOCAL_FLUTTER_DEBIAN_IMAGE_LATEST}",
    ]
  )
  cache-to = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_FLUTTER_DEBIAN_IMAGE_REGISTRY_CACHE},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_FLUTTER_DEBIAN_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : [],
    [
      "type=inline"
    ]
  )
  platforms = platforms
}

target "local-flutter-debian-version-ci" {
  inherits = ["local-flutter-base-ci"]
  contexts = {
    debian = "target:local-debian-version-ci"
  }
  tags = [
    LOCAL_FLUTTER_DEBIAN_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_FLUTTER_DEBIAN_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_FLUTTER_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION
    ] : [],
    [
      "type=inline,ref=${LOCAL_FLUTTER_DEBIAN_IMAGE_LATEST}",
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_FLUTTER_DEBIAN_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION
    ] : []
  )
}

target "local-flutter-debian" {
  inherits = ["local-flutter-base"]
  contexts = {
    debian = "target:local-debian"
  }
  tags = [
    LOCAL_FLUTTER_DEBIAN_IMAGE_LATEST,
    LOCAL_FLUTTER_DEBIAN_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_FLUTTER_DEBIAN_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_FLUTTER_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      "type=inline,ref=${LOCAL_FLUTTER_DEBIAN_IMAGE_LATEST}",
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_FLUTTER_DEBIAN_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : []
  )
}

# -------------------------------------------------------------------
# ###################################################################
# Desktop X
# ###################################################################
variable "LOCAL_FLUTTER_DESKTOP_X_REGISTRY_CACHE_IMAGE" {
  default = "${VEGITO_LOCAL_CACHE_IMAGES_BASE}/flutter-desktop-x"
}

variable "LOCAL_FLUTTER_DESKTOP_X_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_LOCAL_CACHE_IMAGES_BASE}/flutter-desktop-x"
}

variable "LOCAL_FLUTTER_DESKTOP_X_VERSION" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME}:flutter-desktop-x-${VERSION}"
}

variable "LOCAL_FLUTTER_DESKTOP_X_IMAGE_LATEST" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME}:flutter-desktop-x-latest"
}

variable "LOCAL_FLUTTER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/flutter-desktop-x-version"
}

variable "LOCAL_FLUTTER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/flutter-desktop-x-latest"
}

variable "LOCAL_FLUTTER_DESKTOP_X_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION" {
  description = "local write cache (version) for local-flutter image build"
  default     = "type=local,mode=max,dest=${LOCAL_FLUTTER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "LOCAL_FLUTTER_DESKTOP_X_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST" {
  description = "local write cache (latest) for local-flutter image build"
  default     = "type=local,mode=max,dest=${LOCAL_FLUTTER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "LOCAL_FLUTTER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION" {
  description = "local read cache (version)"
  default     = "type=local,src=${LOCAL_FLUTTER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "LOCAL_FLUTTER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST" {
  description = "local read cache (latest)"
  default     = "type=local,src=${LOCAL_FLUTTER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

target "local-flutter-desktop-x-latest-ci" {
  inherits = ["local-flutter-base-ci"]
  contexts = {
    debian = "target:local-desktop-x-latest-ci"
  }
  args = {
    user = "desktopx"
  }
  tags = [
    LOCAL_FLUTTER_DESKTOP_X_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_FLUTTER_DESKTOP_X_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_FLUTTER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      "type=inline,ref=${LOCAL_FLUTTER_DESKTOP_X_IMAGE_LATEST}",
    ]
  )
  cache-to = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_FLUTTER_DESKTOP_X_IMAGE_REGISTRY_CACHE},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_FLUTTER_DESKTOP_X_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : [],
    [
      "type=inline"
    ]
  )
}

target "local-flutter-desktop-x-version-ci" {
  inherits = ["local-flutter-base-ci"]
  contexts = {
    debian = "target:local-desktop-x-version-ci"
  }
  args = {
    user = "desktopx"
  }
  tags = [
    LOCAL_FLUTTER_DESKTOP_X_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_FLUTTER_DESKTOP_X_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_FLUTTER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION
    ] : [],
    [
      "type=inline,ref=${LOCAL_FLUTTER_DESKTOP_X_IMAGE_LATEST}",
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_FLUTTER_DESKTOP_X_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION
    ] : []
  )
}

target "local-flutter-desktop-x" {
  contexts = {
    debian = "target:local-desktop-x"
  }
  args = {
    user = "desktopx"
  }
  tags = [
    LOCAL_FLUTTER_DESKTOP_X_IMAGE_LATEST,
    LOCAL_FLUTTER_DESKTOP_X_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_FLUTTER_DESKTOP_X_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_FLUTTER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      "type=inline,ref=${LOCAL_FLUTTER_DESKTOP_X_IMAGE_LATEST}",
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_FLUTTER_DESKTOP_X_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : []
  )
}
