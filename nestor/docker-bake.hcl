variable "LOCAL_NESTOR_VERSION" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME}:nestor-${VERSION}"
}

variable "LOCAL_NESTOR_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_LOCAL_CACHE_IMAGES_BASE}/local-nestor"
}

variable "LOCAL_NESTOR_DIR" {
  default = "${LOCAL_DIR}/nestor"
}

variable "LOCAL_NESTOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/nestor-version"
}

variable "LOCAL_NESTOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/nestor-latest"
}

variable "LOCAL_NESTOR_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION" {
  description = "local write cache for local-nestor version image build"
  default     = "type=local,mode=max,dest=${LOCAL_NESTOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "LOCAL_NESTOR_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST" {
  description = "local write cache for local-nestor latest image build"
  default     = "type=local,mode=max,dest=${LOCAL_NESTOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "LOCAL_NESTOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION" {
  description = "local read cache for local-nestor version image build (cannot be used before first write)"
  default     = "type=local,src=${LOCAL_NESTOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "LOCAL_NESTOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST" {
  description = "local read cache for local-nestor latest image build (cannot be used before first write)"
  default     = "type=local,src=${LOCAL_NESTOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "LOCAL_NESTOR_IMAGE_LATEST" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME}:nestor-latest"
}

variable "LOCAL_NESTOR_IMAGE_VERSION" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME}:nestor-${VERSION}"
}

group "local-nestor-ci" {
  description = "Build and push Nestor images"
  targets = [
    "local-nestor-version-ci",
    "local-nestor-latest-ci",
  ]
}

target "local-nestor-base" {
  context = LOCAL_NESTOR_DIR
  args = {
    debian_version = "trixie"
  }
}

target "local-nestor-version-ci" {
  inherits = ["local-nestor-base"]
  contexts = {
    debian = "docker-image://${VEGITO_DOCKER_TRIXIE_DEBIAN_VSCODE_GOLANG_AI_DOCKER_DESKTOP_X_IMAGE_VERSION}"
  }
  tags = [
    LOCAL_NESTOR_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_NESTOR_IMAGE_REGISTRY_CACHE}",
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_NESTOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION
    ] : [],
    [
      VEGITO_DOCKER_TRIXIE_DEBIAN_VSCODE_GOLANG_AI_DOCKER_DESKTOP_X_IMAGE_VERSION
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_NESTOR_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION
    ] : []
  )
  platforms = platforms
}

target "local-nestor-latest-ci" {
  inherits = ["local-nestor-base"]
  contexts = {
    debian = "docker-image://${VEGITO_DOCKER_TRIXIE_DEBIAN_VSCODE_GOLANG_AI_DOCKER_DESKTOP_X_IMAGE_VERSION}"
  }
  tags = [
    LOCAL_NESTOR_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_NESTOR_IMAGE_REGISTRY_CACHE}",
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_NESTOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      LOCAL_NESTOR_IMAGE_LATEST,
      VEGITO_DOCKER_TRIXIE_DEBIAN_VSCODE_GOLANG_AI_DOCKER_DESKTOP_X_IMAGE_VERSION
    ]
  )
  cache-to = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_NESTOR_IMAGE_REGISTRY_CACHE},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_NESTOR_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : [],
    [
      "type=inline"
    ]
  )
  platforms = platforms
}

target "local-nestor" {

  inherits = ["local-nestor-base"]
  contexts = {
    debian = "docker-image://${VEGITO_DOCKER_TRIXIE_DEBIAN_VSCODE_GOLANG_AI_DOCKER_DESKTOP_X_IMAGE_VERSION}"
  }
  tags = [
    LOCAL_NESTOR_IMAGE_LATEST,
    LOCAL_NESTOR_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_NESTOR_IMAGE_REGISTRY_CACHE}",
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_NESTOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      LOCAL_NESTOR_IMAGE_LATEST,
      VEGITO_DOCKER_TRIXIE_DEBIAN_VSCODE_GOLANG_AI_DOCKER_DESKTOP_X_IMAGE_VERSION
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_NESTOR_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : []
  )
}
