variable "LOCAL_TRIVY_IMAGE_VERSION" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:trivy-${VERSION}"
}

variable "LOCAL_TRIVY_IMAGE_LATEST" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:trivy-latest"
}

variable "LOCAL_TRIVY_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_LOCAL_CACHE_IMAGES_BASE}/trivy"
}

variable "LOCAL_TRIVY_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/trivy-version"
}

variable "LOCAL_TRIVY_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/trivy-latest"
}

variable "LOCAL_TRIVY_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION" {
  default = "type=local,mode=max,dest=${LOCAL_TRIVY_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "LOCAL_TRIVY_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST" {
  default = "type=local,mode=max,dest=${LOCAL_TRIVY_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "LOCAL_TRIVY_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION" {
  default = "type=local,src=${LOCAL_TRIVY_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "LOCAL_TRIVY_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST" {
  default = "type=local,src=${LOCAL_TRIVY_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

group "local-trivy-ci" {
  targets = [
    "local-trivy-version-ci",
    "local-trivy-latest-ci",
  ]
}

target "local-trivy-version-ci" {
  contexts = {
    debian = "docker-image://${LOCAL_DEBIAN_IMAGE_VERSION}"
  }
  args = {
    trivy_version = TRIVY_VERSION
  }
  context    = "${LOCAL_DIR}/trivy"
  dockerfile = "Dockerfile"
  tags = [
    LOCAL_TRIVY_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_TRIVY_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_TRIVY_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_TRIVY_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION
    ] : [],
    [
      "type=inline,ref=${LOCAL_TRIVY_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_TRIVY_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION
    ] : [],
  )
  platforms = platforms
}

target "local-trivy-latest-ci" {
  contexts = {
    debian = "docker-image://${LOCAL_DEBIAN_IMAGE_LATEST}"
  }
  args = {
    trivy_version = TRIVY_VERSION
  }
  context    = "${LOCAL_DIR}/trivy"
  dockerfile = "Dockerfile"
  tags = [
    LOCAL_TRIVY_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_TRIVY_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_TRIVY_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      "type=inline,ref=${LOCAL_TRIVY_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_TRIVY_IMAGE_REGISTRY_CACHE},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_TRIVY_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : [],
    [
      "type=inline"
    ]
  )
  platforms = platforms
}

target "local-trivy" {
  contexts = {
    debian = "docker-image://${LOCAL_DEBIAN_IMAGE_VERSION}"
  }
  args = {
    trivy_version = TRIVY_VERSION
  }
  context    = "${LOCAL_DIR}/trivy"
  dockerfile = "Dockerfile"
  tags = [
    LOCAL_TRIVY_IMAGE_LATEST,
    LOCAL_TRIVY_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_TRIVY_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_TRIVY_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      "type=inline,ref=${LOCAL_TRIVY_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_TRIVY_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : []
  )
}
