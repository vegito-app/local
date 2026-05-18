variable "VEGITO_DOCKER_DEBIAN_VERSION" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:debian-${VERSION}"
}

variable "VEGITO_DOCKER_DEBIAN_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_CACHE_IMAGES_BASE}/debian"
}

variable "VEGITO_DOCKER_DEBIAN_DIR" {
  default = "${VEGITO_DOCKER_DIR}/debian"
}

variable "VEGITO_DOCKER_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/debian"
}

variable "VEGITO_DOCKER_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  default = "type=local,src=${VEGITO_DOCKER_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "VEGITO_DOCKER_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE" {
  default = "type=local,mode=max,dest=${VEGITO_DOCKER_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "VEGITO_DOCKER_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  default = "type=local,src=${VEGITO_DOCKER_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "VEGITO_DOCKER_DEBIAN_IMAGE_LATEST" {
  default = "${VEGITO_PRIVATE_REPOSITORY}/debian:latest"
}

variable "VEGITO_DOCKER_DEBIAN_IMAGE_VERSION" {
  default = "${VEGITO_PRIVATE_REPOSITORY}/debian:${VERSION}"
}

group "vegito-debian-ci" {
  targets = [
    "vegito-bookworm-debian-ci",

    "vegito-trixie-debian-ci",
  ]
}

group "vegito-bookworm-debian-ci" {
  targets = [
    "vegito-debian-version-ci",
    "vegito-debian-latest-ci",

    "vegito-debian-desktop-x-ci",
    "vegito-debian-flutter-ci",
    "vegito-debian-golang-ci",
    "vegito-debian-rust-ci",
    "vegito-debian-python-ci",

  ]
}

group "vegito-trixie-debian-ci" {
  targets = [
    "vegito-trixie-debian-version-ci",
    "vegito-trixie-debian-latest-ci",

    "vegito-trixie-debian-desktop-x-ci",
    # "vegito-trixie-debian-flutter-ci",
    "vegito-trixie-debian-rust-ci",
    "vegito-trixie-debian-python-ci",
    "vegito-trixie-debian-golang-ci",
  ]
}

target "vegito-debian-base" {
  context = VEGITO_DOCKER_DEBIAN_DIR
}

target "vegito-debian-version-ci" {
  inherits = ["vegito-debian-base"]
  tags = [
    VEGITO_DOCKER_DEBIAN_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      "type=inline,ref=${VEGITO_DOCKER_DEBIAN_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE
    ] : [],
  )
  platforms = platforms
}

target "vegito-debian-latest-ci" {
  tags = [
    VEGITO_DOCKER_DEBIAN_IMAGE_LATEST,
  ]
  inherits = ["vegito-debian-base"]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      "type=inline,ref=${VEGITO_DOCKER_DEBIAN_IMAGE_LATEST}"
    ]
  )
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${VEGITO_DOCKER_DEBIAN_IMAGE_REGISTRY_CACHE},mode=max" : "",
    "type=inline"
  ]
  platforms = platforms
}

target "vegito-debian" {
  tags = [
    VEGITO_DOCKER_DEBIAN_IMAGE_LATEST,
  ]
  inherits = ["vegito-debian-base"]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      "type=inline,ref=${VEGITO_DOCKER_DEBIAN_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE
    ] : []
  )
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_IMAGE_LATEST" {
  default = "${VEGITO_PRIVATE_REPOSITORY}/trixie-debian:latest"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_IMAGE_VERSION" {
  default = "${VEGITO_PRIVATE_REPOSITORY}/trixie-debian:${VERSION}"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_CACHE_IMAGES_BASE}/trixie-debian"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/trixie-debian"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  default = "type=local,src=${VEGITO_DOCKER_TRIXIE_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE" {
  default = "type=local,mode=max,dest=${VEGITO_DOCKER_TRIXIE_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

target "vegito-trixie-debian-base" {
  inherits = ["vegito-debian-base"]
  context  = VEGITO_DOCKER_DEBIAN_DIR
  args = {
    debian_version = "trixie"
  }
}

target "vegito-trixie-debian-latest-ci" {
  inherits = ["vegito-trixie-debian-base"]
  tags = [
    VEGITO_DOCKER_TRIXIE_DEBIAN_IMAGE_LATEST
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      "type=inline,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_IMAGE_LATEST}"
    ]
  )
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_IMAGE_REGISTRY_CACHE},mode=max" : "",
    "type=inline"
  ]
  platforms = platforms
}

target "vegito-trixie-debian-version-ci" {
  inherits = ["vegito-trixie-debian-base"]
  tags = [
    VEGITO_DOCKER_TRIXIE_DEBIAN_IMAGE_VERSION
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      "type=inline,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE
    ] : [],
  )
  platforms = platforms
}

target "vegito-trixie-debian" {
  inherits = ["vegito-trixie-debian-base"]
  tags = [
    VEGITO_DOCKER_TRIXIE_DEBIAN_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      "type=inline,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE
    ] : []
  )
}
