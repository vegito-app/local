variable "LOCAL_APPLICATION_VERSION" {
  description = "current git tag or commit version"
  default     = "dev"
}

variable "LOCAL_APPLICATION_BACKEND_IMAGES_BASE" {
  default = "${VEGITO_PUBLIC_IMAGES_BASE}:application-backend"
}

variable "LOCAL_APPLICATION_BACKEND_IMAGE_VERSION" {
  default = notequal("dev", VERSION) ? "${VEGITO_PUBLIC_IMAGES_BASE}:application-backend-${VERSION}" : ""
}

variable "LOCAL_APPLICATION_BACKEND_IMAGE_LATEST" {
  default = "${LOCAL_APPLICATION_BACKEND_IMAGES_BASE}-latest"
}

target "application-backend-ci" {
  dockerfile = "application/backend/Dockerfile"
  args = {
    builder_image = LOCAL_BUILDER_IMAGE_LATEST
  }
  tags = [
    notequal("", LOCAL_APPLICATION_VERSION) ? LOCAL_APPLICATION_BACKEND_IMAGE_VERSION : "",
    LOCAL_APPLICATION_BACKEND_IMAGE_LATEST,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_APPLICATION_BACKEND_REGISTRY_CACHE_IMAGE}" : "",
    "type=inline,ref=${LOCAL_APPLICATION_BACKEND_IMAGE_LATEST}",
    LOCAL_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_APPLICATION_BACKEND_REGISTRY_CACHE_IMAGE},mode=max" : "type=inline"
  ]
  platforms = [
    "linux/amd64",
  ]
  push = true
}

variable "LOCAL_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE" {
  description = "local write cache for backend image build"
}

variable "LOCAL_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  description = "local read cache for backend image build (cannot be used before first write)"
}

target "application-backend" {
  dockerfile = "application/backend/Dockerfile"
  args = {
    builder_image = LOCAL_BUILDER_IMAGE_LATEST
  }
  tags = [
    notequal("", LOCAL_APPLICATION_VERSION) ? LOCAL_APPLICATION_BACKEND_IMAGE_VERSION : "",
    LOCAL_APPLICATION_BACKEND_IMAGE_LATEST,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_APPLICATION_BACKEND_REGISTRY_CACHE_IMAGE}" : "",
    LOCAL_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
    "type=inline,ref=${LOCAL_APPLICATION_BACKEND_IMAGE_LATEST}",
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_APPLICATION_BACKEND_REGISTRY_CACHE_IMAGE},mode=max" : LOCAL_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE,
  ]
}
