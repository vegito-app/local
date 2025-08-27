variable "LOCAL_APPLICATION_MOBILE_IMAGE_TAG" {
  default = notequal("", VERSION) ? "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:application-mobile-${VERSION}" : ""
}

variable "LOCAL_APPLICATION_MOBILE_IMAGE_LATEST" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:application-mobile-latest"
}

variable "LOCAL_APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_CACHE_WRITE" {
  description = "local write cache for application-mobile image build"
}

variable "LOCAL_APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  description = "local read cache for application-mobile image build (cannot be used before first write)"
}

variable "LOCAL_APPLICATION_MOBILE_ANDROID_STUDIO_IMAGE" {
  description = "Android Studio image to use for mobile application builds"
  default     = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-studio-latest"
}

target "application-mobile" {
  args = {
    android_studio_image = LOCAL_APPLICATION_MOBILE_ANDROID_STUDIO_IMAGE
    environment          = INFRA_ENV
  }
  context    = LOCAL_APPLICATION_DIR
  dockerfile = "mobile/Dockerfile"
  tags = [
    LOCAL_APPLICATION_MOBILE_IMAGE_LATEST,
    LOCAL_APPLICATION_MOBILE_IMAGE_TAG,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_APPLICATION_MOBILE_REGISTRY_CACHE_IMAGE}" : "",
    LOCAL_APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
    "type=inline,ref=${LOCAL_APPLICATION_MOBILE_IMAGE_LATEST}"
  ]
  cache-to = [
    LOCAL_APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_CACHE_WRITE,
  ]
  platforms = ["linux/amd64"]
}

target "application-mobile-ci" {
  args = {
    android_studio_image = LOCAL_APPLICATION_MOBILE_ANDROID_STUDIO_IMAGE
    environment          = INFRA_ENV
  }
  context    = LOCAL_APPLICATION_DIR
  dockerfile = "mobile/Dockerfile"
  tags = [
    LOCAL_APPLICATION_MOBILE_IMAGE_LATEST,
    LOCAL_APPLICATION_MOBILE_IMAGE_TAG,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ},mode=max" : "",
    "type=inline,ref=${LOCAL_APPLICATION_MOBILE_IMAGE_LATEST}",
    LOCAL_APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_CACHE_WRITE},mode=max" : "type=inline"
  ]
  platforms = ["linux/amd64"]
}

