variable "VEGITO_DOCKER_DEBIAN_RUST_DIR" {
  default = "${VEGITO_DOCKER_DEBIAN_DIR}/rust"
}

variable "VEGITO_PRIVATE_IMAGES_BASE_NAME" {
  default = "${VEGITO_PUBLIC_REPOSITORY}/vegito-local-private"
}

variable "VEGITO_DOCKER_DEBIAN_RUST_IMAGE_VERSION" {
  default = "${VEGITO_PUBLIC_IMAGES_BASE_NAME}:debian-rust-${VERSION}"
}


variable "VEGITO_DOCKER_DEBIAN_RUST_IMAGE_LATEST" {
  default = "${VEGITO_PUBLIC_IMAGES_BASE_NAME}:debian-rust-latest"
}

variable "VEGITO_DOCKER_DEBIAN_RUST_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_CACHE_IMAGES_BASE}/debian-rust"
}

variable "VEGITO_DOCKER_DEBIAN_RUST_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/debian-rust-version"
}

variable "VEGITO_DOCKER_DEBIAN_RUST_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/debian-rust-latest"
}

variable "VEGITO_DOCKER_DEBIAN_RUST_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION" {
  description = "local write cache (version)"
  default     = "type=local,mode=max,dest=${VEGITO_DOCKER_DEBIAN_RUST_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_DOCKER_DEBIAN_RUST_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST" {
  description = "local write cache (latest)"
  default     = "type=local,mode=max,dest=${VEGITO_DOCKER_DEBIAN_RUST_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "VEGITO_DOCKER_DEBIAN_RUST_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION" {
  description = "local read cache (version)"
  default     = "type=local,src=${VEGITO_DOCKER_DEBIAN_RUST_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_DOCKER_DEBIAN_RUST_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST" {
  description = "local read cache (latest)"
  default     = "type=local,src=${VEGITO_DOCKER_DEBIAN_RUST_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "RUST_VERSION" {
  default = "1.89.0"
}

target "vegito-debian-rust-base" {
  args = {
    rust_version = RUST_VERSION
  }
  context = VEGITO_DOCKER_DEBIAN_RUST_DIR
}

group "vegito-debian-rust-ci" {
  targets = [
    "vegito-debian-rust-version-ci",
    "vegito-debian-rust-latest-ci",

    "vegito-debian-rust-desktop-x-version-ci",
    "vegito-debian-rust-desktop-x-latest-ci",
  ]
}

target "vegito-debian-rust-version-ci" {
  inherits = ["vegito-debian-rust-base"]
  contexts = {
    debian = "target:vegito-trixie-debian-version-ci"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_RUST_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_RUST_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_RUST_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION
    ] : [],
    [
      "type=inline,ref=${VEGITO_DOCKER_DEBIAN_RUST_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_RUST_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION,
    ] : []
  )
  platforms = platforms
}

target "vegito-debian-rust-latest-ci" {
  inherits = ["vegito-debian-rust-base"]
  contexts = {
    debian = "target:vegito-trixie-debian-latest-ci"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_RUST_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_RUST_IMAGE_REGISTR_CACHE}",
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_RUST_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      "type=inline,ref=${VEGITO_DOCKER_DEBIAN_RUST_IMAGE_LATEST}",
      "type=inline,ref=${VEGITO_DOCKER_DEBIAN_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_RUST_IMAGE_REGISTRY_CACHE},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_RUST_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : [],
    [
      "type=inline"
    ]
  )
  platforms = platforms
}

target "vegito-debian-rust" {
  inherits = ["vegito-debian-rust-base"]
  contexts = {
    debian = "target:vegito-trixie-debian"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_RUST_IMAGE_LATEST,
    VEGITO_DOCKER_DEBIAN_RUST_IMAGE_VERSION
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_RUST_IMAGE_REGISTRY_CACHE}",
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_RUST_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      "type=inline,ref=${VEGITO_DOCKER_DEBIAN_RUST_IMAGE_LATEST}",
      "type=inline,ref=${VEGITO_DOCKER_DEBIAN_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_RUST_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST,
    ] : []
  )
}

variable "VEGITO_DOCKER_DEBIAN_RUST_DESKTOP_X_IMAGE_VERSION" {
  default = "${VEGITO_PUBLIC_IMAGES_BASE_NAME}:debian-rust-desktop-x-${VERSION}"
}

variable "VEGITO_DOCKER_DEBIAN_RUST_DESKTOP_X_IMAGE_LATEST" {
  default = "${VEGITO_PUBLIC_IMAGES_BASE_NAME}:debian-rust-desktop-x-latest"
}

target "vegito-debian-rust-desktop-x-version-ci" {
  contexts = {
    debian = "target:vegito-trixie-debian-desktop-x-version-ci"
  }
  inherits = ["vegito-debian-rust-base"]
  tags = [
    VEGITO_DOCKER_DEBIAN_RUST_DESKTOP_X_IMAGE_VERSION,
  ]
}

target "vegito-debian-rust-desktop-x-latest-ci" {
  inherits = ["vegito-debian-rust-base"]
  contexts = {
    debian = "target:vegito-trixie-debian-desktop-x-latest-ci"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_RUST_DESKTOP_X_IMAGE_LATEST,
  ]
}

target "vegito-debian-rust-desktop-x" {
  inherits = ["vegito-debian-rust"]
  contexts = {
    debian = "target:vegito-trixie-debian-desktop-x"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_RUST_DESKTOP_X_IMAGE_VERSION,
    VEGITO_DOCKER_DEBIAN_RUST_DESKTOP_X_IMAGE_LATEST,
  ]
}
