variable "LOCAL_FIREBASE_EMULATORS_IMAGE_TAG" {
  default = notequal("", LOCAL_VERSION) ? "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:firebase-emulators-${LOCAL_VERSION}" : ""
}

variable "LOCAL_FIREBASE_EMULATORS_IMAGE_LATEST" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:firebase-emulators-latest"
}

variable "LOCAL_FIREBASE_EMULATORS_REGISTRY_CACHE_IMAGE" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}/cache/firebase-emulators"
}

variable "LOCAL_FIREBASE_EMULATORS_IMAGE_DOCKER_BUILDX_CACHE_WRITE" {
  description = "local write cache for firebase-emulators image build"
}

variable "LOCAL_FIREBASE_EMULATORS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  description = "local read cache for firebase-emulators image build (cannot be used before first write)"
}

target "firebase-emulators-ci" {
  args = {
    builder_image = LOCAL_BUILDER_IMAGE_LATEST
  }
  context = "${LOCAL_DIR}/firebase-emulators"
  tags = [
    LOCAL_FIREBASE_EMULATORS_IMAGE_LATEST,
    LOCAL_FIREBASE_EMULATORS_IMAGE_TAG,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_FIREBASE_EMULATORS_REGISTRY_CACHE_IMAGE}" : LOCAL_FIREBASE_EMULATORS_IMAGE_LATEST,
    LOCAL_FIREBASE_EMULATORS_IMAGE_LATEST,
    LOCAL_FIREBASE_EMULATORS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_FIREBASE_EMULATORS_REGISTRY_CACHE_IMAGE},mode=max" : "type=inline"
  ]
  platforms = platforms
}

target "firebase-emulators" {
  args = {
    builder_image = LOCAL_BUILDER_IMAGE_LATEST
  }
  context = "${LOCAL_DIR}/firebase-emulators"
  tags = [
    LOCAL_FIREBASE_EMULATORS_IMAGE_LATEST,
    LOCAL_FIREBASE_EMULATORS_IMAGE_TAG,
  ]
  cache-from = [
    LOCAL_FIREBASE_EMULATORS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
    LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_FIREBASE_EMULATORS_REGISTRY_CACHE_IMAGE},mode=max" : ""
  ]
  cache-to = [
    LOCAL_FIREBASE_EMULATORS_IMAGE_DOCKER_BUILDX_CACHE_WRITE,
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_FIREBASE_EMULATORS_REGISTRY_CACHE_IMAGE},mode=max" : ""
  ]
}
