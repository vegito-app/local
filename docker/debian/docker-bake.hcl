variable "LOCAL_DEBIAN_VERSION" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME}:debian-${VERSION}"
}

variable "LOCAL_DEBIAN_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_LOCAL_CACHE_IMAGES_BASE}/local-debian"
}

variable "LOCAL_DEBIAN_DIR" {
  default = "${LOCAL_DOCKER_DIR}/debian"
}

variable "LOCAL_DEBIAN_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_LOCAL_CACHE_IMAGES_BASE}/debian"
}

variable "LOCAL_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/debian"
}

variable "LOCAL_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE" {
  default = "type=local,mode=max,dest=${LOCAL_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "LOCAL_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  default = "type=local,src=${LOCAL_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "LOCAL_DEBIAN_IMAGE_LATEST" {
  default = "${VEGITO_PRIVATE_REPOSITORY}/debian:latest"
}

variable "LOCAL_DEBIAN_IMAGE_VERSION" {
  default = "${VEGITO_PRIVATE_REPOSITORY}/debian:${DOCKERHUB_REPLICA_VERSION}"
}

group "local-debian-ci" {
  targets = [
    "local-debian-version-ci",
    "local-debian-latest-ci",
  ]
}

target "local-debian-version-ci" {
  tags = [
    LOCAL_DEBIAN_IMAGE_VERSION,
  ]
  context = LOCAL_DEBIAN_DIR
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_DEBIAN_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      "type=inline,ref=${LOCAL_DEBIAN_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE
    ] : [],
  )
  platforms = platforms
}

target "local-debian-latest-ci" {
  tags = [
    LOCAL_DEBIAN_IMAGE_LATEST,
  ]
  context = LOCAL_DEBIAN_DIR
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_DEBIAN_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      "type=inline,ref=${LOCAL_DEBIAN_IMAGE_LATEST}"
    ]
  )
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_DEBIAN_IMAGE_REGISTRY_CACHE},mode=max" : "",
    "type=inline"
  ]
  platforms = platforms
}

target "local-debian" {
  tags = [
    LOCAL_DEBIAN_IMAGE_LATEST,
  ]
  context = LOCAL_DEBIAN_DIR
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_DEBIAN_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      "type=inline,ref=${LOCAL_DEBIAN_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE
    ] : []
  )
}
