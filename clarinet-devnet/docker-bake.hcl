variable "LOCAL_CLARINET_DEVNET_IMAGE_VERSION" {
  default = notequal("", VERSION) ? "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:clarinet-${VERSION}" : ""
}

variable "LOCAL_CLARINET_DEVNET_IMAGE_LATEST" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:clarinet-latest"
}

variable "LOCAL_CLARINET_DEVNET_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}/cache/clarinet-devnet"
}

variable "LOCAL_CLARINET_DEVNET_IMAGE_REGISTRY_CACHE_CI" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}/cache/clarinet-devnet/ci"
}

variable "LOCAL_CLARINET_DEVNET_IMAGE_DOCKER_BUILDX_CACHE_WRITE" {
  description = "local write cache for clarinet image build"
}

variable "LOCAL_CLARINET_DEVNET_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  description = "local read cache for clarinet image build (cannot be used before first write)"
}

variable "CLARINET_VERSION" {
  default = "2.12.0"
}

target "clarinet-devnet-ci" {
  args = {
    builder_image    = LOCAL_BUILDER_IMAGE_VERSION
    docker_version   = DOCKER_VERSION
    clarinet_version = CLARINET_VERSION
  }
  context    = "${LOCAL_DIR}/clarinet-devnet"
  dockerfile = "Dockerfile"
  tags = [
    LOCAL_CLARINET_DEVNET_IMAGE_LATEST,
    LOCAL_CLARINET_DEVNET_IMAGE_VERSION,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_CLARINET_DEVNET_IMAGE_REGISTRY_CACHE_CI}" : LOCAL_CLARINET_DEVNET_IMAGE_LATEST,
    "type=inline,ref=${LOCAL_CLARINET_DEVNET_IMAGE_LATEST}",
    LOCAL_CLARINET_DEVNET_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_CLARINET_DEVNET_IMAGE_REGISTRY_CACHE_CI},mode=max" : "type=inline"
  ]
  platforms = platforms
}

target "clarinet-devnet" {
  args = {
    builder_image    = LOCAL_BUILDER_IMAGE_LATEST
    docker_version   = DOCKER_VERSION
    clarinet_version = CLARINET_VERSION
  }
  context    = "${LOCAL_DIR}/clarinet-devnet"
  dockerfile = "Dockerfile"
  tags = [
    LOCAL_CLARINET_DEVNET_IMAGE_LATEST,
    LOCAL_CLARINET_DEVNET_IMAGE_VERSION,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_CLARINET_DEVNET_IMAGE_REGISTRY_CACHE}" : "",
    LOCAL_CLARINET_DEVNET_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
    "type=inline,ref=${LOCAL_CLARINET_DEVNET_IMAGE_LATEST}",
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_CLARINET_DEVNET_IMAGE_REGISTRY_CACHE},mode=max" : LOCAL_CLARINET_DEVNET_IMAGE_DOCKER_BUILDX_CACHE_WRITE,
  ]
}
