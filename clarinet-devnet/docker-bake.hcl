variable "LOCAL_CLARINET_DEVNET_IMAGE_VERSION" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:clarinet-${VERSION}"
}

variable "LOCAL_CLARINET_DEVNET_IMAGE_LATEST" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:clarinet-latest"
}

variable "LOCAL_CLARINET_DEVNET_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_LOCAL_CACHE_IMAGES_BASE}/clarinet-devnet"
}

variable "LOCAL_CLARINET_DEVNET_IMAGE_DOCKER_BUILDX_LOCAL_CACHE" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/clarinet-devnet"
}

variable "LOCAL_CLARINET_DEVNET_IMAGE_DOCKER_BUILDX_CACHE_WRITE" {
  description = "local write cache for clarinet image build"
  default     = "type=local,mode=max,dest=${LOCAL_CLARINET_DEVNET_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "LOCAL_CLARINET_DEVNET_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  description = "local read cache for clarinet image build (cannot be used before first write)"
  default     = "type=local,src=${LOCAL_CLARINET_DEVNET_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "CLARINET_VERSION" {
  default = "2.12.0"
}

group "local-clarinet-devnet-ci" {
  targets = [
    "local-clarinet-devnet-version-ci",
    # "local-clarinet-devnet-latest-ci",
  ]
}

target "local-clarinet-devnet-version-ci" {
  contexts = {
    builder_image              = "target:local-project-builder-version-ci"
    debian_image               = "docker-image://${LOCAL_DEBIAN_IMAGE_VERSION}"
    docker_dind_rootless_image = "docker-image://${LOCAL_DOCKER_DIND_ROOTLESS_IMAGE_VERSION}"
    rust_image                 = "docker-image://${LOCAL_RUST_IMAGE_VERSION}"
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
  # cache-from = concat(
  #   USE_REGISTRY_CACHE ? [
  #     "type=registry,ref=${LOCAL_CLARINET_DEVNET_IMAGE_REGISTRY_CACHE}",
  #     "type=registry,ref=${LOCAL_BUILDER_IMAGE_REGISTRY_CACHE}",
  #     "type=registry,ref=${LOCAL_DEBIAN_IMAGE_REGISTRY_CACHE}"
  #   ] : [],
  #   ENABLE_LOCAL_CACHE ? [
  #     LOCAL_CLARINET_DEVNET_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
  #   ] : [],
  #   [
  #     "type=inline,ref=${LOCAL_CLARINET_DEVNET_IMAGE_LATEST}",
  #     "type=inline,ref=${LOCAL_BUILDER_IMAGE_LATEST}",
  #     "type=inline,ref=${LOCAL_DEBIAN_IMAGE_LATEST}"
  #   ]
  # )
  # cache-to = concat(
  #   ENABLE_LOCAL_CACHE ? [
  #     LOCAL_CLARINET_DEVNET_IMAGE_DOCKER_BUILDX_CACHE_WRITE
  #   ] : []
  # )
  platforms = platforms
}

target "local-clarinet-devnet-latest-ci" {
  contexts = {
    builder_image              = "target:local-project-builder-latest-ci"
    debian_image               = "docker-image://${LOCAL_DEBIAN_IMAGE_LATEST}"
    docker_dind_rootless_image = "docker-image://${LOCAL_DOCKER_DIND_ROOTLESS_IMAGE_LATEST}"
    rust_image                 = "docker-image://${LOCAL_RUST_IMAGE_LATEST}"
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
      "type=registry,ref=${LOCAL_BUILDER_IMAGE_REGISTRY_CACHE}",
      "type=registry,ref=${LOCAL_DEBIAN_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_CLARINET_DEVNET_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      "type=inline,ref=${LOCAL_CLARINET_DEVNET_IMAGE_LATEST}",
      "type=inline,ref=${LOCAL_BUILDER_IMAGE_LATEST}",
      "type=inline,ref=${LOCAL_DEBIAN_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_CLARINET_DEVNET_IMAGE_REGISTRY_CACHE},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_CLARINET_DEVNET_IMAGE_DOCKER_BUILDX_CACHE_WRITE
    ] : []
  )
  platforms = platforms
}

target "local-clarinet-devnet" {
  contexts = {
    builder_image              = "target:local-project-builder"
    debian_image               = "docker-image://${LOCAL_DEBIAN_IMAGE_VERSION}"
    docker_dind_rootless_image = "docker-image://${LOCAL_DOCKER_DIND_ROOTLESS_IMAGE_VERSION}"
    rust_image                 = "docker-image://${LOCAL_RUST_IMAGE_VERSION}"
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
      "type=registry,ref=${LOCAL_BUILDER_IMAGE_REGISTRY_CACHE}",
      "type=registry,ref=${LOCAL_DEBIAN_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [LOCAL_CLARINET_DEVNET_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ] : [],
    [
      "type=inline,ref=${LOCAL_CLARINET_DEVNET_IMAGE_LATEST}",
      "type=inline,ref=${LOCAL_BUILDER_IMAGE_LATEST}",
      "type=inline,ref=${LOCAL_DEBIAN_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_CLARINET_DEVNET_IMAGE_REGISTRY_CACHE},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_CLARINET_DEVNET_IMAGE_DOCKER_BUILDX_CACHE_WRITE
    ] : []
  )
}
