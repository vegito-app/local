variable "VEGITO_DOCKER_TRIXIE_DEBIAN_VSCODE_VERSION" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:trixie-debian-vscode-${VERSION}"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_VSCODE_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_CACHE_IMAGES_BASE}/vegito-trixie-debian-vscode"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_VSCODE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/trixie-debian-vscode-version"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_VSCODE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/trixie-debian-vscode-latest"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_VSCODE_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION" {
  description = "local write cache for vegito-trixie-debian-vscode version image build"
  default     = "type=local,mode=max,dest=${VEGITO_DOCKER_TRIXIE_DEBIAN_VSCODE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_VSCODE_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST" {
  description = "local write cache for vegito-trixie-debian-vscode latest image build"
  default     = "type=local,mode=max,dest=${VEGITO_DOCKER_TRIXIE_DEBIAN_VSCODE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_VSCODE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION" {
  description = "local read cache for vegito-trixie-debian-vscode version image build (cannot be used before first write)"
  default     = "type=local,src=${VEGITO_DOCKER_TRIXIE_DEBIAN_VSCODE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_VSCODE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST" {
  description = "local read cache for vegito-trixie-debian-vscode latest image build (cannot be used before first write)"
  default     = "type=local,src=${VEGITO_DOCKER_TRIXIE_DEBIAN_VSCODE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_VSCODE_IMAGE_LATEST" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:trixie-debian-vscode-latest"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_VSCODE_IMAGE_VERSION" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:trixie-debian-vscode-${VERSION}"
}

group "vegito-trixie-debian-vscode-ci" {
  description = "Build and push Android Emmulator images"
  targets = [
    "vegito-trixie-debian-vscode-version-ci",
    "vegito-trixie-debian-vscode-latest-ci",
  ]
}

target "vegito-trixie-debian-vscode-base" {
  context = VEGITO_DOCKER_DEBIAN_VSCODE_DIR
  args = {
    debian_version = "trixie"
  }
}

target "vegito-trixie-debian-vscode-version-ci" {
  inherits = ["vegito-trixie-debian-vscode-base"]
  contexts = {
    debian = "target:vegito-trixie-debian-desktop-x-version-ci"
  }
  tags = [
    VEGITO_DOCKER_TRIXIE_DEBIAN_VSCODE_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_VSCODE_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_VSCODE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION
    ] : [],
    [
      VEGITO_DOCKER_TRIXIE_DEBIAN_VSCODE_IMAGE_LATEST
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_VSCODE_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION
    ] : []
  )
  platforms = platforms
}

target "vegito-trixie-debian-vscode-latest-ci" {
  inherits = ["vegito-trixie-debian-vscode-base"]
  contexts = {
    debian = "target:vegito-trixie-debian-desktop-x-latest-ci"
  }
  tags = [
    VEGITO_DOCKER_TRIXIE_DEBIAN_VSCODE_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_VSCODE_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_VSCODE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      VEGITO_DOCKER_TRIXIE_DEBIAN_VSCODE_IMAGE_LATEST,
    ]
  )
  cache-to = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_VSCODE_IMAGE_REGISTRY_CACHE},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_VSCODE_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : [],
    [
      "type=inline"
    ]
  )
  platforms = platforms
}

target "vegito-trixie-debian-vscode" {

  inherits = ["vegito-trixie-debian-vscode-base"]
  contexts = {
    debian = "target:vegito-trixie-debian-desktop-x-version-ci"
  }
  tags = [
    VEGITO_DOCKER_TRIXIE_DEBIAN_VSCODE_IMAGE_LATEST,
    VEGITO_DOCKER_TRIXIE_DEBIAN_VSCODE_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_VSCODE_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_VSCODE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      VEGITO_DOCKER_TRIXIE_DEBIAN_VSCODE_IMAGE_LATEST,
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_VSCODE_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : []
  )
}
