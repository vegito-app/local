variable "REPOSITORY" {
  default = "docker-repository"
}

variable "PUBLIC_REPOSITORY" {
  default = "docker-repository-public"
}

variable "PUBLIC_IMAGES_BASE" {
  default = "${PUBLIC_REPOSITORY}/main"
}

variable "BUILDER_IMAGE" {
  default = "${PUBLIC_IMAGES_BASE}:builder"
}

variable "LATEST_BUILDER_IMAGE" {
  default = "${PUBLIC_IMAGES_BASE}:latest-builder"
}

variable "GIT_TAG" {}

variable "VERSION" {
  default = "dev"
}

group "dev" {
  targets = ["builder"]
}

variable "PWD" {}

target "builder" {
  context    = "."
  dockerfile = "builder.Dockerfile"
  tags = [
    LATEST_BUILDER_IMAGE,
    notequal("dev", VERSION) ? "${PUBLIC_IMAGES_BASE}:${VERSION}-builder" : "",
    notequal("", GIT_TAG) ? "${PUBLIC_IMAGES_BASE}:${GIT_TAG}-builder" : "",
  ]
  cache-from = [LATEST_BUILDER_IMAGE]
  cache-to   = ["type=inline"]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
  push = false
  args = {
    host_pwd = PWD
  }
}

target "localbuilder" {
  context    = "."
  dockerfile = "builder.Dockerfile"
  tags = [
    LATEST_BUILDER_IMAGE,
    notequal("", GIT_TAG) ? "${PUBLIC_IMAGES_BASE}:${GIT_TAG}-builder" : "",
  ]
  cache-from = [LATEST_BUILDER_IMAGE]
  cache-to   = ["type=inline"]
  args = {
    host_pwd = PWD
  }
}

group "application" {
  targets = ["backend"]
}

variable "IMAGE_BASE" {
  default = "${REPOSITORY}/utrade"
}

default_backend_version = "latest-backend"

variable "VERSION" {
  default = default_backend_version
}

variable "BACKEND_IMAGE" {
  default = "${IMAGE_BASE}:${VERSION}-backend"
}

variable "GOOGLE_MAPS_API_KEY_FILE" {
  default = "frontend/google_maps_api_key"
}

target "backend" {
  context    = "."
  dockerfile = "Dockerfile"
  args = {
    builder_image = BUILDER_IMAGE
  }
  tags = [
    BACKEND_IMAGE,
    notequal("", GIT_TAG) ? "${IMAGE_BASE}:${GIT_TAG}-backend" : "",
    "${IMAGE_BASE}:latest-backend",
  ]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
  cache-from = ["${IMAGE_BASE}:latest-backend"]
  cache-to   = ["type=inline"]
  push       = true
  secret = [
    "type=file,id=google_maps_api_key,src=${GOOGLE_MAPS_API_KEY_FILE}"
  ]
}

variable "HOME" {
  default = null
}

target "default" {
}
