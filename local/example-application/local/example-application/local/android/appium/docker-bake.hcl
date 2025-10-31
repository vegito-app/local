variable "LOCAL_ANDROID_APPIUM_IMAGE_VERSION" {
  default = notequal("", VERSION) ? "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-appium-${VERSION}" : ""
}

variable "LOCAL_ANDROID_APPIUM_IMAGE_LATEST" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-appium-latest"
}

variable "LOCAL_ANDROID_APPIUM_REGISTRY_CACHE_IMAGE" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}/cache/android-appium"
}

variable "LOCAL_ANDROID_APPIUM_IMAGE_REGISTRY_CACHE_CI" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}/cache/android-appium/ci"
}

variable "LOCAL_ANDROID_APPIUM_DIR" {
  default = "${LOCAL_ANDROID_DIR}/appium"
}

variable "LOCAL_ANDROID_APPIUM_IMAGE_DOCKER_BUILDX_LOCAL_CACHE" {
  default = "${LOCAL_ANDROID_APPIUM_DIR}/.containers/android-appium/docker-buildx-cache"
}

variable "LOCAL_ANDROID_APPIUM_IMAGE_DOCKER_BUILDX_CACHE_WRITE" {
  description = "local write cache for local-android-appium image build"
  default = "type=local,mode=max,dest=${LOCAL_ANDROID_APPIUM_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "LOCAL_ANDROID_APPIUM_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  description = "local read cache for local-android-appium image build (cannot be used before first write)"
  default = "type=local,src=${LOCAL_ANDROID_APPIUM_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "LOCAL_ANDROID_APPIUM_IMAGE_LATEST" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-appium-latest"
}

target "local-android-appium-ci" {
  args = {
    android_apk_emulator_image   = LOCAL_ANDROID_APK_RUNNER_EMULATOR_IMAGE
  }
  context = LOCAL_ANDROID_APPIUM_DIR
  tags = [
    LOCAL_ANDROID_APPIUM_IMAGE_LATEST,
    LOCAL_ANDROID_APPIUM_IMAGE_VERSION,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_ANDROID_APPIUM_IMAGE_REGISTRY_CACHE_CI}" : "",
    "type=inline,ref=${LOCAL_ANDROID_APPIUM_IMAGE_LATEST}",
    LOCAL_ANDROID_APPIUM_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_ANDROID_APPIUM_IMAGE_REGISTRY_CACHE_CI},mode=max" : "type=inline"
  ]
  platforms = platforms
}

target "local-android-appium" {
  args = {
    android_apk_emulator_image   = LOCAL_ANDROID_APK_RUNNER_EMULATOR_IMAGE_LATEST
  }
  context = LOCAL_ANDROID_APPIUM_DIR
  tags = [
    LOCAL_ANDROID_APPIUM_IMAGE_LATEST,
    LOCAL_ANDROID_APPIUM_IMAGE_VERSION,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_ANDROID_APPIUM_REGISTRY_CACHE_IMAGE}" : "",
    LOCAL_ANDROID_APPIUM_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
    "type=inline,ref=${LOCAL_ANDROID_APPIUM_IMAGE_LATEST}",
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_ANDROID_APPIUM_REGISTRY_CACHE_IMAGE},mode=max" : LOCAL_ANDROID_APPIUM_IMAGE_DOCKER_BUILDX_CACHE_WRITE,
  ]
}
