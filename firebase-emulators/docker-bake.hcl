variable "LOCAL_FIREBASE_EMULATORS_IMAGE_TAG" {
  default = notequal("", LOCAL_VERSION) ? "${PUBLIC_IMAGES_BASE}:firebase-emulators-${LOCAL_VERSION}" : ""
}

variable "LOCAL_FIREBASE_EMULATORS_LATEST_IMAGE" {
  default = "${PUBLIC_IMAGES_BASE}:firebase-emulators-latest"
}

variable "LOCAL_FIREBASE_EMULATORS_IMAGE_DOCKER_BUILDX_CACHE_WRITE" {
  description = "local write cache for firebase-emulators image build"
}

variable "LOCAL_FIREBASE_EMULATORS_IMAGE_DOCKER_BUILDX_CACHE_READ" {
  description = "local read cache for firebase-emulators image build (cannot be used before first write)"
}

target "firebase-emulators-ci" {
  args = {
    builder_image = LOCAL_BUILDER_IMAGE
  }
  context = "${LOCAL_DIR}/firebase-emulators"
  tags = [
    LOCAL_FIREBASE_EMULATORS_LATEST_IMAGE,
    LOCAL_FIREBASE_EMULATORS_IMAGE_TAG,
  ]
  cache-from = [
    LOCAL_BUILDER_IMAGE,
    LOCAL_FIREBASE_EMULATORS_LATEST_IMAGE,
    LOCAL_FIREBASE_EMULATORS_IMAGE_DOCKER_BUILDX_CACHE_READ,
  ]
  cache-to  = ["type=inline"]
  platforms = platforms
}

target "firebase-emulators" {
  args = {
    builder_image = LOCAL_BUILDER_IMAGE
  }
  context = "${LOCAL_DIR}/firebase-emulators"
  tags = [
    LOCAL_FIREBASE_EMULATORS_LATEST_IMAGE,
    LOCAL_FIREBASE_EMULATORS_IMAGE_TAG,
  ]
  cache-from = [
    LOCAL_FIREBASE_EMULATORS_IMAGE_DOCKER_BUILDX_CACHE_READ,
    LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_CACHE_READ,
  ]
  cache-to = [
    LOCAL_FIREBASE_EMULATORS_IMAGE_DOCKER_BUILDX_CACHE_WRITE
  ]
}
