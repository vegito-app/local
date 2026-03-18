variable "VERSION" {
  description = "current git tag or commit version"
  default     = "local"
}
variable "LOCAL_VERSION" {
  description = "version of vegito-app/local repository"
}
variable "VEGITO_EXAMPLE_APPLICATION_DIR" {
  default = "."
}
variable "INFRA_ENV" {
  description = "production, staging or dev"
  default     = "dev"
}

variable "EXAMPLE_APPLICATION_PUBLIC_IMAGES_BASE" {
  default = "${VEGITO_PUBLIC_REPOSITORY}/example-application"
}

variable "EXAMPLE_APPLICATION_PRIVATE_IMAGES_BASE" {
  default = "${VEGITO_PRIVATE_REPOSITORY}/example-application"
}

group "example-application-builders" {
  targets = [
    "example-application-builder",
  ]
}

group "example-application-builders-ci" {
  targets = [
    "example-application-builder-ci",
    "example-application-builder-latest-ci",
  ]
}

group "example-application-services" {
  targets = [
    "example-application-backend",
  ]
}

group "example-application-services-ci" {
  targets = [
    "example-application-backend-ci",
    "example-application-backend-latest-ci",
  ]
}

group "example-application-applications" {
  targets = [
    "example-application-mobile",
    "example-application-tests",
  ]
}

group "example-application-applications-ci" {
  targets = [
    "example-application-mobile-ci",
    "example-application-mobile-latest-ci",
    "example-application-tests-ci",
    "example-application-tests-latest-ci",

  ]
}

variable "EXAMPLE_APPLICATION_BUILDER_IMAGE_VERSION" {
  default = notequal("latest", VERSION) ? "${EXAMPLE_APPLICATION_BUILDER_IMAGES_BASE}:builder-${VERSION}" : ""
}

variable "EXAMPLE_APPLICATION_BUILDER_IMAGE_LATEST" {
  default = "${EXAMPLE_APPLICATION_BUILDER_IMAGES_BASE}:builder-latest"
}

variable "EXAMPLE_APPLICATION_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/example-application-builder"
}

variable "EXAMPLE_APPLICATION_BUILDER_IMAGE_REGISTRY_CACHE" {
  default = "${EXAMPLE_APPLICATION_BUILDER_IMAGES_BASE}/cache/example-application-builder"
}

variable "EXAMPLE_APPLICATION_BUILDER_IMAGE_REGISTRY_CACHE_CI" {
  default = "${EXAMPLE_APPLICATION_BUILDER_IMAGES_BASE}/cache/example-application-builder/ci"
}

variable "EXAMPLE_APPLICATION_BUILDER_IMAGE_DOCKER_BUILDX_CACHE_WRITE" {
  description = "local write cache for example-application-builder image build"
  default     = "type=local,mode=max,dest=${EXAMPLE_APPLICATION_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "EXAMPLE_APPLICATION_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  description = "local read cache for example-application-builder image build (cannot be used before first write)"
  default     = "type=local,src=${EXAMPLE_APPLICATION_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "EXAMPLE_APPLICATION_BUILDER_IMAGE_VERSION" {
  default = notequal("latest", VERSION) ? "${EXAMPLE_APPLICATION_BUILDER_IMAGES_BASE}:dev-${VERSION}" : ""
}

variable "EXAMPLE_APPLICATION_BUILDER_IMAGE_LATEST" {
  default = "${EXAMPLE_APPLICATION_BUILDER_IMAGES_BASE}:dev-latest"
}

target "example-application-builder" {
  args = {
    local_builder_image = LOCAL_BUILDER_IMAGE_VERSION
  }
  context    = VEGITO_EXAMPLE_APPLICATION_DIR
  dockerfile = "Dockerfile"
  tags = [
    EXAMPLE_APPLICATION_BUILDER_IMAGE_LATEST,
    notequal("", VERSION) ? EXAMPLE_APPLICATION_BUILDER_IMAGE_VERSION : "",
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${EXAMPLE_APPLICATION_BUILDER_IMAGE_REGISTRY_CACHE}" : "",
    EXAMPLE_APPLICATION_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
    "type=inline,ref=${EXAMPLE_APPLICATION_BUILDER_IMAGE_LATEST}",
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${EXAMPLE_APPLICATION_BUILDER_IMAGE_REGISTRY_CACHE},mode=max" : EXAMPLE_APPLICATION_BUILDER_IMAGE_DOCKER_BUILDX_CACHE_WRITE
  ]
}

target "example-application-builder-ci" {
  dockerfile = "Dockerfile"
  context    = EXAMPLE_APPLICATION_DIR
  args = {
    local_builder_image = LOCAL_BUILDER_IMAGE_VERSION
  }
  tags = [
    EXAMPLE_APPLICATION_BUILDER_IMAGE_VERSION,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${EXAMPLE_APPLICATION_BUILDER_IMAGE_REGISTRY_CACHE_CI}" : "",
    "type=inline,ref=${EXAMPLE_APPLICATION_BUILDER_IMAGE_LATEST}",
  ]
  cache-to = []
}

target "example-application-builder-latest-ci" {
  dockerfile = "Dockerfile"
  context    = EXAMPLE_APPLICATION_DIR
  args = {
    local_builder_image = LOCAL_BUILDER_IMAGE_VERSION
  }
  tags = [
    EXAMPLE_APPLICATION_BUILDER_IMAGE_LATEST
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${EXAMPLE_APPLICATION_BUILDER_IMAGE_REGISTRY_CACHE_CI}" : "",
    "type=inline,ref=${EXAMPLE_APPLICATION_BUILDER_IMAGE_LATEST}",
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${EXAMPLE_APPLICATION_BUILDER_IMAGE_REGISTRY_CACHE_CI},mode=max" : "type=inline"
  ]
  platforms = platforms
}
