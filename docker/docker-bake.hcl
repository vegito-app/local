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

group "services-load-local-arch" {
  targets = [
    "backend",
    "github-runner",
  ]
}

group "services-push-multi-arch" {
  targets = [
    "backend-ci",
    "github-runner-ci",
  ]
}
