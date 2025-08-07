variable "APPLICATION_MOBILE_IMAGE_TAG" {
  default = notequal("", VERSION) ? "${PUBLIC_IMAGES_BASE}:application-mobile-${VERSION}" : ""
}

variable "APPLICATION_MOBILE_IMAGE_LATEST" {
  default = "${PUBLIC_IMAGES_BASE}:application-mobile-latest"
}

variable "APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_CACHE_WRITE" {
  description = "local write cache for application-mobile image build"
}

variable "APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_CACHE_READ" {
  description = "local read cache for application-mobile image build (cannot be used before first write)"
}

variable "APPLICATION_MOBILE_ANDROID_STUDIO_LATEST_IMAGE" {
  description = "Android Studio image to use for mobile application builds"
  default     = "${PUBLIC_IMAGES_BASE}:android-studio-latest"
}

target "application-mobile" {
  args = {
    android_studio_image = APPLICATION_MOBILE_ANDROID_STUDIO_LATEST_IMAGE
    environment          = INFRA_ENV
  }
  context    = "${LOCAL_APPLICATION_DIR}"
  dockerfile = "mobile/Dockerfile"
  tags = [
    APPLICATION_MOBILE_IMAGE_LATEST,
    APPLICATION_MOBILE_IMAGE_TAG,
  ]
  cache-from = [
    APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_CACHE_READ,
    APPLICATION_MOBILE_IMAGE_LATEST
  ]
  cache-to = [
    APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_CACHE_WRITE,
  ]
  platforms = ["linux/amd64"]
}

target "application-mobile-ci" {
  args = {
    android_studio_image = APPLICATION_MOBILE_ANDROID_STUDIO_LATEST_IMAGE
    environment          = INFRA_ENV
  }
  context    = "${LOCAL_APPLICATION_DIR}"
  dockerfile = "mobile/Dockerfile"
  tags = [
    APPLICATION_MOBILE_IMAGE_LATEST,
    APPLICATION_MOBILE_IMAGE_TAG,
  ]
  cache-from = [
    APPLICATION_MOBILE_IMAGE_LATEST
  ]
  cache-to  = ["type=inline"]
  platforms = ["linux/amd64"]
}

