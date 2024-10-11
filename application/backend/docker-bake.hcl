variable "BACKEND_IMAGES_BASE" {
  default = "${REPOSITORY}/utrade:backend"
}

variable "BACKEND_IMAGE_VERSION" {
  default = notequal("dev", VERSION) ? "${BACKEND_IMAGES_BASE}-${VERSION}" : ""
}

variable "LATEST_BACKEND_IMAGE" {
  default = "${BACKEND_IMAGES_BASE}-latest"
}

target "backend-ci" {
  dockerfile = "application/backend/Dockerfile"
  args = {
    builder_image = LATEST_BUILDER_IMAGE
  }
  tags = [
    BACKEND_IMAGE_VERSION,
    LATEST_BACKEND_IMAGE,
  ]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
  cache-from = [
    LATEST_BUILDER_IMAGE,
    LATEST_BACKEND_IMAGE,
  ]
  cache-to = [
    "type=inline",
  ]
}

variable "backend_local_build_cache" {
  description = "local cache for backend image build"
  default     = "~/.docker_buildx/backend"
}

target "backend" {
  dockerfile = "application/backend/Dockerfile"
  args = {
    builder_image = LATEST_BUILDER_IMAGE
  }
  tags = [
    BACKEND_IMAGE_VERSION,
    LATEST_BACKEND_IMAGE,
  ]
  # cache-from = [
  #   "type=local,src=${backend_local_build_cache}",
  #   LATEST_BUILDER_IMAGE,
  #   LATEST_BACKEND_IMAGE
  # ]
  # cache-to = [
  #   "type=inline",
  #   "type=local,dest=${backend_local_build_cache}",
  # ]
}
