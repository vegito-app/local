variable "LOCAL_APPLICATION_VERSION" {
  description = "current git tag or commit version"
  default     = "dev"
}

variable "LOCAL_APPLICATION_BACKEND_IMAGES_BASE" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:application-backend"
}

variable "LOCAL_APPLICATION_BACKEND_IMAGE" {
  default = notequal("dev", LOCAL_APPLICATION_VERSION) ? "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:application-backend-${LOCAL_APPLICATION_VERSION}" : ""
}

variable "LOCAL_APPLICATION_BACKEND_IMAGE_LATEST" {
  default = "${LOCAL_APPLICATION_BACKEND_IMAGES_BASE}-latest"
}

variable "LOCAL_APPLICATION_BACKEND_REGISTRY_CACHE_IMAGE" {
  default = "${VEGITO_APP_PRIVATE_IMAGES_BASE}/cache/application-backend"
}

variable "LOCAL_APPLICATION_BACKEND_REGISTRY_CACHE_IMAGE_CI" {
  default = "${VEGITO_APP_PRIVATE_IMAGES_BASE}/cache/application-backend/ci"
}

target "local-application-backend-ci" {
  context = "application/backend"
  contexts = {
    "approot" : "application"
  }
  args = {
    builder_image = LOCAL_BUILDER_IMAGE_LATEST
  }
  tags = [
    LOCAL_APPLICATION_BACKEND_IMAGE,
    LOCAL_APPLICATION_BACKEND_IMAGE_LATEST,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_APPLICATION_BACKEND_REGISTRY_CACHE_IMAGE}" : "",
    "type=inline,ref=${LOCAL_APPLICATION_BACKEND_IMAGE_LATEST}",
    LOCAL_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_APPLICATION_BACKEND_REGISTRY_CACHE_IMAGE},mode=max" : "type=inline",
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

target "local-application-backend" {
  context = "application/backend"
  contexts = {
    "approot" : "application"
    "appfrontend" : "application/frontend"
    "project" : "."
  }
  args = {
    builder_image = LOCAL_BUILDER_IMAGE_LATEST
  }
  tags = [
    LOCAL_APPLICATION_BACKEND_IMAGE,
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
