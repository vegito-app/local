variable "BACKEND_IMAGES_BASE" {
  default = "${REPOSITORY}/utrade"
}

variable "BACKEND_IMAGE_VERSION" {
  default = notequal("dev", VERSION) ? "${BACKEND_IMAGES_BASE}:backend-${VERSION}" : ""
}

variable "BACKEND_IMAGE_TAG" {
  default = notequal("", GIT_TAG) ? "${BACKEND_IMAGES_BASE}:backend-${GIT_TAG}" : ""
}

variable "LATEST_BACKEND_IMAGE" {
  default = "${BACKEND_IMAGES_BASE}:backend-latest"
}

group "application" {
  targets = ["backend"]
}

variable "GOOGLE_MAPS_API_KEY_FILE" {
  default = "frontend/google_maps_api_key"
}

target "backend" {
  context    = "."
  dockerfile = "application/backend/Dockerfile"
  args = {
    builder_image = LATEST_BUILDER_IMAGE
  }
  tags = [
    BACKEND_IMAGE_VERSION,
    BACKEND_IMAGE_TAG,
    LATEST_BACKEND_IMAGE,
  ]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
  cache-from = [
    LATEST_BUILDER_IMAGE,
    LATEST_BACKEND_IMAGE
  ]
  cache-to = ["type=inline"]
  secret = [
    "type=file,id=google_maps_api_key,src=${GOOGLE_MAPS_API_KEY_FILE}"
  ]
}

target "backend-local" {
  context    = "."
  dockerfile = "application/backend/Dockerfile"
  args = {
    builder_image = LATEST_BUILDER_IMAGE
  }
  tags = [
    BACKEND_IMAGE_VERSION,
    BACKEND_IMAGE_TAG,
    LATEST_BACKEND_IMAGE,
  ]
  cache-from = [
    LATEST_BUILDER_IMAGE,
    LATEST_BACKEND_IMAGE
  ]
  cache-to = ["type=inline"]
  secret = [
    "type=file,id=google_maps_api_key,src=${GOOGLE_MAPS_API_KEY_FILE}"
  ]
}
