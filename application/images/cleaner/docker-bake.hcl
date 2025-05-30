variable "APPLICATION_IMAGES_CLEANER_IMAGE_BASE" {
  default = "${PRIVATE_IMAGES_BASE}:application-images-cleaner"
}

variable "APPLICATION_IMAGES_CLEANER_IMAGE_VERSION" {
  default = notequal("dev", VERSION) ? "${PRIVATE_IMAGES_BASE}:application-images-cleaner-${VERSION}" : ""
}

variable "LATEST_APPLICATION_IMAGES_CLEANER_IMAGE" {
  default = "${APPLICATION_IMAGES_CLEANER_IMAGE_BASE}-latest"
}

target "application-images-cleaner-ci" {
  dockerfile = "application/images/cleaner/Dockerfile"
  args = {
    builder_image = LATEST_BUILDER_IMAGE
  }
  tags = [
    notequal("", VERSION) ? APPLICATION_IMAGES_CLEANER_IMAGE_VERSION : "",
    LATEST_APPLICATION_IMAGES_CLEANER_IMAGE,
  ]
  cache-from = [
    # LATEST_BUILDER_IMAGE,
    LATEST_APPLICATION_IMAGES_CLEANER_IMAGE,
  ]
  cache-to = [
    "type=inline",
  ]
  platforms = [
    "linux/amd64",
  ]
}

variable "APPLICATION_IMAGES_CLEANER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE" {
  description = "local write cache for application-images-cleaner image build"
}

variable "APPLICATION_IMAGES_CLEANER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  description = "local read cache for application-images-cleaner image build (cannot be used before first write)"
}

target "application-images-cleaner" {
  dockerfile = "application/images/cleaner/Dockerfile"
  args = {
    builder_image = LATEST_BUILDER_IMAGE
  }
  tags = [
    notequal("", VERSION) ? APPLICATION_IMAGES_CLEANER_IMAGE_VERSION : "",
    LATEST_APPLICATION_IMAGES_CLEANER_IMAGE,
  ]
  cache-from = [
    APPLICATION_IMAGES_CLEANER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
    BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
  ]
  cache-to = [
    APPLICATION_IMAGES_CLEANER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE,
  ]
}
