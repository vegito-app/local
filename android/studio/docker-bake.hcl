variable "LOCAL_ANDROID_STUDIO_DIR" {
  default = "android/studio"
}

variable "LOCAL_ANDROID_STUDIO_VERSION" {
  default = notequal("", VERSION) ? "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-studio-${VERSION}" : ""
}

variable "LOCAL_ANDROID_STUDIO_IMAGE_LATEST" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-studio-latest"
}

variable "LOCAL_ANDROID_STUDIO_REGISTRY_CACHE_IMAGE" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}/cache/android-studio"
}

variable "LOCAL_ANDROID_STUDIO_IMAGE_REGISTRY_CACHE_CI" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}/cache/android-studio/ci"
}

variable "ANDROID_STUDIO_VERSION" {
  default = "2025.1.1.9"
}

variable "ANDROID_NDK_VERSION" {
  default = "27.0.12077973"
}

variable "FLUTTER_VERSION" {
  default = "3.32.8"
}

variable "LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_CACHE_WRITE" {
  description = "local write cache for android-studio image build"
}

variable "LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  description = "local read cache for android-studio image build (cannot be used before first write)"
}

target "local-android-studio-ci" {
  args = {
    android_studio_version = ANDROID_STUDIO_VERSION
    android_apk_builder_image = LOCAL_ANDROID_APK_BUILDER_IMAGE_LATEST
  }
  context = LOCAL_ANDROID_STUDIO_DIR
  contexts = {
    "appium": "${LOCAL_DIR}/android/appium",
  }
  tags = [
    LOCAL_ANDROID_STUDIO_IMAGE_LATEST,
    LOCAL_ANDROID_STUDIO_VERSION,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_ANDROID_STUDIO_IMAGE_REGISTRY_CACHE_CI}" : "",
    "type=inline,ref=${LOCAL_ANDROID_STUDIO_IMAGE_LATEST}",
    LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_ANDROID_STUDIO_IMAGE_REGISTRY_CACHE_CI},mode=max" : "type=inline"
  ]
  platforms = platforms
}

target "local-android-studio" {
  args = {
    android_studio_version = ANDROID_STUDIO_VERSION
    android_apk_builder_image = LOCAL_ANDROID_APK_BUILDER_IMAGE_LATEST
  }
  context = LOCAL_ANDROID_STUDIO_DIR
  contexts = {
    "appium": "${LOCAL_DIR}/android/appium",
  }
  tags = [
    LOCAL_ANDROID_STUDIO_IMAGE_LATEST,
    LOCAL_ANDROID_STUDIO_VERSION,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_ANDROID_STUDIO_REGISTRY_CACHE_IMAGE}" : "",
    LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
    "type=inline,ref=${LOCAL_ANDROID_STUDIO_IMAGE_LATEST}",
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_ANDROID_STUDIO_REGISTRY_CACHE_IMAGE},mode=max" : LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_CACHE_WRITE,
  ]
}
