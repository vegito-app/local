variable "LOCAL_ANDROID_EMULATOR_VERSION" {
  default = notequal("", VERSION) ? "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-emulator-${VERSION}" : ""
}

variable "LOCAL_ANDROID_EMULATOR_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}/cache/local-android-emulator"
}

variable "LOCAL_ANDROID_EMULATOR_IMAGE_REGISTRY_CACHE_CI" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}/cache/local-android-emulator/ci"
}

variable "LOCAL_ANDROID_EMULATOR_DIR" {
  default = "${LOCAL_ANDROID_DIR}/emulator"
}

variable "LOCAL_ANDROID_EMULATOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE" {
  default = "${LOCAL_ANDROID_EMULATOR_DIR}/.containers/android-emulator/docker-buildx-cache"
}

variable "LOCAL_ANDROID_EMULATOR_IMAGE_DOCKER_BUILDX_CACHE_WRITE" {
  description = "local write cache for local-android-emulator image build"
  default = "type=local,mode=max,dest=${LOCAL_ANDROID_EMULATOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "LOCAL_ANDROID_EMULATOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  description = "local read cache for local-android-emulator image build (cannot be used before first write)"
  default = "type=local,src=${LOCAL_ANDROID_EMULATOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "LOCAL_ANDROID_EMULATOR_IMAGE_LATEST" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-emulator-latest"
}

target "local-android-emulator-ci" {
  context = LOCAL_ANDROID_EMULATOR_DIR
  tags = [
    LOCAL_ANDROID_EMULATOR_IMAGE_LATEST,
    LOCAL_ANDROID_EMULATOR_VERSION,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_ANDROID_EMULATOR_IMAGE_REGISTRY_CACHE_CI}" : "",
    "type=inline,ref=${LOCAL_ANDROID_EMULATOR_IMAGE_LATEST}",
    LOCAL_ANDROID_EMULATOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_ANDROID_EMULATOR_IMAGE_REGISTRY_CACHE_CI},mode=max" : "type=inline",
  ]
  platforms = platforms
}

target "local-android-emulator" {
  context = LOCAL_ANDROID_EMULATOR_DIR
  tags = [
    LOCAL_ANDROID_EMULATOR_IMAGE_LATEST,
    LOCAL_ANDROID_EMULATOR_VERSION,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_ANDROID_EMULATOR_IMAGE_REGISTRY_CACHE}" : "",
    LOCAL_ANDROID_EMULATOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
    "type=inline,ref=${LOCAL_ANDROID_EMULATOR_IMAGE_LATEST}",
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_ANDROID_EMULATOR_IMAGE_REGISTRY_CACHE},mode=max" : LOCAL_ANDROID_EMULATOR_IMAGE_DOCKER_BUILDX_CACHE_WRITE,
  ]
}
