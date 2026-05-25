variable "VEGITO_DOCKER_TRIXIE_DEBIAN_IMAGE_LATEST" {
  default = "${VEGITO_PUBLIC_REPOSITORY}/trixie-debian:latest"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_IMAGE_VERSION" {
  default = "${VEGITO_PUBLIC_REPOSITORY}/trixie-debian:${VERSION}"
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

group "vegito-trixie-debian-ci" {
  targets = [
    "vegito-trixie-debian-version-ci",
    "vegito-trixie-debian-latest-ci",

    "vegito-trixie-debian-desktop-x-ci",
    "vegito-trixie-debian-flutter-ci",
    "vegito-trixie-debian-golang-ci",
    "vegito-trixie-debian-nodejs-ci",
    "vegito-trixie-debian-python-ci",
    "vegito-trixie-debian-rust-ci",

    "vegito-trixie-debian-ai-ci",

    "vegito-trixie-debian-docker-ci",
  ]
}

target "vegito-trixie-debian-base" {
  inherits = ["vegito-debian-base"]
  args = {
    debian_version = "trixie"
  }
  contexts = {
    debian = "target:docker-debian-trixie-base"
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
      VEGITO_DOCKER_TRIXIE_DEBIAN_IMAGE_LATEST
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
      VEGITO_DOCKER_TRIXIE_DEBIAN_IMAGE_LATEST
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
      VEGITO_DOCKER_TRIXIE_DEBIAN_IMAGE_LATEST
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE
    ] : []
  )
}
