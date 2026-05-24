variable "VEGITO_DOCKER_DEBIAN_AI_VERSION" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:debian-ai-${VERSION}"
}

variable "VEGITO_DOCKER_DEBIAN_AI_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_CACHE_IMAGES_BASE}/vegito-debian-ai"
}

variable "VEGITO_DOCKER_DEBIAN_AI_DIR" {
  default = "${VEGITO_DOCKER_DEBIAN_DIR}/ai"
}

variable "VEGITO_DOCKER_DEBIAN_AI_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/debian-ai-version"
}

variable "VEGITO_DOCKER_DEBIAN_AI_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/debian-ai-latest"
}

variable "VEGITO_DOCKER_DEBIAN_AI_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION" {
  description = "local write cache for vegito-debian-ai version image build"
  default     = "type=local,mode=max,dest=${VEGITO_DOCKER_DEBIAN_AI_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_DOCKER_DEBIAN_AI_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST" {
  description = "local write cache for vegito-debian-ai latest image build"
  default     = "type=local,mode=max,dest=${VEGITO_DOCKER_DEBIAN_AI_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "VEGITO_DOCKER_DEBIAN_AI_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION" {
  description = "local read cache for vegito-debian-ai version image build (cannot be used before first write)"
  default     = "type=local,src=${VEGITO_DOCKER_DEBIAN_AI_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_DOCKER_DEBIAN_AI_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST" {
  description = "local read cache for vegito-debian-ai latest image build (cannot be used before first write)"
  default     = "type=local,src=${VEGITO_DOCKER_DEBIAN_AI_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "VEGITO_DOCKER_DEBIAN_AI_IMAGE_LATEST" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:debian-ai-latest"
}

variable "VEGITO_DOCKER_DEBIAN_AI_IMAGE_VERSION" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:debian-ai-${VERSION}"
}

group "vegito-debian-ai-ci" {
  description = "Build and push Android Emmulator images"
  targets = [
    "vegito-debian-ai-version-ci",
    "vegito-debian-ai-latest-ci",
  ]
}

target "vegito-debian-ai-version-ci" {
  context = VEGITO_DOCKER_DEBIAN_AI_DIR
  contexts = {
    debian = "target:vegito-debian-version-ci"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_AI_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_AI_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_AI_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION
    ] : [],
    [
      VEGITO_DOCKER_DEBIAN_AI_IMAGE_LATEST
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_AI_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION
    ] : []
  )
  platforms = platforms
}

target "vegito-debian-ai-latest-ci" {
  context = VEGITO_DOCKER_DEBIAN_AI_DIR
  contexts = {
    debian = "target:vegito-debian-latest-ci"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_AI_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_AI_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_AI_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      VEGITO_DOCKER_DEBIAN_AI_IMAGE_LATEST
    ]
  )
  cache-to = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_AI_IMAGE_REGISTRY_CACHE},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_AI_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : [],
    [
      "type=inline"
    ]
  )
  platforms = platforms
}

target "vegito-debian-ai" {

  context = VEGITO_DOCKER_DEBIAN_AI_DIR
  contexts = {
    debian = "target:vegito-debian-version-ci"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_AI_IMAGE_LATEST,
    VEGITO_DOCKER_DEBIAN_AI_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_AI_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_AI_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      VEGITO_DOCKER_DEBIAN_AI_IMAGE_LATEST,
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_AI_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : []
  )
}
