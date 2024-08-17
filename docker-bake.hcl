variable "REPOSITORY" {
  default = "utrade-repository"
}

variable "BUILDER_IMAGE" {
  default = "${IMAGE_BASE}:builder"
}

default_git_tag = "latest"

variable "GIT_TAG" {
  default = default_git_tag
}

group "dev" {
  targets = ["builder"]
}

variable "PWD" {}

target "builder" {
  context    = "."
  dockerfile = "builder.Dockerfile"
  tags = [
    BUILDER_IMAGE,
    notequal("", GIT_TAG) ? "${IMAGE_BASE}:${GIT_TAG}-builder" : "",
    "${IMAGE_BASE}:latest-builder",
  ]
  cache-from = ["${IMAGE_BASE}:latest-builder"]
  cache-to   = ["type=inline"]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
  push = true
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
