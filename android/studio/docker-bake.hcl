variable "LOCAL_ANDROID_STUDIO_DIR" {
  default = "android/studio"
}

variable "LOCAL_ANDROID_STUDIO_VERSION" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME}:android-studio-${VERSION}"
}

variable "LOCAL_ANDROID_STUDIO_IMAGE_LATEST" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME}:android-studio-latest"
}

variable "LOCAL_ANDROID_STUDIO_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_LOCAL_CACHE_IMAGES_BASE}/android-studio"
}

variable "LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/android-studio-version"
}

variable "LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/android-studio-latest"
}

variable "LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION" {
  description = "local write cache for local-android-studio image build version"
  default     = "type=local,mode=max,dest=${LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST" {
  description = "local write cache for local-android-studio image build latest"
  default     = "type=local,mode=max,dest=${LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION" {
  description = "local read cache for local-android-studio image build version (cannot be used before first write)"
  default     = "type=local,src=${LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST" {
  description = "local read cache for local-android-studio image build latest (cannot be used before first write)"
  default     = "type=local,src=${LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "ANDROID_STUDIO_VERSION" {
  # default = "2025.3.4.6/android-studio-panda4"
  default = "2026.1.1.9/android-studio-quail1-patch1"
}

variable "ANDROID_NDK_VERSION" {
  default = "27.0.12077973"
}

group "local-android-studio-ci" {
  description = "Build and push Android Studio images"
  targets = [
    "local-android-studio-version-ci",
    "local-android-studio-latest-ci",
  ]
}

target "local-android-studio-version-ci" {
  args = {
    android_ndk_version    = ANDROID_NDK_VERSION
    android_studio_version = ANDROID_STUDIO_VERSION
  }
  context = LOCAL_ANDROID_STUDIO_DIR
  contexts = {
    android = "target:local-android-appium-flutter-version-ci"
  }
  tags = [
    LOCAL_ANDROID_STUDIO_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_ANDROID_STUDIO_IMAGE_REGISTRY_CACHE}",
      "type=registry,ref=${LOCAL_ANDROID_FLUTTER_IMAGE_REGISTRY_CACHE}",
      "type=registry,ref=${LOCAL_ANDROID_EMULATOR_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION
    ] : [],
    [
      LOCAL_ANDROID_STUDIO_IMAGE_LATEST,
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION
    ] : []
  )
  platforms = platforms
}

target "local-android-studio-latest-ci" {
  args = {
    android_ndk_version    = ANDROID_NDK_VERSION
    android_studio_version = ANDROID_STUDIO_VERSION
  }
  context = LOCAL_ANDROID_STUDIO_DIR
  contexts = {
    android = "target:local-android-appium-flutter-latest-ci"
  }
  tags = [
    LOCAL_ANDROID_STUDIO_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_ANDROID_STUDIO_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      LOCAL_ANDROID_STUDIO_IMAGE_LATEST,
    ]
  )
  cache-to = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_ANDROID_STUDIO_IMAGE_REGISTRY_CACHE},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : [],
    [
      "type=inline"
    ]
  )
  platforms = platforms
}

target "local-android-studio" {
  args = {
    android_ndk_version    = ANDROID_NDK_VERSION
    android_studio_version = ANDROID_STUDIO_VERSION
  }
  context = LOCAL_ANDROID_STUDIO_DIR
  contexts = {
    android = "target:local-android-appium-flutter"
  }
  tags = [
    LOCAL_ANDROID_STUDIO_IMAGE_LATEST,
    LOCAL_ANDROID_STUDIO_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_ANDROID_STUDIO_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      LOCAL_ANDROID_STUDIO_IMAGE_LATEST,
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : []
  )
}
