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

group "vegito-example-application-builders" {
  targets = [
    "vegito-example-application-builder",
  ]
}

group "vegito-example-application-builders-ci" {
  targets = [
    "vegito-example-application-builder-ci",
    "vegito-example-application-builder-latest-ci",
  ]
}

group "vegito-example-application-services" {
  targets = [
    "vegito-example-application-backend",
  ]
}

group "vegito-example-application-services-ci" {
  targets = [
    "vegito-example-application-backend-ci",
    "vegito-example-application-backend-latest-ci",
  ]
}

group "vegito-example-application-applications" {
  targets = [
    "vegito-example-application-mobile",
    "vegito-example-application-tests",
  ]
}

group "vegito-example-application-applications-ci" {
  targets = [
    "vegito-example-application-mobile-ci",
    "vegito-example-application-mobile-latest-ci",
    "vegito-example-application-tests-ci",
    "vegito-example-application-tests-latest-ci",

  ]
}

variable "EXAMPLE_APPLICATION_IMAGES_BASE" {
  default = "${VEGITO_PUBLIC_REPOSITORY}/example-application"
}
variable "EXAMPLE_APPLICATION_BUILDER_IMAGE_VERSION" {
  default = "${EXAMPLE_APPLICATION_IMAGES_BASE}:builder-${VERSION}"
}

variable "EXAMPLE_APPLICATION_BUILDER_IMAGE_LATEST" {
  default = "${EXAMPLE_APPLICATION_IMAGES_BASE}:builder-latest"
}

variable "EXAMPLE_APPLICATION_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/example-application-builder"
}

variable "EXAMPLE_APPLICATION_BUILDER_IMAGE_REGISTRY_CACHE" {
  default = "${EXAMPLE_APPLICATION_IMAGES_BASE}/cache/example-application-builder"
}

variable "EXAMPLE_APPLICATION_BUILDER_IMAGE_REGISTRY_CACHE_CI" {
  default = "${EXAMPLE_APPLICATION_IMAGES_BASE}/cache/example-application-builder/ci"
}

variable "EXAMPLE_APPLICATION_BUILDER_IMAGE_DOCKER_BUILDX_CACHE_WRITE" {
  description = "local write cache for example-application-builder image build"
  default     = "type=local,mode=max,dest=${EXAMPLE_APPLICATION_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "EXAMPLE_APPLICATION_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  description = "local read cache for example-application-builder image build (cannot be used before first write)"
  default     = "type=local,src=${EXAMPLE_APPLICATION_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}


target "vegito-example-application-builder" {
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

target "vegito-example-application-builder-ci" {
  dockerfile = "Dockerfile"
  context    = VEGITO_EXAMPLE_APPLICATION_DIR
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

target "vegito-example-application-builder-latest-ci" {
  dockerfile = "Dockerfile"
  context    = VEGITO_EXAMPLE_APPLICATION_DIR
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
