group "docker-debian-ci" {
  targets = [
    "docker-debian-bookworm-ci",
    "docker-debian-trixie-ci",
  ]
}

group "docker-debian" {
  targets = [
    "docker-debian-bookworm",
    "docker-debian-trixie",
  ]
}

# Bookworm targets
group "docker-debian-bookworm-ci" {
  targets = [
    "docker-debian-bookworm-version-ci",
    "docker-debian-bookworm-latest-ci",
  ]
}

target "docker-debian-bookworm-base" {
  context    = VEGITO_DOCKER_IO_HUB_DIR
  dockerfile = "debian.Dockerfile"
  args = {
    debian_version = "bookworm"
  }
}

target "docker-debian-bookworm-latest-ci" {
  inherits = ["docker-debian-bookworm-base"]
  tags = [
    VEGITO_DOCKER_DEBIAN_IMAGE_LATEST
  ]
}

target "docker-debian-bookworm-version-ci" {
  inherits = ["docker-debian-bookworm-base"]
  tags = [
    VEGITO_DOCKER_DEBIAN_IMAGE_VERSION
  ]
}

target "docker-debian-bookworm" {
  inherits = ["docker-debian-bookworm-base"]
  tags = [
    VEGITO_DOCKER_DEBIAN_IMAGE_VERSION,
    VEGITO_DOCKER_DEBIAN_IMAGE_LATEST,
  ]
}

# Trixie targets

group "docker-debian-trixie-ci" {
  targets = [
    "docker-debian-trixie-version-ci",
    "docker-debian-trixie-latest-ci",
  ]
}

target "docker-debian-trixie-base" {
  context    = VEGITO_DOCKER_IO_HUB_DIR
  dockerfile = "debian.Dockerfile"
  args = {
    debian_version = "trixie"
  }
}

target "docker-debian-trixie-latest-ci" {
  inherits = ["docker-debian-trixie-base"]
  tags = [
    VEGITO_DOCKER_DEBIAN_IMAGE_LATEST
  ]
}

target "docker-debian-trixie-version-ci" {
  inherits = ["docker-debian-trixie-base"]
  tags = [
    VEGITO_DOCKER_DEBIAN_IMAGE_VERSION
  ]
}

target "docker-debian-trixie" {
  inherits = ["docker-debian-trixie-base"]
  tags = [
    VEGITO_DOCKER_DEBIAN_IMAGE_VERSION,
    VEGITO_DOCKER_DEBIAN_IMAGE_LATEST,
  ]
}
