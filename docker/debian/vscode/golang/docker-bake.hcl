variable "VEGITO_DOCKER_DEBIAN_VSCODE_AI_DOCKER_DESKTOP_X_VERSION" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:debian-vscode-golang-ai-docker-desktop-x-${VERSION}"
}

variable "VEGITO_DOCKER_DEBIAN_VSCODE_AI_DOCKER_DESKTOP_X_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_CACHE_IMAGES_BASE}/vegito-debian-vscode-golang-ai-docker-desktop-x"
}

variable "VEGITO_DOCKER_DEBIAN_VSCODE_AI_DOCKER_DESKTOP_X_DIR" {
  default = "${VEGITO_DOCKER_DEBIAN_DIR}/vscode"
}

variable "VEGITO_DOCKER_DEBIAN_VSCODE_AI_DOCKER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/debian-vscode-golang-ai-docker-desktop-x-version"
}

variable "VEGITO_DOCKER_DEBIAN_VSCODE_AI_DOCKER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/debian-vscode-golang-ai-docker-desktop-x-latest"
}

variable "VEGITO_DOCKER_DEBIAN_VSCODE_AI_DOCKER_DESKTOP_X_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION" {
  description = "local write cache for vegito-debian-vscode-golang-ai-docker-desktop-x version image build"
  default     = "type=local,mode=max,dest=${VEGITO_DOCKER_DEBIAN_VSCODE_AI_DOCKER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_DOCKER_DEBIAN_VSCODE_AI_DOCKER_DESKTOP_X_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST" {
  description = "local write cache for vegito-debian-vscode-golang-ai-docker-desktop-x latest image build"
  default     = "type=local,mode=max,dest=${VEGITO_DOCKER_DEBIAN_VSCODE_AI_DOCKER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "VEGITO_DOCKER_DEBIAN_VSCODE_AI_DOCKER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION" {
  description = "local read cache for vegito-debian-vscode-golang-ai-docker-desktop-x version image build (cannot be used before first write)"
  default     = "type=local,src=${VEGITO_DOCKER_DEBIAN_VSCODE_AI_DOCKER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_DOCKER_DEBIAN_VSCODE_AI_DOCKER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST" {
  description = "local read cache for vegito-debian-vscode-golang-ai-docker-desktop-x latest image build (cannot be used before first write)"
  default     = "type=local,src=${VEGITO_DOCKER_DEBIAN_VSCODE_AI_DOCKER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "VEGITO_DOCKER_DEBIAN_VSCODE_AI_DOCKER_DESKTOP_X_IMAGE_LATEST" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:debian-vscode-golang-ai-docker-desktop-x-latest"
}

variable "VEGITO_DOCKER_DEBIAN_VSCODE_AI_DOCKER_DESKTOP_X_IMAGE_VERSION" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:debian-vscode-golang-ai-docker-desktop-x-${VERSION}"
}

group "vegito-debian-vscode-golang-ai-docker-desktop-x-ci" {
  description = "Build and push Debian VSCode images"
  targets = [
    "vegito-debian-vscode-golang-ai-docker-desktop-x-version-ci",
    "vegito-debian-vscode-golang-ai-docker-desktop-x-latest-ci",
  ]
}

target "vegito-debian-vscode-golang-ai-docker-desktop-x-version-ci" {
  context = VEGITO_DOCKER_DEBIAN_VSCODE_DIR
  contexts = {
    debian = "target:vegito-debian-golang-ai-docker-desktop-x-version-ci"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_VSCODE_AI_DOCKER_DESKTOP_X_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_VSCODE_AI_DOCKER_DESKTOP_X_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_VSCODE_AI_DOCKER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION
    ] : [],
    [
      VEGITO_DOCKER_DEBIAN_VSCODE_AI_DOCKER_DESKTOP_X_IMAGE_LATEST
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_VSCODE_AI_DOCKER_DESKTOP_X_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION
    ] : []
  )
  platforms = platforms
}

target "vegito-debian-vscode-golang-ai-docker-desktop-x-latest-ci" {
  context = VEGITO_DOCKER_DEBIAN_VSCODE_DIR
  contexts = {
    debian = "target:vegito-debian-golang-ai-docker-desktop-x-latest-ci"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_VSCODE_AI_DOCKER_DESKTOP_X_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_VSCODE_AI_DOCKER_DESKTOP_X_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_VSCODE_AI_DOCKER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      VEGITO_DOCKER_DEBIAN_VSCODE_AI_DOCKER_DESKTOP_X_IMAGE_LATEST
    ]
  )
  cache-to = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_VSCODE_AI_DOCKER_DESKTOP_X_IMAGE_REGISTRY_CACHE},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_VSCODE_AI_DOCKER_DESKTOP_X_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : [],
    [
      "type=inline"
    ]
  )
  platforms = platforms
}

target "vegito-debian-vscode-golang-ai-docker-desktop-x" {

  context = VEGITO_DOCKER_DEBIAN_VSCODE_DIR
  contexts = {
    debian = "target:vegito-debian-golang-ai-docker-desktop-x-version-ci"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_VSCODE_AI_DOCKER_DESKTOP_X_IMAGE_LATEST,
    VEGITO_DOCKER_DEBIAN_VSCODE_AI_DOCKER_DESKTOP_X_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_VSCODE_AI_DOCKER_DESKTOP_X_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_VSCODE_AI_DOCKER_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      VEGITO_DOCKER_DEBIAN_VSCODE_AI_DOCKER_DESKTOP_X_IMAGE_LATEST,
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_VSCODE_AI_DOCKER_DESKTOP_X_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : []
  )
}
