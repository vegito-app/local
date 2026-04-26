variable "LOCAL_ANDROID_APPIUM_IMAGE_VERSION" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME}:android-appium-${VERSION}"
}

variable "LOCAL_ANDROID_APPIUM_IMAGE_LATEST" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME}:android-appium-latest"
}

variable "LOCAL_ANDROID_APPIUM_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_LOCAL_CACHE_IMAGES_BASE}/android-appium"
}

variable "LOCAL_ANDROID_APPIUM_DIR" {
  default = "${LOCAL_ANDROID_DIR}/appium"
}

variable "LOCAL_ANDROID_APPIUM_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/android-appium-version"
}

variable "LOCAL_ANDROID_APPIUM_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/android-appium-latest"
}

variable "LOCAL_ANDROID_APPIUM_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION" {
  description = "local write cache for local-android-appium version image build"
  default     = "type=local,mode=max,dest=${LOCAL_ANDROID_APPIUM_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "LOCAL_ANDROID_APPIUM_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST" {
  description = "local write cache for local-android-appium latest image build"
  default     = "type=local,mode=max,dest=${LOCAL_ANDROID_APPIUM_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "LOCAL_ANDROID_APPIUM_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION" {
  description = "local read cache for local-android-appium version image build (cannot be used before first write)"
  default     = "type=local,src=${LOCAL_ANDROID_APPIUM_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "LOCAL_ANDROID_APPIUM_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST" {
  description = "local read cache for local-android-appium latest image build (cannot be used before first write)"
  default     = "type=local,src=${LOCAL_ANDROID_APPIUM_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "LOCAL_ANDROID_APPIUM_IMAGE_LATEST" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME}:android-appium-latest"
}

group "local-android-appium-ci" {
  targets = [
    "local-android-appium-version-ci",
    "local-android-appium-latest-ci"
  ]
}

target "local-android-appium-version-ci" {
  contexts = {
    builder_image = "target:local-android-emulator-latest-ci"
  }
  context = LOCAL_ANDROID_APPIUM_DIR
  tags = [
    LOCAL_ANDROID_APPIUM_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_ANDROID_APPIUM_IMAGE_REGISTRY_CACHE}",
      "type=registry,ref=${LOCAL_ANDROID_EMULATOR_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ANDROID_APPIUM_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION
    ] : [],
    [
      "type=inline,ref=${LOCAL_ANDROID_APPIUM_IMAGE_LATEST}",
      "type=inline,ref=${LOCAL_ANDROID_EMULATOR_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ANDROID_APPIUM_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION
    ] : []
  )
  platforms = platforms
}

target "local-android-appium-latest-ci" {
  contexts = {
    builder_image = "target:local-android-emulator-latest-ci"
  }
  context = LOCAL_ANDROID_APPIUM_DIR
  tags = [
    LOCAL_ANDROID_APPIUM_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_ANDROID_APPIUM_IMAGE_REGISTRY_CACHE}",
      "type=registry,ref=${LOCAL_ANDROID_EMULATOR_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ANDROID_APPIUM_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      "type=inline,ref=${LOCAL_ANDROID_APPIUM_IMAGE_LATEST}",
      "type=inline,ref=${LOCAL_ANDROID_EMULATOR_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_ANDROID_APPIUM_IMAGE_REGISTRY_CACHE},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ANDROID_APPIUM_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : [],
    [
      "type=inline"
    ]
  )
  platforms = platforms
}

target "local-android-appium" {
  contexts = {
    builder_image = "target:local-android-emulator"
  }
  context = LOCAL_ANDROID_APPIUM_DIR
  tags = [
    LOCAL_ANDROID_APPIUM_IMAGE_LATEST,
    LOCAL_ANDROID_APPIUM_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_ANDROID_APPIUM_IMAGE_REGISTRY_CACHE}",
      "type=registry,ref=${LOCAL_ANDROID_EMULATOR_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ANDROID_APPIUM_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      "type=inline,ref=${LOCAL_ANDROID_APPIUM_IMAGE_LATEST}",
      "type=inline,ref=${LOCAL_ANDROID_EMULATOR_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ANDROID_APPIUM_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : []
  )
}
