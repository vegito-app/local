

variable "LOCAL_TRIVY_IMAGE_VERSION" {
  default = notequal("latest", VERSION) ? "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:trivy-${VERSION}" : ""
}

variable "LOCAL_TRIVY_IMAGE_LATEST" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:trivy-latest"
}

variable "LOCAL_TRIVY_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_LOCAL_CACHE_IMAGES_BASE}/trivy"
}

variable "LOCAL_TRIVY_IMAGE_DOCKER_BUILDX_LOCAL_CACHE" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/trivy"
}

variable "LOCAL_TRIVY_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE" {
  default = "type=local,mode=max,dest=${LOCAL_TRIVY_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

group "local-trivy-ci" {
  targets = [
    "local-trivy-version-ci",
    "local-trivy-latest-ci",
  ]
}

target "local-trivy-version-ci" {
  contexts = {
    debian = "target:local-debian-version-ci"
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
    [
      "type=inline,ref=${LOCAL_TRIVY_IMAGE_LATEST}"
    ]
  )
  cache-to  = []
  platforms = platforms
}

target "local-trivy-latest-ci" {
  contexts = {
    debian = "target:local-debian-version-ci"
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
    [
      "type=inline,ref=${LOCAL_TRIVY_IMAGE_LATEST}"
    ]
  )
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_TRIVY_IMAGE_REGISTRY_CACHE},mode=max" : "type=inline"
  ]
  platforms = platforms
}

target "local-trivy" {
  contexts = {
    debian = "target:local-debian-version-ci"
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
    ENABLE_LOCAL_CACHE ? [
      LOCAL_TRIVY_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_TRIVY_IMAGE_REGISTRY_CACHE}"
    ] : [],
    [
      "type=inline,ref=${LOCAL_TRIVY_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_TRIVY_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE
    ] : []
  )
}
