variable "LOCAL_EXAMPLE_APPLICATIONBACKEND_DIR" {
  description = "current git tag or commit version"
  default     = "application/backend"
}

variable "VERSION" {
  description = "current git tag or commit version"
  default     = "dev"
}

variable "LOCAL_EXAMPLE_APPLICATION_BACKEND_IMAGES_BASE" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:application-backend"
}

variable "LOCAL_EXAMPLE_APPLICATION_BACKEND_IMAGE" {
  default = notequal("dev", VERSION) ? "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:application-backend-${VERSION}" : ""
}

variable "LOCAL_EXAMPLE_APPLICATION_BACKEND_IMAGE_LATEST" {
  default = "${LOCAL_EXAMPLE_APPLICATION_BACKEND_IMAGES_BASE}-latest"
}

variable "LOCAL_EXAMPLE_APPLICATION_BACKEND_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_APP_PUBLIC_IMAGES_BASE}/cache/application-backend"
}

variable "LOCAL_EXAMPLE_APPLICATION_BACKEND_IMAGE_REGISTRY_CACHE_CI" {
  default = "${VEGITO_APP_PUBLIC_IMAGES_BASE}/cache/application-backend/ci"
}
variable "LOCAL_EXAMPLE_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE" {
  default = "${LOCAL_EXAMPLE_APPLICATIONBACKEND_DIR}/.containers/application-backend/docker-buildx-cache"
}

variable "LOCAL_EXAMPLE_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_CACHE_WRITE" {
  description = "local write cache for local-example-application-backend image build"
  default = "type=local,mode=max,dest=${LOCAL_EXAMPLE_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "LOCAL_EXAMPLE_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  description = "local read cache for local-example-application-backend image build (cannot be used before first write)"
  default = "type=local,src=${LOCAL_EXAMPLE_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

target "local-example-application-backend-ci" {
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
    LOCAL_EXAMPLE_APPLICATION_BACKEND_IMAGE,
    LOCAL_EXAMPLE_APPLICATION_BACKEND_IMAGE_LATEST,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_EXAMPLE_APPLICATION_BACKEND_IMAGE_REGISTRY_CACHE}" : "",
    "type=inline,ref=${LOCAL_EXAMPLE_APPLICATION_BACKEND_IMAGE_LATEST}",
    LOCAL_EXAMPLE_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_EXAMPLE_APPLICATION_BACKEND_IMAGE_REGISTRY_CACHE},mode=max" : "type=inline",
  ]
  platforms = [
    "linux/amd64",
  ]
  push = true
}

target "local-example-application-backend" {
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
    LOCAL_EXAMPLE_APPLICATION_BACKEND_IMAGE,
    LOCAL_EXAMPLE_APPLICATION_BACKEND_IMAGE_LATEST,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_EXAMPLE_APPLICATION_BACKEND_IMAGE_REGISTRY_CACHE}" : "",
    LOCAL_EXAMPLE_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
    "type=inline,ref=${LOCAL_EXAMPLE_APPLICATION_BACKEND_IMAGE_LATEST}",
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_EXAMPLE_APPLICATION_BACKEND_IMAGE_REGISTRY_CACHE},mode=max" : LOCAL_EXAMPLE_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_CACHE_WRITE,
  ]
}
