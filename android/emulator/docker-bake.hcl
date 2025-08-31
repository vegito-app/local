variable "LOCAL_ANDROID_APK_RUNNER_EMULATOR_VERSION" {
  default = notequal("", VERSION) ? "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:local-android-emulator-${VERSION}" : ""
}

variable "LOCAL_ANDROID_APK_RUNNER_EMULATOR_REGISTRY_CACHE_IMAGE" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}/cache/local-android-emulator"
}

variable "FLUTTER_VERSION" {
  default = "3.32.8"
}

variable "LOCAL_ANDROID_APK_RUNNER_EMULATOR_IMAGE_DOCKER_BUILDX_CACHE_WRITE" {
  description = "local write cache for local-android-emulator image build"
}

variable "LOCAL_ANDROID_APK_RUNNER_EMULATOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  description = "local read cache for local-android-emulator image build (cannot be used before first write)"
}

target "local-android-emulator-ci" {
  # args = {
  #   flutter_version        = FLUTTER_VERSION
  # }
  context = "${LOCAL_DIR}/android/emulator"
  tags = [
    LOCAL_ANDROID_APK_RUNNER_EMULATOR_IMAGE_LATEST,
    LOCAL_ANDROID_APK_RUNNER_EMULATOR_VERSION,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_ANDROID_APK_RUNNER_EMULATOR_REGISTRY_CACHE_IMAGE}" : "",
    "type=inline,ref=${LOCAL_ANDROID_APK_RUNNER_EMULATOR_IMAGE_LATEST}",
    LOCAL_ANDROID_APK_RUNNER_EMULATOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_ANDROID_APK_RUNNER_EMULATOR_REGISTRY_CACHE_IMAGE},mode=max" : "type=inline"
  ]
  platforms = platforms
}

target "local-android-emulator" {
  # args = {
  #   android_apk-runner-emulator_version = ANDROID_STUDIO_VERSION
  #   # android_ndk_version    = ANDROID_NDK_VERSION
  #   flutter_version        = FLUTTER_VERSION
  # }
  context = "${LOCAL_DIR}/android/emulator"
  tags = [
    LOCAL_ANDROID_APK_RUNNER_EMULATOR_IMAGE_LATEST,
    LOCAL_ANDROID_APK_RUNNER_EMULATOR_VERSION,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_ANDROID_APK_RUNNER_EMULATOR_REGISTRY_CACHE_IMAGE}" : "",
    LOCAL_ANDROID_APK_RUNNER_EMULATOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
    "type=inline,ref=${LOCAL_ANDROID_APK_RUNNER_EMULATOR_IMAGE_LATEST}",
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_ANDROID_APK_RUNNER_EMULATOR_REGISTRY_CACHE_IMAGE},mode=max" : LOCAL_ANDROID_APK_RUNNER_EMULATOR_IMAGE_DOCKER_BUILDX_CACHE_WRITE,
  ]
}
