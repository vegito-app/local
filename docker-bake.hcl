variable "GIT_TAG" {}

variable "VERSION" {
  default = "dev"
}

variable "REPOSITORY" {
  default = "docker-repository"
}

variable "PUBLIC_REPOSITORY" {
  default = "docker-repository-public"
}

variable "PUBLIC_IMAGES_BASE" {
  default = "${PUBLIC_REPOSITORY}/utrade"
}

variable "BUILDER_IMAGE_VERSION" {
  default = notequal("dev", VERSION) ? "${PUBLIC_IMAGES_BASE}:builder-${VERSION}" : ""
}

variable "BUILDER_IMAGE_TAG" {
  default = notequal("", GIT_TAG) ? "${PUBLIC_IMAGES_BASE}:builder-${GIT_TAG}" : ""
}

variable "LATEST_BUILDER_IMAGE" {
  default = "${PUBLIC_IMAGES_BASE}:builder-latest"
}

variable "LATEST_GITHUB_RUNNER_IMAGE" {
  default = "${PUBLIC_IMAGES_BASE}:github-runnner-latest"
}

group "dev" {
  targets = ["builder"]
}

variable "PWD" {}

target "builder" {
  context    = "."
  dockerfile = "local/builder.Dockerfile"
  tags = [
    LATEST_BUILDER_IMAGE,
    BUILDER_IMAGE_VERSION,
    BUILDER_IMAGE_TAG,
  ]
  cache-from = [LATEST_BUILDER_IMAGE]
  cache-to   = ["type=inline"]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
  args = {
    host_pwd = PWD
  }
}


target "local-builder" {
  context    = "."
  dockerfile = "local/builder.Dockerfile"
  tags = [
    LATEST_BUILDER_IMAGE,
    BUILDER_IMAGE_VERSION,
    BUILDER_IMAGE_TAG,
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

default_backend_version = "backend-latest"

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
    builder_image = BUILDER_IMAGE_VERSION
  }
  tags = [
    BACKEND_IMAGE,
    notequal("", GIT_TAG) ? "${IMAGE_BASE}:${GIT_TAG}-backend" : "",
    "${IMAGE_BASE}:backend-latest",
  ]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
  cache-from = ["${IMAGE_BASE}:backend-latest"]
  cache-to   = ["type=inline"]
  secret = [
    "type=file,id=google_maps_api_key,src=${GOOGLE_MAPS_API_KEY_FILE}"
  ]
}

variable "HOME" {
  default = null
}

target "default" {
}
