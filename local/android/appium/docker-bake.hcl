variable "LOCAL_ANDROID_APPIUM_IMAGE_VERSION" {
  default = notequal("", VERSION) ? "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-appium-${VERSION}" : ""
}

variable "LOCAL_ANDROID_APPIUM_IMAGE_LATEST" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-appium-latest"
}

variable "LOCAL_ANDROID_APPIUM_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_LOCAL_CACHE_IMAGES_BASE}/android-appium"
}

variable "LOCAL_ANDROID_APPIUM_DIR" {
  default = "${LOCAL_ANDROID_DIR}/appium"
}

variable "LOCAL_ANDROID_APPIUM_IMAGE_DOCKER_BUILDX_LOCAL_CACHE" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/android-appium"
}

variable "LOCAL_ANDROID_APPIUM_IMAGE_DOCKER_BUILDX_CACHE_WRITE" {
  description = "local write cache for local-android-appium image build"
  default     = "type=local,mode=max,dest=${LOCAL_ANDROID_APPIUM_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "LOCAL_ANDROID_APPIUM_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  description = "local read cache for local-android-appium image build (cannot be used before first write)"
  default     = "type=local,src=${LOCAL_ANDROID_APPIUM_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "LOCAL_ANDROID_APPIUM_IMAGE_LATEST" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-appium-latest"
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
    [
      "type=inline,ref=${LOCAL_ANDROID_APPIUM_IMAGE_LATEST}",
      "type=inline,ref=${LOCAL_ANDROID_EMULATOR_IMAGE_LATEST}"
    ]
  )
  cache-to  = []
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
    [
      "type=inline,ref=${LOCAL_ANDROID_APPIUM_IMAGE_LATEST}",
      "type=inline,ref=${LOCAL_ANDROID_EMULATOR_IMAGE_LATEST}"
    ]
  )
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_ANDROID_APPIUM_IMAGE_REGISTRY_CACHE},mode=max" : "type=inline"
  ]
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
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ANDROID_APPIUM_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_ANDROID_APPIUM_IMAGE_REGISTRY_CACHE}",
      "type=registry,ref=${LOCAL_ANDROID_EMULATOR_IMAGE_REGISTRY_CACHE}"
    ] : [],
    [
      "type=inline,ref=${LOCAL_ANDROID_APPIUM_IMAGE_LATEST}",
      "type=inline,ref=${LOCAL_ANDROID_EMULATOR_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ANDROID_APPIUM_IMAGE_DOCKER_BUILDX_CACHE_WRITE
    ] : []
  )
}
