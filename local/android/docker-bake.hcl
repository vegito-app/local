variable "ANDROID_STUDIO_IMAGE_VERSION" {
  default = notequal("dev", VERSION) ? "${PUBLIC_IMAGES_BASE}:android-studio-${VERSION}" : ""
}

variable "ANDROID_STUDIO_IMAGE_TAG" {
  default = notequal("", VERSION) ? "${PUBLIC_IMAGES_BASE}:android-studio-${VERSION}" : ""
}

variable "LATEST_ANDROID_STUDIO_IMAGE" {
  default = "${PUBLIC_IMAGES_BASE}:android-studio-latest"
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
  cache-to = ["type=inline"]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
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
    LATEST_BUILDER_IMAGE,
    LATEST_ANDROID_STUDIO_IMAGE
  ]
  cache-to = ["type=inline"]
}
