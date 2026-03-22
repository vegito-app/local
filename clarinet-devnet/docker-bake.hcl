variable "LOCAL_CLARINET_DEVNET_IMAGE_VERSION" {
  default = notequal("", VERSION) ? "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:clarinet-${VERSION}" : ""
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

target "clarinet-devnet-ci" {
  contexts = {
    builder_image              = "target:local-builder-ci"
    debian_image               = "target:local-debian-ci"
    docker_dind_rootless_image = "target:local-docker-dind-rootless-ci"
    rust_image                 = "target:local-rust-ci"
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
    [],
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_CLARINET_DEVNET_IMAGE_REGISTRY_CACHE}",
      "type=registry,ref=${LOCAL_BUILDER_IMAGE_REGISTRY_CACHE}",
      "type=registry,ref=${LOCAL_DEBIAN_IMAGE_REGISTRY_CACHE}"
    ] : [],
    [
      "type=inline,ref=${LOCAL_CLARINET_DEVNET_IMAGE_LATEST}",
      "type=inline,ref=${LOCAL_BUILDER_IMAGE_LATEST}",
      "type=inline,ref=${LOCAL_DEBIAN_IMAGE_LATEST}"
    ]
  )
  cache-to  = []
  platforms = platforms
}

target "clarinet-devnet-latest-ci" {
  contexts = {
    builder_image              = "target:local-builder-latest-ci"
    debian_image               = "target:local-debian-latest-ci"
    docker_dind_rootless_image = "target:local-docker-dind-rootless-latest-ci"
    rust_image                 = "target:local-rust-latest-ci"
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
    [],
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_CLARINET_DEVNET_IMAGE_REGISTRY_CACHE}",
      "type=registry,ref=${LOCAL_BUILDER_IMAGE_REGISTRY_CACHE}",
      "type=registry,ref=${LOCAL_DEBIAN_IMAGE_REGISTRY_CACHE}"
    ] : [],
    [
      "type=inline,ref=${LOCAL_CLARINET_DEVNET_IMAGE_LATEST}",
      "type=inline,ref=${LOCAL_BUILDER_IMAGE_LATEST}",
      "type=inline,ref=${LOCAL_DEBIAN_IMAGE_LATEST}"
    ]
  )
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_CLARINET_DEVNET_IMAGE_REGISTRY_CACHE},mode=max" : "type=inline"
  ]
  platforms = platforms
}

target "clarinet-devnet" {
  contexts = {
    builder_image              = "target:local-builder"
    debian_image               = "target:local-debian"
    docker_dind_rootless_image = "target:local-docker-dind-rootless"
    rust_image                 = "target:local-rust"
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
    ENABLE_LOCAL_CACHE ? [LOCAL_CLARINET_DEVNET_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ] : [],
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_CLARINET_DEVNET_IMAGE_REGISTRY_CACHE}",
      "type=registry,ref=${LOCAL_BUILDER_IMAGE_REGISTRY_CACHE}",
      "type=registry,ref=${LOCAL_DEBIAN_IMAGE_REGISTRY_CACHE}"
    ] : [],
    [
      "type=inline,ref=${LOCAL_CLARINET_DEVNET_IMAGE_LATEST}",
      "type=inline,ref=${LOCAL_BUILDER_IMAGE_LATEST}",
      "type=inline,ref=${LOCAL_DEBIAN_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [LOCAL_CLARINET_DEVNET_IMAGE_DOCKER_BUILDX_CACHE_WRITE] : []
  )
}
