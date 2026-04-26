variable "LOCAL_ANDROID_EMULATOR_VERSION" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME}:android-emulator-${VERSION}"
}

variable "LOCAL_ANDROID_EMULATOR_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_LOCAL_CACHE_IMAGES_BASE}/local-android-emulator"
}

variable "LOCAL_ANDROID_EMULATOR_DIR" {
  default = "${LOCAL_ANDROID_DIR}/emulator"
}

variable "LOCAL_ANDROID_EMULATOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/android-emulator-version"
}

variable "LOCAL_ANDROID_EMULATOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/android-emulator-latest"
}

variable "LOCAL_ANDROID_EMULATOR_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION" {
  description = "local write cache for local-android-emulator version image build"
  default     = "type=local,mode=max,dest=${LOCAL_ANDROID_EMULATOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "LOCAL_ANDROID_EMULATOR_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST" {
  description = "local write cache for local-android-emulator latest image build"
  default     = "type=local,mode=max,dest=${LOCAL_ANDROID_EMULATOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "LOCAL_ANDROID_EMULATOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION" {
  description = "local read cache for local-android-emulator version image build (cannot be used before first write)"
  default     = "type=local,src=${LOCAL_ANDROID_EMULATOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "LOCAL_ANDROID_EMULATOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST" {
  description = "local read cache for local-android-emulator latest image build (cannot be used before first write)"
  default     = "type=local,src=${LOCAL_ANDROID_EMULATOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "LOCAL_ANDROID_EMULATOR_IMAGE_LATEST" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME}:android-emulator-latest"
}

variable "LOCAL_ANDROID_EMULATOR_IMAGE_VERSION" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME}:android-emulator-${VERSION}"
}

group "local-android-emulator-ci" {
  description = "Build and push Android Emmulator images"
  targets = [
    "local-android-emulator-version-ci",
    "local-android-emulator-latest-ci",
  ]
}

target "local-android-emulator-version-ci" {
  context = LOCAL_ANDROID_EMULATOR_DIR
  contexts = {
    debian_image = "docker-image://${LOCAL_DEBIAN_IMAGE_VERSION}"
  }
  tags = [
    LOCAL_ANDROID_EMULATOR_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_ANDROID_EMULATOR_IMAGE_REGISTRY_CACHE}",
      "type=registry,ref=${LOCAL_DEBIAN_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ANDROID_EMULATOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION
    ] : [],
    [
      "type=inline,ref=${LOCAL_DEBIAN_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ANDROID_EMULATOR_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION
    ] : []
  )
  platforms = platforms
}

target "local-android-emulator-latest-ci" {
  context = LOCAL_ANDROID_EMULATOR_DIR
  contexts = {
    debian_image = "docker-image://${LOCAL_DEBIAN_IMAGE_LATEST}"
  }
  tags = [
    LOCAL_ANDROID_EMULATOR_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_ANDROID_EMULATOR_IMAGE_REGISTRY_CACHE}",
      "type=registry,ref=${LOCAL_DEBIAN_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ANDROID_EMULATOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      "type=inline,ref=${LOCAL_ANDROID_EMULATOR_IMAGE_LATEST}",
      "type=inline,ref=${LOCAL_DEBIAN_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_ANDROID_EMULATOR_IMAGE_REGISTRY_CACHE},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ANDROID_EMULATOR_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : [],
    [
      "type=inline"
    ]
  )
  platforms = platforms
}

target "local-android-emulator" {

  context = LOCAL_ANDROID_EMULATOR_DIR
  contexts = {
    debian_image = "docker-image://${LOCAL_DEBIAN_IMAGE_VERSION}"
  }
  tags = [
    LOCAL_ANDROID_EMULATOR_IMAGE_LATEST,
    LOCAL_ANDROID_EMULATOR_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_ANDROID_EMULATOR_IMAGE_REGISTRY_CACHE}",
      "type=registry,ref=${LOCAL_DEBIAN_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ANDROID_EMULATOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      "type=inline,ref=${LOCAL_ANDROID_EMULATOR_IMAGE_LATEST}",
      "type=inline,ref=${LOCAL_DEBIAN_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ANDROID_EMULATOR_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : []
  )
}
