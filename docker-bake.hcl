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

group "vegito-example-application-release-ci" {
  targets = [
    "vegito-example-application-services-ci",
    "vegito-example-application-applications-ci"
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

variable "VEGITO_EXAMPLE_APPLICATION_BUILDER_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_EXAMPLE_APPLICATION_CACHE_IMAGES_BASE}/builder"
}

variable "EXAMPLE_APPLICATION_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/builder-version"
}

variable "EXAMPLE_APPLICATION_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/builder-latest"
}

variable "EXAMPLE_APPLICATION_BUILDER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION" {
  description = "local write cache (version) for example-application-builder image build"
  default     = "type=local,mode=max,dest=${EXAMPLE_APPLICATION_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "EXAMPLE_APPLICATION_BUILDER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST" {
  description = "local write cache (latest) for example-application-builder image build"
  default     = "type=local,mode=max,dest=${EXAMPLE_APPLICATION_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "EXAMPLE_APPLICATION_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION" {
  description = "local read cache (version) for example-application-builder image build (cannot be used before first write)"
  default     = "type=local,src=${EXAMPLE_APPLICATION_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "EXAMPLE_APPLICATION_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST" {
  description = "local read cache (latest) for example-application-builder image build (cannot be used before first write)"
  default     = "type=local,src=${EXAMPLE_APPLICATION_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
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
    EXAMPLE_APPLICATION_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST,
    "type=inline,ref=${EXAMPLE_APPLICATION_BUILDER_IMAGE_LATEST}",
  ]
  cache-to = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_EXAMPLE_APPLICATION_BUILDER_IMAGE_REGISTRY_CACHE},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      EXAMPLE_APPLICATION_BUILDER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : []
  )
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
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_EXAMPLE_APPLICATION_BUILDER_IMAGE_REGISTRY_CACHE}"
    ] : [],
    [
      EXAMPLE_APPLICATION_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION,
      "type=inline,ref=${EXAMPLE_APPLICATION_BUILDER_IMAGE_LATEST}",
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      EXAMPLE_APPLICATION_BUILDER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION
    ] : []
  )
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
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_EXAMPLE_APPLICATION_BUILDER_IMAGE_REGISTRY_CACHE}"
    ] : [],
    [
      EXAMPLE_APPLICATION_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST,
      "type=inline,ref=${EXAMPLE_APPLICATION_BUILDER_IMAGE_LATEST}",
    ]
  )
  cache-to = ENABLE_LOCAL_CACHE ? [ EXAMPLE_APPLICATION_BUILDER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST ] : []
  platforms = platforms
}
