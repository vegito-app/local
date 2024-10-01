variable "BUILDER_IMAGE_VERSION" {
  default = notequal("dev", VERSION) ? "${PUBLIC_IMAGES_BASE}:builder-${VERSION}" : ""
}

variable "LATEST_BUILDER_IMAGE" {
  default = "${PUBLIC_IMAGES_BASE}:builder-latest"
}

target "builder" {
  dockerfile = "local/builder.Dockerfile"
  tags = [
    LATEST_BUILDER_IMAGE,
    BUILDER_IMAGE_VERSION,
  ]
  cache-from = [LATEST_BUILDER_IMAGE]
  cache-to   = ["type=inline"]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}

target "builder-local" {
  dockerfile = "local/builder.Dockerfile"
  tags = [
    LATEST_BUILDER_IMAGE,
    BUILDER_IMAGE_VERSION,
  ]
  cache-from = [LATEST_BUILDER_IMAGE]
  cache-to   = ["type=inline"]
}
