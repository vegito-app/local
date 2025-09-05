variable "LOCAL_ANDROID_APK_BUILDER_VERSION" {
  default = notequal("", VERSION) ? "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-flutter-${VERSION}" : ""
}

variable "LOCAL_ANDROID_APK_BUILDER_IMAGE_LATEST" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-flutter-latest"
}

variable "LOCAL_ANDROID_APK_BUILDER_REGISTRY_CACHE_IMAGE" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}/cache/android-flutter"
}

variable "LOCAL_ANDROID_APK_BUILDER_REGISTRY_CACHE_IMAGE_CI" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}/cache/android-flutter/ci"
}

variable "LOCAL_ANDROID_STUDIO_VERSION" {
  default = notequal("",ANDROID_STUDIO_VERSION)?ANDROID_STUDIO_VERSION:"2025.1.1.9"
}

variable "LOCAL_ANDROID_NDK_VERSION" {
  default = notequal("",ANDROID_NDK_VERSION)?ANDROID_NDK_VERSION:"27.0.12077973"
}

variable "LOCAL_ANDROID_APK_BUILDER_IMAGE_DOCKER_BUILDX_CACHE_WRITE" {
  description = "local write cache for android-apppium image build"
}

variable "LOCAL_ANDROID_APK_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  description = "local read cache for android-apppium image build (cannot be used before first write)"
}

variable "LOCAL_ANDROID_APK_RUNNER_REGISTRY_CACHE_IMAGE" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}/cache/android-apk-runner"
}

variable "FLUTTER_VERSION" {
  default = "3.32.8"
}

target "local-android-flutter-ci" {
  args = {
    flutter_version        = FLUTTER_VERSION
    android_apk_emulator_image   = LOCAL_ANDROID_APK_RUNNER_EMULATOR_IMAGE_LATEST
  }
  context = "${LOCAL_DIR}/android"
  dockerfile = "flutter/Dockerfile"
  tags = [
    LOCAL_ANDROID_APK_BUILDER_IMAGE_LATEST,
    LOCAL_ANDROID_APK_BUILDER_VERSION,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_ANDROID_APK_BUILDER_REGISTRY_CACHE_IMAGE_CI}" : "",
    "type=inline,ref=${LOCAL_ANDROID_APK_BUILDER_IMAGE_LATEST}",
    LOCAL_ANDROID_APK_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_ANDROID_APK_BUILDER_REGISTRY_CACHE_IMAGE_CI},mode=max" : "type=inline"
  ]
  platforms = platforms
}

target "local-android-flutter" {
  args = {
    flutter_version        = FLUTTER_VERSION
    android_apk_emulator_image   = LOCAL_ANDROID_APK_RUNNER_EMULATOR_IMAGE_LATEST
  }
  context = "${LOCAL_DIR}/android"
  dockerfile = "flutter/Dockerfile"
  tags = [
    LOCAL_ANDROID_APK_BUILDER_IMAGE_LATEST,
    LOCAL_ANDROID_APK_BUILDER_VERSION,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_ANDROID_APK_BUILDER_REGISTRY_CACHE_IMAGE}" : "",
    LOCAL_ANDROID_APK_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
    "type=inline,ref=${LOCAL_ANDROID_APK_BUILDER_IMAGE_LATEST}",
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_ANDROID_APK_BUILDER_REGISTRY_CACHE_IMAGE},mode=max" : LOCAL_ANDROID_APK_BUILDER_IMAGE_DOCKER_BUILDX_CACHE_WRITE,
  ]
}
