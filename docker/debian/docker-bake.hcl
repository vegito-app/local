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
  default = "${VEGITO_PUBLIC_REPOSITORY}/debian:bookworm"
}

variable "VEGITO_DOCKER_DEBIAN_IMAGE_VERSION" {
  default = "${VEGITO_PUBLIC_REPOSITORY}/debian:${VERSION}"
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
    "vegito-debian-nodejs-ci",
    "vegito-debian-flutter-ci",
    "vegito-debian-golang-ci",
    "vegito-debian-python-ci",
    "vegito-debian-rust-ci",

    "vegito-debian-ai-ci",

    "vegito-debian-docker-ci",
  ]
}

target "vegito-debian-base" {
  context = VEGITO_DOCKER_DEBIAN_DIR
}

target "vegito-bookworm-debian-base" {
  inherits = ["vegito-debian-base"]
  args = {
    "debian_version" = "bookworm"
  }
  contexts = {
    debian = "target:docker-debian-bookworm-base"
  }
  dockerfile = "bookworm.Dockerfile"
}

target "vegito-debian-version-ci" {
  inherits = ["vegito-debian-base"]
  contexts = {
    debian = "docker-image://${VEGITO_DOCKER_DEBIAN_IMAGE_VERSION}"
  }
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
      VEGITO_DOCKER_DEBIAN_IMAGE_LATEST
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
  inherits = ["vegito-debian-base"]
  contexts = {
    debian = "docker-image://${VEGITO_DOCKER_DEBIAN_IMAGE_LATEST}"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      VEGITO_DOCKER_DEBIAN_IMAGE_LATEST
    ]
  )
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${VEGITO_DOCKER_DEBIAN_IMAGE_REGISTRY_CACHE},mode=max" : "",
    "type=inline"
  ]
  platforms = platforms
}

target "vegito-debian" {
  inherits = ["vegito-debian-base"]
  contexts = {
    debian = "docker-image://${VEGITO_DOCKER_DEBIAN_IMAGE_LATEST}"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      VEGITO_DOCKER_DEBIAN_IMAGE_LATEST
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE
    ] : []
  )
}
