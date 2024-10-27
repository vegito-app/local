variable "ANDROID_STUDIO_IMAGE_VERSION" {
  default = notequal("dev", VERSION) ? "${PUBLIC_IMAGES_BASE}:android-studio-${VERSION}" : ""
}

variable "ANDROID_STUDIO_IMAGE_TAG" {
  default = notequal("", VERSION) ? "${PUBLIC_IMAGES_BASE}:android-studio-${VERSION}" : ""
}

variable "LATEST_ANDROID_STUDIO_IMAGE" {
  default = "${PUBLIC_IMAGES_BASE}:android-studio-latest"
}

variable "ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE" {
  description = "local write cache for android-studio image build"
}

variable "ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  description = "local read cache for android-studio image build (cannot be used before first write)"
}

target "android-studio-ci" {
  args = {
    builder_image = LATEST_BUILDER_IMAGE
  }
  context    = "local/android"
  dockerfile = "studio.Dockerfile"
  tags = [
    LATEST_ANDROID_STUDIO_IMAGE,
    ANDROID_STUDIO_IMAGE_VERSION,
    ANDROID_STUDIO_IMAGE_TAG,
  ]
  cache-from = [
    LATEST_BUILDER_IMAGE,
    LATEST_ANDROID_STUDIO_IMAGE
  ]
  cache-to  = ["type=inline"]
  platforms = platforms
  push      = true
}

target "android-studio" {
  args = {
    builder_image = LATEST_BUILDER_IMAGE
  }
  context    = "local/android"
  dockerfile = "studio.Dockerfile"
  tags = [
    LATEST_ANDROID_STUDIO_IMAGE,
    ANDROID_STUDIO_IMAGE_VERSION,
    ANDROID_STUDIO_IMAGE_TAG,
  ]
  cache-from = [
    ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
    BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
  ]
  cache-to = [
    ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE
  ]
  load = true
}
