variable "VEGITO_DOCKER_LINUX_ALPINE_DIR" {
  default = "${VEGITO_DOCKER_DIR}/alpine"
}

variable "VEGITO_LINUX_ALPINE_VERSION" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:alpine-${VERSION}"
}

variable "VEGITO_LINUX_ALPINE_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_CACHE_IMAGES_BASE}/alpine"
}

variable "VEGITO_LINUX_ALPINE_DIR" {
  default = "${VEGITO_DOCKER_DIR}/alpine"
}

variable "VEGITO_LINUX_ALPINE_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_CACHE_IMAGES_BASE}/alpine"
}

variable "VEGITO_LINUX_ALPINE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/alpine"
}

variable "VEGITO_LINUX_ALPINE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE" {
  default = "type=local,mode=max,dest=${VEGITO_LINUX_ALPINE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "VEGITO_LINUX_ALPINE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  default = "type=local,src=${VEGITO_LINUX_ALPINE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "VEGITO_LINUX_ALPINE_IMAGE_LATEST" {
  default = "${VEGITO_PUBLIC_REPOSITORY}/alpine:latest"
}

variable "VEGITO_LINUX_ALPINE_IMAGE_VERSION" {
  default = "${VEGITO_PUBLIC_REPOSITORY}/alpine:${VERSION}"
}

group "vegito-linux-alpine-ci" {
  targets = [
    "vegito-linux-alpine-version-ci",

    "vegito-linux-alpine-latest-ci",
  ]
}

target "vegito-linux-alpine-version-ci" {
  tags = [
    VEGITO_LINUX_ALPINE_IMAGE_VERSION,
  ]
  context = VEGITO_DOCKER_LINUX_ALPINE_DIR
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_LINUX_ALPINE_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_LINUX_ALPINE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      VEGITO_LINUX_ALPINE_IMAGE_LATEST
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_LINUX_ALPINE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE
    ] : [],
  )
  platforms = platforms
}

target "vegito-linux-alpine-latest-ci" {
  tags = [
    VEGITO_LINUX_ALPINE_IMAGE_LATEST,
  ]
  context = VEGITO_DOCKER_LINUX_ALPINE_DIR
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_LINUX_ALPINE_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_LINUX_ALPINE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      VEGITO_LINUX_ALPINE_IMAGE_LATEST
    ]
  )
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${VEGITO_LINUX_ALPINE_IMAGE_REGISTRY_CACHE},mode=max" : "",
    "type=inline"
  ]
  platforms = platforms
}

target "vegito-linux-alpine" {
  tags = [
    VEGITO_LINUX_ALPINE_IMAGE_LATEST,
  ]
  context = VEGITO_DOCKER_LINUX_ALPINE_DIR
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_LINUX_ALPINE_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_LINUX_ALPINE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      VEGITO_LINUX_ALPINE_IMAGE_LATEST
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_LINUX_ALPINE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE
    ] : []
  )
}
