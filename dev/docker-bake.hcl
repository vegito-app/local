variable "BUILDER_IMAGE_VERSION" {
  default = notequal("dev", VERSION) ? "${PUBLIC_IMAGES_BASE}:builder-${VERSION}" : ""
}

variable "LATEST_BUILDER_IMAGE" {
  default = "${PUBLIC_IMAGES_BASE}:builder-latest"
}

target "builder-ci" {
  dockerfile = "dev/builder.Dockerfile"
  args = {
    docker_version = DOCKER_VERSION
  }
  tags = [
    LATEST_BUILDER_IMAGE,
    notequal("", VERSION) ? BUILDER_IMAGE_VERSION : "",
  ]
  cache-from = [LATEST_BUILDER_IMAGE]
  cache-to   = ["type=inline"]
  platforms  = platforms
}

variable "BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE" {
  description = "local write cache for builder image build"
}

variable "BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  description = "local read cache for builder image build (cannot be used before first write)"
}

target "builder" {
  dockerfile = "dev/builder.Dockerfile"
  args = {
    docker_version = DOCKER_VERSION
  }
  tags = [
    LATEST_BUILDER_IMAGE,
    notequal("", VERSION) ? BUILDER_IMAGE_VERSION : "",
  ]
  cache-from = [
    BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
  ]
  cache-to = [
    BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE
  ]
}
