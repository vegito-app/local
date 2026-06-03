variable "VEGITO_PUBLIC_REPOSITORY" {
  default = "vegito-docker-repository-public"
}

variable "VEGITO_NESTOR_PUBLIC_IMAGES_BASE_NAME" {
  default = "${VEGITO_PUBLIC_REPOSITORY}/vegito-nestor-public"
}

variable "VEGITO_NESTOR_PRIVATE_IMAGES_BASE_NAME" {
  default = "${VEGITO_PUBLIC_REPOSITORY}/vegito-nestor-private"
}

variable "VEGITO_NESTOR_DIR" {
  default = "."
}

variable "VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR" {
  default = "${VEGITO_NESTOR_DIR}/.containers/buildx-cache"
}

variable "VEGITO_NESTOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/nestor-version"
}

variable "VEGITO_NESTOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/nestor-latest"
}

variable "VERSION" {
  description = "current git tag or commit version"
  default     = "dev"
}

variable "platforms" {
  default = [
    "linux/amd64",
    "linux/arm64",
  ]
}

variable "USE_REGISTRY_CACHE" {
  default = false
  type    = bool
}

variable "ENABLE_LOCAL_CACHE" {
  default = false
  type    = bool
}

variable "VEGITO_CACHE_REPOSITORY" {
  default = "vegito-docker-repository-cache"
}

variable "VEGITO_NESTOR_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION" {
  description = "local write cache for vegito-nestor version image build"
  default     = "type=local,mode=max,dest=${VEGITO_NESTOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_NESTOR_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST" {
  description = "local write cache for vegito-nestor latest image build"
  default     = "type=local,mode=max,dest=${VEGITO_NESTOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "VEGITO_NESTOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION" {
  description = "local read cache for vegito-nestor version image build (cannot be used before first write)"
  default     = "type=local,src=${VEGITO_NESTOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_NESTOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST" {
  description = "local read cache for vegito-nestor latest image build (cannot be used before first write)"
  default     = "type=local,src=${VEGITO_NESTOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "VEGITO_NESTOR_CACHE_IMAGES_BASE" {
  default = "${VEGITO_CACHE_REPOSITORY}/vegito-nestor"
}

variable "VEGITO_NESTOR_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_NESTOR_CACHE_IMAGES_BASE}/nestor"
}


variable "VEGITO_NESTOR_IMAGE_LATEST" {
  default = "${VEGITO_NESTOR_PUBLIC_IMAGES_BASE_NAME}:nestor-latest"
}

variable "VEGITO_NESTOR_IMAGE_VERSION" {
  default = "${VEGITO_NESTOR_PUBLIC_IMAGES_BASE_NAME}:nestor-${VERSION}"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_VSCODE_GOLANG_AI_DOCKER_DESKTOP_X_IMAGE_LATEST" {
  default = "${VEGITO_PUBLIC_REPOSITORY}/vegito-public:trixie-debian-vscode-golang-ai-docker-desktop-x-latest"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_VSCODE_GOLANG_AI_DOCKER_DESKTOP_X_IMAGE_VERSION" {
  default = "${VEGITO_PUBLIC_REPOSITORY}/vegito-public:trixie-debian-vscode-golang-ai-docker-desktop-x-${VERSION}"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_IMAGE_VERSION" {
  default = "${VEGITO_PUBLIC_REPOSITORY}/vegito-public:trixie-debian-golang-${VERSION}"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_IMAGE_LATEST" {
  default = "${VEGITO_PUBLIC_REPOSITORY}/vegito-public:trixie-debian-golang-latest"
}

group "vegito-nestor-ci" {
  description = "Build and push Nestor images"
  targets = [
    "vegito-nestor-version-ci",
    "vegito-nestor-latest-ci",
  ]
}

target "vegito-nestor-base" {
  context = VEGITO_NESTOR_DIR
  args = {
    debian_version = "trixie"
  }
}

target "vegito-nestor-version-ci" {
  inherits = ["vegito-nestor-base"]
  contexts = {
    debian = "docker-image://${VEGITO_DOCKER_TRIXIE_DEBIAN_VSCODE_GOLANG_AI_DOCKER_DESKTOP_X_IMAGE_VERSION}"
    debian-golang = "docker-image://${VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_IMAGE_VERSION}"
  }
  tags = [
    VEGITO_NESTOR_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_NESTOR_IMAGE_REGISTRY_CACHE}",
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_NESTOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION
    ] : [],
    [
      VEGITO_DOCKER_TRIXIE_DEBIAN_VSCODE_GOLANG_AI_DOCKER_DESKTOP_X_IMAGE_VERSION
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_NESTOR_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION
    ] : []
  )
  platforms = platforms
}

target "vegito-nestor-latest-ci" {
  inherits = ["vegito-nestor-base"]
  contexts = {
    debian = "docker-image://${VEGITO_DOCKER_TRIXIE_DEBIAN_VSCODE_GOLANG_AI_DOCKER_DESKTOP_X_IMAGE_LATEST}"
    debian-golang = "docker-image://${VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_IMAGE_LATEST}"
  }
  tags = [
    VEGITO_NESTOR_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_NESTOR_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_NESTOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      VEGITO_NESTOR_IMAGE_LATEST,
      VEGITO_DOCKER_TRIXIE_DEBIAN_VSCODE_GOLANG_AI_DOCKER_DESKTOP_X_IMAGE_VERSION
    ]
  )
  cache-to = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_NESTOR_IMAGE_REGISTRY_CACHE},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_NESTOR_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : [],
    [
      "type=inline"
    ]
  )
  platforms = platforms
}

target "vegito-nestor" {

  inherits = ["vegito-nestor-base"]
  contexts = {
    debian = "docker-image://${VEGITO_DOCKER_TRIXIE_DEBIAN_VSCODE_GOLANG_AI_DOCKER_DESKTOP_X_IMAGE_VERSION}"
    debian-golang = "docker-image://${VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_IMAGE_VERSION}"
  }
  tags = [
    VEGITO_NESTOR_IMAGE_LATEST,
    VEGITO_NESTOR_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_NESTOR_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_NESTOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      VEGITO_NESTOR_IMAGE_LATEST,
      VEGITO_DOCKER_TRIXIE_DEBIAN_VSCODE_GOLANG_AI_DOCKER_DESKTOP_X_IMAGE_VERSION
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_NESTOR_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : []
  )
}
