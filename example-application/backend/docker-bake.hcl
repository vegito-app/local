variable "LOCAL_EXAMPLE_APPLICATIONBACKEND_DIR" {
  description = "current git tag or commit version"
  default     = "application/backend"
}

variable "VERSION" {
  description = "current git tag or commit version"
  default     = "dev"
}

variable "EXAMPLE_APPLICATION_BACKEND_IMAGES_BASE" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:application-backend"
}

variable "EXAMPLE_APPLICATION_BACKEND_IMAGE" {
  default = notequal("dev", VERSION) ? "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:application-backend-${VERSION}" : ""
}

variable "EXAMPLE_APPLICATION_BACKEND_IMAGE_LATEST" {
  default = "${EXAMPLE_APPLICATION_BACKEND_IMAGES_BASE}-latest"
}

variable "EXAMPLE_APPLICATION_BACKEND_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_APP_PUBLIC_IMAGES_BASE}/cache/application-backend"
}

variable "EXAMPLE_APPLICATION_BACKEND_IMAGE_REGISTRY_CACHE_CI" {
  default = "${VEGITO_APP_PUBLIC_IMAGES_BASE}/cache/application-backend/ci"
}
variable "EXAMPLE_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE" {
  default = "${LOCAL_EXAMPLE_APPLICATIONBACKEND_DIR}/.containers/application-backend/docker-buildx-cache"
}

variable "EXAMPLE_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_CACHE_WRITE" {
  description = "local write cache for example-application-backend image build"
  default     = "type=local,mode=max,dest=${EXAMPLE_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "EXAMPLE_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  description = "local read cache for example-application-backend image build (cannot be used before first write)"
  default     = "type=local,src=${EXAMPLE_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

target "example-application-backend-ci" {
  context = "example-application/backend"
  contexts = {
    "approot" : "example-application"
    "appfrontend" : "example-application/frontend"
    "project" : "."
  }
  args = {
    builder_image = LOCAL_BUILDER_IMAGE_VERSION
  }
  tags = [
    EXAMPLE_APPLICATION_BACKEND_IMAGE,
    EXAMPLE_APPLICATION_BACKEND_IMAGE_LATEST,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${EXAMPLE_APPLICATION_BACKEND_IMAGE_REGISTRY_CACHE}" : "",
    "type=inline,ref=${EXAMPLE_APPLICATION_BACKEND_IMAGE_LATEST}",
    EXAMPLE_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${EXAMPLE_APPLICATION_BACKEND_IMAGE_REGISTRY_CACHE},mode=max" : "type=inline",
  ]
  platforms = [
    "linux/amd64",
  ]
  push = true
}

target "example-application-backend" {
  context = "example-application/backend"
  contexts = {
    "approot" : "example-application"
    "appfrontend" : "example-application/frontend"
    "project" : "."
  }
  args = {
    builder_image = LOCAL_BUILDER_IMAGE_LATEST
  }
  tags = [
    EXAMPLE_APPLICATION_BACKEND_IMAGE,
    EXAMPLE_APPLICATION_BACKEND_IMAGE_LATEST,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${EXAMPLE_APPLICATION_BACKEND_IMAGE_REGISTRY_CACHE}" : "",
    EXAMPLE_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
    "type=inline,ref=${EXAMPLE_APPLICATION_BACKEND_IMAGE_LATEST}",
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${EXAMPLE_APPLICATION_BACKEND_IMAGE_REGISTRY_CACHE},mode=max" : EXAMPLE_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_CACHE_WRITE,
  ]
}
