variable "VEGITO_DOCKER_DEBIAN_DESKTOP_X_VERSION" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:debian-desktop-x-${VERSION}"
}

variable "VEGITO_DOCKER_DEBIAN_DESKTOP_X_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_CACHE_IMAGES_BASE}/vegito-debian-desktop-x"
}

variable "VEGITO_DOCKER_DEBIAN_DESKTOP_X_DIR" {
  default = "${VEGITO_DOCKER_DEBIAN_DIR}/desktop-x"
}

variable "VEGITO_DOCKER_DEBIAN_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/debian-desktop-x-version"
}

variable "VEGITO_DOCKER_DEBIAN_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/debian-desktop-x-latest"
}

variable "VEGITO_DOCKER_DEBIAN_DESKTOP_X_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION" {
  description = "local write cache for vegito-debian-desktop-x version image build"
  default     = "type=local,mode=max,dest=${VEGITO_DOCKER_DEBIAN_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_DOCKER_DEBIAN_DESKTOP_X_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST" {
  description = "local write cache for vegito-debian-desktop-x latest image build"
  default     = "type=local,mode=max,dest=${VEGITO_DOCKER_DEBIAN_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "VEGITO_DOCKER_DEBIAN_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION" {
  description = "local read cache for vegito-debian-desktop-x version image build (cannot be used before first write)"
  default     = "type=local,src=${VEGITO_DOCKER_DEBIAN_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_DOCKER_DEBIAN_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST" {
  description = "local read cache for vegito-debian-desktop-x latest image build (cannot be used before first write)"
  default     = "type=local,src=${VEGITO_DOCKER_DEBIAN_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "VEGITO_DOCKER_DEBIAN_DESKTOP_X_IMAGE_LATEST" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:debian-desktop-x-latest"
}

variable "VEGITO_DOCKER_DEBIAN_DESKTOP_X_IMAGE_VERSION" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:debian-desktop-x-${VERSION}"
}

group "vegito-debian-desktop-x-ci" {
  description = "Build and push Android Emmulator images"
  targets = [
    "vegito-debian-desktop-x-version-ci",
    "vegito-debian-desktop-x-latest-ci",
  ]
}

target "vegito-debian-desktop-x-version-ci" {
  context = VEGITO_DOCKER_DEBIAN_DESKTOP_X_DIR
  contexts = {
    debian = "target:vegito-debian-version-ci"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_DESKTOP_X_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_DESKTOP_X_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION
    ] : [],
    [
      "type=inline,ref=${VEGITO_DOCKER_DEBIAN_DESKTOP_X_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_DESKTOP_X_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION
    ] : []
  )
  platforms = platforms
}

target "vegito-debian-desktop-x-latest-ci" {
  context = VEGITO_DOCKER_DEBIAN_DESKTOP_X_DIR
  contexts = {
    debian = "target:vegito-debian-latest-ci"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_DESKTOP_X_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_DESKTOP_X_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      "type=inline,ref=${VEGITO_DOCKER_DEBIAN_DESKTOP_X_IMAGE_LATEST}",
    ]
  )
  cache-to = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_DESKTOP_X_IMAGE_REGISTRY_CACHE},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_DESKTOP_X_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : [],
    [
      "type=inline"
    ]
  )
  platforms = platforms
}

target "vegito-debian-desktop-x" {

  context = VEGITO_DOCKER_DEBIAN_DESKTOP_X_DIR
  contexts = {
    debian = "target:vegito-debian-version-ci"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_DESKTOP_X_IMAGE_LATEST,
    VEGITO_DOCKER_DEBIAN_DESKTOP_X_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_DESKTOP_X_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      "type=inline,ref=${VEGITO_DOCKER_DEBIAN_DESKTOP_X_IMAGE_LATEST}",
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_DESKTOP_X_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : []
  )
}
