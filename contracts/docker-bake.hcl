variable "CLARINET_DEVNET_IMAGE_TAG" {
  default = notequal("", VERSION) ? "${PUBLIC_IMAGES_BASE}:clarinet-devnet-${VERSION}" : ""
}

variable "LATEST_CLARINET_DEVNET_IMAGE" {
  default = "${PUBLIC_IMAGES_BASE}:clarinet-devnet-latest"
}

variable "CLARINET_DEVNET_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE" {
  description = "local write cache for clarinet-devnet image build"
}

variable "CLARINET_DEVNET_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  description = "local read cache for clarinet-devnet image build (cannot be used before first write)"
}

target "clarinet-devnet-ci" {
  args = {
    builder_image = LATEST_BUILDER_IMAGE
  }
  context    = "local/android"
  dockerfile = "studio.Dockerfile"
  tags = [
    LATEST_CLARINET_DEVNET_IMAGE,
    CLARINET_DEVNET_IMAGE_TAG,
  ]
  cache-from = [
    LATEST_BUILDER_IMAGE,
    LATEST_CLARINET_DEVNET_IMAGE
  ]
  cache-to  = ["type=inline"]
  platforms = platforms
  push      = true
}

target "clarinet-devnet" {
  args = {
    builder_image = LATEST_BUILDER_IMAGE
  }
  context    = "contracts"
  dockerfile = "clarinet.Dockerfile"
  tags = [
    LATEST_CLARINET_DEVNET_IMAGE,
    CLARINET_DEVNET_IMAGE_TAG,
  ]
  cache-from = [
    CLARINET_DEVNET_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
    BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
  ]
  cache-to = [
    CLARINET_DEVNET_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE
  ]
  load = true
}
