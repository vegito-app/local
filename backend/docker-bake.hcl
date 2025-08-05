variable "APPLICATION_BACKEND_IMAGES_BASE" {
  default = "${PRIVATE_IMAGES_BASE}:application-backend"
}

variable "APPLICATION_BACKEND_IMAGE_VERSION" {
  default = notequal("latest", VERSION) ? "${PRIVATE_IMAGES_BASE}:application-backend-${VERSION}" : ""
}

variable "LATEST_APPLICATION_BACKEND_IMAGE" {
  default = "${APPLICATION_BACKEND_IMAGES_BASE}-latest"
}

target "application-backend-ci" {
  context = APPLICATION_DIR  
  dockerfile = "backend/Dockerfile"
  args = {
    builder_image = LATEST_BUILDER_IMAGE
    application_directory = "."
  }
  tags = [
    notequal("", VERSION) ? APPLICATION_BACKEND_IMAGE_VERSION : "",
    LATEST_APPLICATION_BACKEND_IMAGE,
  ]
  cache-from = [
    LATEST_BUILDER_IMAGE,
    LATEST_APPLICATION_BACKEND_IMAGE,
  ]
  cache-to = [
    "type=inline",
  ]
  platforms = [
    "linux/amd64",
  ]
}

variable "APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE" {
  description = "local write cache for backend image build"
}

variable "APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  description = "local read cache for backend image build (cannot be used before first write)"
}

target "application-backend" {
  dockerfile = "backend/Dockerfile"
  context = APPLICATION_DIR  
  args = {
    builder_image = LATEST_BUILDER_IMAGE
    application_directory = "."
  }
  tags = [
    notequal("", VERSION) ? APPLICATION_BACKEND_IMAGE_VERSION : "",
    LATEST_APPLICATION_BACKEND_IMAGE,
  ]
  cache-from = [
    APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
  ]
  cache-to = [
    APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE,
  ]
}
