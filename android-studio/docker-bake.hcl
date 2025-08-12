variable "ANDROID_STUDIO_IMAGE_TAG" {
  default = notequal("", LOCAL_VERSION) ? "${PUBLIC_IMAGES_BASE}:android-studio-${LOCAL_VERSION}" : ""
}

variable "LOCAL_ANDROID_STUDIO_IMAGE" {
  default = "${PUBLIC_IMAGES_BASE}:android-studio-latest"
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

variable "LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_CACHE_READ" {
  description = "local read cache for android-studio image build (cannot be used before first write)"
}

target "android-studio-ci" {
  args = {
    android_studio_version = ANDROID_STUDIO_VERSION
    android_ndk_version    = ANDROID_NDK_VERSION
    flutter_version        = FLUTTER_VERSION
  }
  context    = "${LOCAL_DIR}/android-studio"
  dockerfile = "Dockerfile"
  tags = [
    LOCAL_ANDROID_STUDIO_IMAGE,
    ANDROID_STUDIO_IMAGE_TAG,
  ]
  cache-from = [
    LOCAL_ANDROID_STUDIO_IMAGE,
    LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_CACHE_READ,
  ]
  cache-to  = ["type=inline"]
  platforms = platforms
}

target "android-studio" {
  args = {
    android_studio_version = ANDROID_STUDIO_VERSION
    android_ndk_version    = ANDROID_NDK_VERSION
    flutter_version        = FLUTTER_VERSION
  }
  context    = "${LOCAL_DIR}/android-studio"
  dockerfile = "Dockerfile"
  tags = [
    LOCAL_ANDROID_STUDIO_IMAGE,
    ANDROID_STUDIO_IMAGE_TAG,
  ]
  cache-from = [
    LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_CACHE_READ,
  ]
  cache-to = [
    LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_CACHE_WRITE
  ]
}
