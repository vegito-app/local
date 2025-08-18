variable "LOCAL_APPLICATION_VERSION" {
  description = "current git tag or commit version"
  default     = "dev"
}

variable "LOCAL_APPLICATION_BACKEND_IMAGES_BASE" {
  default = "${VEGITO_PUBLIC_IMAGES_BASE}:application-backend"
}

variable "LOCAL_APPLICATION_BACKEND_IMAGE" {
  default = notequal("dev", LOCAL_APPLICATION_VERSION) ? "${VEGITO_PUBLIC_IMAGES_BASE}:application-backend-${LOCAL_APPLICATION_VERSION}" : ""
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
    LOCAL_APPLICATION_BACKEND_IMAGE,
    LOCAL_APPLICATION_BACKEND_IMAGE_LATEST,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${APPLICATION_BACKEND_REGISTRY_CACHE_IMAGE}" : "",
    LOCAL_BUILDER_IMAGE_LATEST,
    LOCAL_APPLICATION_BACKEND_IMAGE_LATEST,
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${APPLICATION_BACKEND_REGISTRY_CACHE_IMAGE},mode=max" : "type=inline",
  ]
  platforms = [
    "linux/amd64",
  ]
  push = true
}

variable "APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE" {
  description = "local write cache for backend image build"
}

variable "APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  description = "local read cache for backend image build (cannot be used before first write)"
}

target "application-backend" {
  dockerfile = "application/backend/Dockerfile"
  args = {
    builder_image = LOCAL_BUILDER_IMAGE_LATEST
  }
  tags = [
    LOCAL_APPLICATION_BACKEND_IMAGE,
    LOCAL_APPLICATION_BACKEND_IMAGE_LATEST,
  ]
  cache-from = [
    APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
    USE_REGISTRY_CACHE ? "type=registry,ref=${APPLICATION_BACKEND_REGISTRY_CACHE_IMAGE}" : "",
  ]
  cache-to = [
    APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE,
    USE_REGISTRY_CACHE ? "type=registry,ref=${APPLICATION_BACKEND_REGISTRY_CACHE_IMAGE},mode=max" : "",
  ]
}
