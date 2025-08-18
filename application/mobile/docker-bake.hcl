variable "APPLICATION_MOBILE_IMAGE_TAG" {
  default = notequal("", VERSION) ? "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:application-mobile-${VERSION}" : ""
}

variable "APPLICATION_MOBILE_IMAGE_LATEST" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:application-mobile-latest"
}

variable "APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_CACHE_WRITE" {
  description = "local write cache for application-mobile image build"
}

variable "APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  description = "local read cache for application-mobile image build (cannot be used before first write)"
}

variable "APPLICATION_MOBILE_ANDROID_STUDIO_IMAGE" {
  description = "Android Studio image to use for mobile application builds"
  default     = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-studio-latest"
}

target "application-mobile" {
  args = {
    android_studio_image = APPLICATION_MOBILE_ANDROID_STUDIO_IMAGE
    environment          = INFRA_ENV
  }
  context    = "${LOCAL_APPLICATION_DIR}"
  dockerfile = "mobile/Dockerfile"
  tags = [
    APPLICATION_MOBILE_IMAGE_LATEST,
    APPLICATION_MOBILE_IMAGE_TAG,
  ]
  cache-from = [
    APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
    APPLICATION_MOBILE_IMAGE_LATEST,
    USE_REGISTRY_CACHE ? "type=registry,ref=${APPLICATION_MOBILE_REGISTRY_CACHE_IMAGE}" : ""
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${APPLICATION_MOBILE_REGISTRY_CACHE_IMAGE},mode=max" : APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_CACHE_WRITE
  ]
  platforms = ["linux/amd64"]
}

target "application-mobile-ci" {
  args = {
    android_studio_image = APPLICATION_MOBILE_ANDROID_STUDIO_IMAGE
    environment          = INFRA_ENV
  }
  context    = "${LOCAL_APPLICATION_DIR}"
  dockerfile = "mobile/Dockerfile"
  tags = [
    APPLICATION_MOBILE_IMAGE_LATEST,
    APPLICATION_MOBILE_IMAGE_TAG,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${APPLICATION_MOBILE_REGISTRY_CACHE_IMAGE}" : "",
    APPLICATION_MOBILE_IMAGE_LATEST,
  ]
  cache-to  = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${APPLICATION_MOBILE_REGISTRY_CACHE_IMAGE},mode=max" : "type=inline"
  ]
  platforms = ["linux/amd64"]
}

