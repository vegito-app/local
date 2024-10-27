variable "APPLICATION_BACKEND_IMAGES_BASE" {
  default = "${PRIVATE_IMAGES_BASE}:backend"
}

variable "APPLICATION_BACKEND_IMAGE_VERSION" {
  default = notequal("dev", VERSION) ? "${PRIVATE_IMAGES_BASE}:backend-${VERSION}" : ""
}

variable "LATEST_APPLICATION_BACKEND_IMAGE" {
  default = "${APPLICATION_BACKEND_IMAGES_BASE}-latest"
}

target "backend-ci" {
  dockerfile = "application/backend/Dockerfile"
  args = {
    builder_image = LATEST_BUILDER_IMAGE
  }
  tags = [
    notequal("", VERSION) ? APPLICATION_BACKEND_IMAGE_VERSION : "",
    LATEST_APPLICATION_BACKEND_IMAGE,
  ]
  platforms = platforms
  cache-from = [
    LATEST_BUILDER_IMAGE,
    LATEST_APPLICATION_BACKEND_IMAGE,
  ]
  cache-to = [
    "type=inline",
  ]
}

variable "APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE" {
  description = "local write cache for backend image build"
}

variable "APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  description = "local read cache for backend image build (cannot be used before first write)"
}

target "backend" {
  dockerfile = "application/backend/Dockerfile"
  args = {
    builder_image = LATEST_BUILDER_IMAGE
  }
  tags = [
    notequal("", VERSION) ? APPLICATION_BACKEND_IMAGE_VERSION : "",
    LATEST_APPLICATION_BACKEND_IMAGE,
  ]
  cache-from = [
    APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
    BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
  ]
  cache-to = [
    APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE,
  ]
}
