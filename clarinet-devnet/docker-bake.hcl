variable "LOCAL_CLARINET_DEVNET_IMAGE_VERSION" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME}:clarinet-${VERSION}"
}

variable "LOCAL_CLARINET_DEVNET_IMAGE_LATEST" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME}:clarinet-latest"
}

variable "LOCAL_CLARINET_DEVNET_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_LOCAL_CACHE_IMAGES_BASE}/clarinet-devnet"
}

variable "LOCAL_CLARINET_DEVNET_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/clarinet-devnet-version"
}

variable "LOCAL_CLARINET_DEVNET_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/clarinet-devnet-latest"
}

variable "LOCAL_CLARINET_DEVNET_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION" {
  description = "local write cache (version)"
  default     = "type=local,mode=max,dest=${LOCAL_CLARINET_DEVNET_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "LOCAL_CLARINET_DEVNET_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST" {
  description = "local write cache (latest)"
  default     = "type=local,mode=max,dest=${LOCAL_CLARINET_DEVNET_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "LOCAL_CLARINET_DEVNET_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION" {
  description = "local read cache (version)"
  default     = "type=local,src=${LOCAL_CLARINET_DEVNET_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "LOCAL_CLARINET_DEVNET_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST" {
  description = "local read cache (latest)"
  default     = "type=local,src=${LOCAL_CLARINET_DEVNET_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "CLARINET_VERSION" {
  default = "2.12.0"
}

group "local-clarinet-devnet-ci" {
  targets = [
    "local-clarinet-devnet-version-ci",
    "local-clarinet-devnet-latest-ci",
  ]
}

target "local-clarinet-devnet-version-ci" {
  contexts = {
    builder_image = "target:local-project-builder-version-ci"
    debian        = "docker-image://${VEGITO_DOCKER_DEBIAN_DOCKER_IMAGE_VERSION}"
    rust_image    = "docker-image://${VEGITO_DOCKER_ALPINE_RUST_IMAGE_VERSION}"
  }
  args = {
    clarinet_version = CLARINET_VERSION
    docker_version   = DOCKER_VERSION
  }
  context    = "${LOCAL_DIR}/clarinet-devnet"
  dockerfile = "Dockerfile"
  tags = [
    LOCAL_CLARINET_DEVNET_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_CLARINET_DEVNET_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_CLARINET_DEVNET_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION
    ] : [],
    [
      LOCAL_CLARINET_DEVNET_IMAGE_LATEST,
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_CLARINET_DEVNET_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION
    ] : []
  )
  platforms = platforms
}

target "local-clarinet-devnet-latest-ci" {
  contexts = {
    builder_image = "target:local-project-builder-latest-ci"
    debian        = "docker-image://${VEGITO_DOCKER_DEBIAN_DOCKER_IMAGE_LATEST}"
    rust_image    = "docker-image://${VEGITO_DOCKER_ALPINE_RUST_IMAGE_LATEST}"
  }
  args = {
    clarinet_version = CLARINET_VERSION
    docker_version   = DOCKER_VERSION
  }
  context    = "${LOCAL_DIR}/clarinet-devnet"
  dockerfile = "Dockerfile"
  tags = [
    LOCAL_CLARINET_DEVNET_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_CLARINET_DEVNET_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_CLARINET_DEVNET_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    ENABLE_LOCAL_CACHE ? [LOCAL_CLARINET_DEVNET_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST] : [],
    [
      LOCAL_CLARINET_DEVNET_IMAGE_LATEST,
    ]
  )
  cache-to = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_CLARINET_DEVNET_IMAGE_REGISTRY_CACHE},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_CLARINET_DEVNET_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : [],
    [
      "type=inline"
    ]
  )
  platforms = platforms
}

target "local-clarinet-devnet" {
  contexts = {
    builder_image = "target:local-project-builder"
    debian        = "docker-image://${VEGITO_DOCKER_DEBIAN_DOCKER_IMAGE_VERSION}"
    rust_image    = "docker-image://${VEGITO_DOCKER_ALPINE_RUST_IMAGE_VERSION}"
  }
  args = {
    clarinet_version = CLARINET_VERSION
    docker_version   = DOCKER_VERSION
  }
  context    = "${LOCAL_DIR}/clarinet-devnet"
  dockerfile = "Dockerfile"
  tags = [
    LOCAL_CLARINET_DEVNET_IMAGE_LATEST,
    LOCAL_CLARINET_DEVNET_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_CLARINET_DEVNET_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [LOCAL_CLARINET_DEVNET_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST] : [],
    [
      LOCAL_CLARINET_DEVNET_IMAGE_LATEST,
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_CLARINET_DEVNET_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : []
  )
}
