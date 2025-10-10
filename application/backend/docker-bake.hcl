variable "LOCAL_APPLICATION_BACKEND_DIR" {
  description = "current git tag or commit version"
  default     = "application/backend"
}

variable "VERSION" {
  description = "current git tag or commit version"
  default     = "dev"
}

variable "LOCAL_APPLICATION_BACKEND_IMAGES_BASE" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:application-backend"
}

variable "LOCAL_APPLICATION_BACKEND_IMAGE" {
  default = notequal("dev", VERSION) ? "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:application-backend-${VERSION}" : ""
}

variable "LOCAL_APPLICATION_BACKEND_IMAGE_LATEST" {
  default = "${LOCAL_APPLICATION_BACKEND_IMAGES_BASE}-latest"
}

variable "LOCAL_APPLICATION_BACKEND_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_APP_PUBLIC_IMAGES_BASE}/cache/application-backend"
}

variable "LOCAL_APPLICATION_BACKEND_IMAGE_REGISTRY_CACHE_CI" {
  default = "${VEGITO_APP_PUBLIC_IMAGES_BASE}/cache/application-backend/ci"
}
variable "LOCAL_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE" {
  default = "${LOCAL_APPLICATION_BACKEND_DIR}/.containers/application-backend/docker-buildx-cache"
}

variable "LOCAL_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_CACHE_WRITE" {
  description = "local write cache for local-application-backend image build"
  default = "type=local,mode=max,dest=${LOCAL_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "LOCAL_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  description = "local read cache for local-application-backend image build (cannot be used before first write)"
  default = "type=local,src=${LOCAL_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

target "local-application-backend-ci" {
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
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_APPLICATION_BACKEND_IMAGE_REGISTRY_CACHE}" : "",
    "type=inline,ref=${LOCAL_APPLICATION_BACKEND_IMAGE_LATEST}",
    LOCAL_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_APPLICATION_BACKEND_IMAGE_REGISTRY_CACHE},mode=max" : "type=inline",
  ]
  platforms = [
    "linux/amd64",
  ]
  push = true
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
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_APPLICATION_BACKEND_IMAGE_REGISTRY_CACHE}" : "",
    LOCAL_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
    "type=inline,ref=${LOCAL_APPLICATION_BACKEND_IMAGE_LATEST}",
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_APPLICATION_BACKEND_IMAGE_REGISTRY_CACHE},mode=max" : LOCAL_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_CACHE_WRITE,
  ]
}
