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
