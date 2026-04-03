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

variable "VEGITO_EXAMPLE_APPLICATION_PUBLIC_IMAGES_BASE" {
  default = "${VEGITO_PUBLIC_REPOSITORY}/example-application"
}

variable "EXAMPLE_APPLICATION_PRIVATE_IMAGES_BASE" {
  default = "${VEGITO_PRIVATE_REPOSITORY}/example-application"
}

variable "VEGITO_EXAMPLE_APPLICATION_CACHE_IMAGES_BASE" {
  default = "${VEGITO_CACHE_REPOSITORY}/example-application"
}

group "vegito-example-application-ci" {
  targets = [
    "vegito-example-application-builders-ci",
    "vegito-example-application-services-ci",
    "vegito-example-application-applications-ci",
  ]
}

group "vegito-example-application-builders" {
  targets = [
    "vegito-example-application-builder",
  ]
}

group "vegito-example-application-builders-ci" {
  targets = [
    "vegito-example-application-builder-ci",
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
    "vegito-example-application-tests-ci",
  ]
}

variable "EXAMPLE_APPLICATION_IMAGES_BASE" {
  default = "${VEGITO_PUBLIC_REPOSITORY}/example-application"
}

variable "EXAMPLE_APPLICATION_BUILDER_IMAGE_VERSION" {
  default = "${EXAMPLE_APPLICATION_IMAGES_BASE}:builder-${VERSION}"
}

variable "EXAMPLE_APPLICATION_BUILDER_BASE_CONTEXT" {
  default = "docker-image://${LOCAL_BUILDER_IMAGE_VERSION}"
}

variable "EXAMPLE_APPLICATION_BUILDER_IMAGE_LATEST" {
  default = "${EXAMPLE_APPLICATION_IMAGES_BASE}:builder-latest"
}

variable "EXAMPLE_APPLICATION_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/builder"
}

variable "VEGITO_EXAMPLE_APPLICATION_BUILDER_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_EXAMPLE_APPLICATION_CACHE_IMAGES_BASE}/builder"
}

variable "EXAMPLE_APPLICATION_BUILDER_IMAGE_DOCKER_BUILDX_CACHE_WRITE" {
  description = "local write cache for example-application-builder image build"
  default     = "type=local,mode=max,dest=${EXAMPLE_APPLICATION_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "EXAMPLE_APPLICATION_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  description = "local read cache for example-application-builder image build (cannot be used before first write)"
  default     = "type=local,src=${EXAMPLE_APPLICATION_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "VEGITO_EXAMPLE_APPLICATION_BUILDER_BASE_CONTEXT_CI" {
  default = "docker-image://${LOCAL_BUILDER_IMAGE_VERSION}"
}

target "vegito-example-application-builder" {
  contexts = {
    builder = "docker-image://${LOCAL_BUILDER_IMAGE_VERSION}"
  }
  context    = VEGITO_EXAMPLE_APPLICATION_DIR
  dockerfile = "Dockerfile"
  tags = [
    EXAMPLE_APPLICATION_BUILDER_IMAGE_LATEST,
    notequal("", VERSION) ? EXAMPLE_APPLICATION_BUILDER_IMAGE_VERSION : "",
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${VEGITO_EXAMPLE_APPLICATION_BUILDER_IMAGE_REGISTRY_CACHE}" : "",
    EXAMPLE_APPLICATION_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
    "type=inline,ref=${EXAMPLE_APPLICATION_BUILDER_IMAGE_LATEST}",
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${VEGITO_EXAMPLE_APPLICATION_BUILDER_IMAGE_REGISTRY_CACHE},mode=max" : EXAMPLE_APPLICATION_BUILDER_IMAGE_DOCKER_BUILDX_CACHE_WRITE
  ]
}

group "vegito-example-application-builder-ci" {
  targets = [
    "vegito-example-application-builder-version-ci",
    "vegito-example-application-builder-latest-ci",
  ]
}

target "vegito-example-application-builder-version-ci" {
  dockerfile = "Dockerfile"
  context    = VEGITO_EXAMPLE_APPLICATION_DIR
  contexts = {
    builder = VEGITO_EXAMPLE_APPLICATION_BUILDER_BASE_CONTEXT_CI
  }
  tags = [
    EXAMPLE_APPLICATION_BUILDER_IMAGE_VERSION,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${VEGITO_EXAMPLE_APPLICATION_BUILDER_IMAGE_REGISTRY_CACHE}" : "",
    "type=inline,ref=${EXAMPLE_APPLICATION_BUILDER_IMAGE_LATEST}",
  ]
  cache-to  = []
  platforms = platforms
}

target "vegito-example-application-builder-latest-ci" {
  dockerfile = "Dockerfile"
  context    = VEGITO_EXAMPLE_APPLICATION_DIR
  contexts = {
    builder = VEGITO_EXAMPLE_APPLICATION_BUILDER_BASE_CONTEXT_CI
  }
  tags = [
    EXAMPLE_APPLICATION_BUILDER_IMAGE_LATEST
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${VEGITO_EXAMPLE_APPLICATION_BUILDER_IMAGE_REGISTRY_CACHE}" : "",
    "type=inline,ref=${EXAMPLE_APPLICATION_BUILDER_IMAGE_LATEST}",
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${VEGITO_EXAMPLE_APPLICATION_BUILDER_IMAGE_REGISTRY_CACHE},mode=max" : "type=inline"
  ]
  platforms = platforms
}
