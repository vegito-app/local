variable "VEGITO_DOCKER_DEBIAN_VSCODE_VERSION" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:debian-vscode-${VERSION}"
}

variable "VEGITO_DOCKER_DEBIAN_VSCODE_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_CACHE_IMAGES_BASE}/vegito-debian-vscode"
}

variable "VEGITO_DOCKER_DEBIAN_VSCODE_DIR" {
  default = "${VEGITO_DOCKER_DEBIAN_DIR}/vscode"
}

variable "VEGITO_DOCKER_DEBIAN_VSCODE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/debian-vscode-version"
}

variable "VEGITO_DOCKER_DEBIAN_VSCODE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/debian-vscode-latest"
}

variable "VEGITO_DOCKER_DEBIAN_VSCODE_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION" {
  description = "local write cache for vegito-debian-vscode version image build"
  default     = "type=local,mode=max,dest=${VEGITO_DOCKER_DEBIAN_VSCODE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_DOCKER_DEBIAN_VSCODE_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST" {
  description = "local write cache for vegito-debian-vscode latest image build"
  default     = "type=local,mode=max,dest=${VEGITO_DOCKER_DEBIAN_VSCODE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "VEGITO_DOCKER_DEBIAN_VSCODE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION" {
  description = "local read cache for vegito-debian-vscode version image build (cannot be used before first write)"
  default     = "type=local,src=${VEGITO_DOCKER_DEBIAN_VSCODE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_DOCKER_DEBIAN_VSCODE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST" {
  description = "local read cache for vegito-debian-vscode latest image build (cannot be used before first write)"
  default     = "type=local,src=${VEGITO_DOCKER_DEBIAN_VSCODE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "VEGITO_DOCKER_DEBIAN_VSCODE_IMAGE_LATEST" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:debian-vscode-latest"
}

variable "VEGITO_DOCKER_DEBIAN_VSCODE_IMAGE_VERSION" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:debian-vscode-${VERSION}"
}

group "vegito-debian-vscode-ci" {
  description = "Build and push Debian VSCode images"
  targets = [
    "vegito-debian-vscode-version-ci",
    "vegito-debian-vscode-latest-ci",
  ]
}

target "vegito-debian-vscode-version-ci" {
  context = VEGITO_DOCKER_DEBIAN_VSCODE_DIR
  contexts = {
    debian = "target:vegito-debian-desktop-x-version-ci"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_VSCODE_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_VSCODE_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_VSCODE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION
    ] : [],
    [
      VEGITO_DOCKER_DEBIAN_VSCODE_IMAGE_LATEST
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_VSCODE_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION
    ] : []
  )
  platforms = platforms
}

target "vegito-debian-vscode-latest-ci" {
  context = VEGITO_DOCKER_DEBIAN_VSCODE_DIR
  contexts = {
    debian = "target:vegito-debian-desktop-x-latest-ci"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_VSCODE_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_VSCODE_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_VSCODE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      VEGITO_DOCKER_DEBIAN_VSCODE_IMAGE_LATEST
    ]
  )
  cache-to = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_VSCODE_IMAGE_REGISTRY_CACHE},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_VSCODE_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : [],
    [
      "type=inline"
    ]
  )
  platforms = platforms
}

target "vegito-debian-vscode" {

  context = VEGITO_DOCKER_DEBIAN_VSCODE_DIR
  contexts = {
    debian = "target:vegito-debian-desktop-x-version-ci"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_VSCODE_IMAGE_LATEST,
    VEGITO_DOCKER_DEBIAN_VSCODE_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_VSCODE_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_VSCODE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      VEGITO_DOCKER_DEBIAN_VSCODE_IMAGE_LATEST,
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_VSCODE_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : []
  )
}
