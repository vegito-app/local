variable "LOCAL_DIR" {
  default = "."
}
variable "VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME" {
  default = "${VEGITO_PUBLIC_REPOSITORY}/vegito-local-public"
}

variable "LOCAL_BUILDER_IMAGE_VERSION" {
  default = VEGITO_DOCKER_DEBIAN_PROJECT_BUILDER_IMAGE_VERSION
}
