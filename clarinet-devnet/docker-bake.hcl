variable "CLARINET_DEVNET_IMAGE_TAG" {
  default = notequal("", LOCAL_VERSION) ? "${PUBLIC_IMAGES_BASE}:clarinet-${LOCAL_VERSION}" : ""
}

variable "LATEST_CLARINET_DEVNET_IMAGE" {
  default = "${PUBLIC_IMAGES_BASE}:clarinet-latest"
}

variable "LOCAL_CLARINET_DEVNET_IMAGE_DOCKER_BUILDX_CACHE_WRITE" {
  description = "local write cache for clarinet image build"
}

variable "LOCAL_CLARINET_DEVNET_IMAGE_DOCKER_BUILDX_CACHE_READ" {
  description = "local read cache for clarinet image build (cannot be used before first write)"
}

variable "CLARINET_VERSION" {
  default = "2.12.0"
}

target "clarinet-devnet-ci" {
  args = {
    builder_image    = LATEST_BUILDER_IMAGE
    docker_version   = DOCKER_VERSION
    clarinet_version = CLARINET_VERSION
  }
  context    = "${LOCAL_DIR}/clarinet-devnet"
  dockerfile = "Dockerfile"
  tags = [
    LATEST_CLARINET_DEVNET_IMAGE,
    CLARINET_DEVNET_IMAGE_TAG,
  ]
  cache-from = [
    # LATEST_BUILDER_IMAGE,
    LATEST_CLARINET_DEVNET_IMAGE
  ]
  cache-to  = ["type=inline"]
  platforms = platforms
}

target "clarinet-devnet" {
  args = {
    builder_image    = LATEST_BUILDER_IMAGE
    docker_version   = DOCKER_VERSION
    clarinet_version = CLARINET_VERSION
  }
  context    = "${LOCAL_DIR}/clarinet-devnet"
  dockerfile = "Dockerfile"
  tags = [
    LATEST_CLARINET_DEVNET_IMAGE,
    CLARINET_DEVNET_IMAGE_TAG,
  ]
  cache-from = [
    LOCAL_CLARINET_DEVNET_IMAGE_DOCKER_BUILDX_CACHE_READ,
  ]
  cache-to = [
    LOCAL_CLARINET_DEVNET_IMAGE_DOCKER_BUILDX_CACHE_WRITE
  ]
}
