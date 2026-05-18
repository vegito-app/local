variable "VEGITO_DOCKER_IO_HUB_DIR" {
  default = "${VEGITO_DOCKER_DIR}/docker.io"
}

# Groups are used to build incrementally the images in the correct order:
# - Dockerhub: the base images that we replicate to our private repository
# - Runners: the most basic level, they are used to run the services and applications
# - Builders: used to build the services, applications and the local development environments
# - Services: the dependencies of the applications, they are used to run the applications
# - Applications: the end products that we want to run and test
group "dockerhub" {
  targets = [
    "debian",
    "vegito-docker-dind-rootless",
    "golang-alpine",
    "rust",
  ]
}

group "dockerhub-ci" {
  targets = [
    "vegito-debian-latest-ci",
    "vegito-debian-version-ci",

    "vegito-docker-dind-rootless-ci",
    "golang-alpine-ci",
    "rust-ci",
  ]
}


variable "VEGITO_DOCKER_DIND_ROOTLESS_IMAGE_LATEST" {
  default = "${VEGITO_PRIVATE_REPOSITORY}/docker-dind-rootless:latest"
}

variable "VEGITO_DOCKER_DIND_ROOTLESS_IMAGE_VERSION" {
  default = "${VEGITO_PRIVATE_REPOSITORY}/docker-dind-rootless:${VERSION}"
}

variable "VEGITO_GOLANG_ALPINE_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_CACHE_IMAGES_BASE}/golang-alpine"
}

variable "VEGITO_DOCKER_DEBIAN_PYTHON_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_CACHE_IMAGES_BASE}/python"
}

variable "VEGITO_DOCKER_DIND_ROOTLESS_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_CACHE_IMAGES_BASE}/docker-dind-rootless"
}

variable "VEGITO_DOCKER_DIND_ROOTLESS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/docker-dind-rootless"
}

variable "VEGITO_DOCKER_DIND_ROOTLESS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE" {
  default = "type=local,mode=max,dest=${VEGITO_DOCKER_DIND_ROOTLESS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "VEGITO_DOCKER_DIND_ROOTLESS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  default = "type=local,src=${VEGITO_DOCKER_DIND_ROOTLESS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

group "vegito-docker-dind-rootless-ci" {
  targets = [
    "vegito-docker-dind-rootless-version-ci",
    "vegito-docker-dind-rootless-latest-ci",
  ]
}

target "vegito-docker-dind-rootless-base" {
  context    = VEGITO_DOCKER_IO_HUB_DIR
  dockerfile = "docker-dind-rootless.Dockerfile"
}

target "vegito-docker-dind-rootless-version-ci" {
  inherits = ["vegito-docker-dind-rootless-base"]
  tags = [
    VEGITO_DOCKER_DIND_ROOTLESS_IMAGE_VERSION,
  ]
  cache-from = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DIND_ROOTLESS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DIND_ROOTLESS_IMAGE_REGISTRY_CACHE}"
    ] : [],
    [
      "type=inline,ref=${VEGITO_DOCKER_DIND_ROOTLESS_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DIND_ROOTLESS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE
    ] : [],
  )
  platforms = platforms
}

target "vegito-docker-dind-rootless-latest-ci" {
  tags = [
    VEGITO_DOCKER_DIND_ROOTLESS_IMAGE_LATEST,
  ]
  inherits = ["vegito-docker-dind-rootless-base"]
  cache-from = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DIND_ROOTLESS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DIND_ROOTLESS_IMAGE_REGISTRY_CACHE}"
    ] : [],
    [
      "type=inline,ref=${VEGITO_DOCKER_DIND_ROOTLESS_IMAGE_LATEST}"
    ]
  )
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${VEGITO_DOCKER_DIND_ROOTLESS_IMAGE_REGISTRY_CACHE},mode=max" : "type=inline"
  ]
  platforms = platforms
}

target "vegito-docker-dind-rootless" {
  tags = [
    VEGITO_DOCKER_DIND_ROOTLESS_IMAGE_VERSION,
    VEGITO_DOCKER_DIND_ROOTLESS_IMAGE_LATEST,
  ]
  inherits = ["vegito-docker-dind-rootless-base"]
  cache-from = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DIND_ROOTLESS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DIND_ROOTLESS_IMAGE_REGISTRY_CACHE}"
    ] : [],
    [
      "type=inline,ref=${VEGITO_DOCKER_DIND_ROOTLESS_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DIND_ROOTLESS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE
    ] : [],
  )
}

variable "VEGITO_DOCKER_ALPINE_GO_IMAGE_LATEST" {
  default = "${VEGITO_PRIVATE_REPOSITORY}/golang-alpine:latest"
}

variable "VEGITO_DOCKER_ALPINE_GO_IMAGE_VERSION" {
  default = "${VEGITO_PRIVATE_REPOSITORY}/golang-alpine:${VERSION}"
}

variable "VEGITO_GOLANG_ALPINE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/golang-alpine"
}

variable "VEGITO_GOLANG_ALPINE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE" {
  default = "type=local,mode=max,dest=${VEGITO_GOLANG_ALPINE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "VEGITO_GOLANG_ALPINE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  default = "type=local,src=${VEGITO_GOLANG_ALPINE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

group "golang-alpine-ci" {
  targets = [
    "golang-alpine-version-ci",
    "golang-alpine-latest-ci",
  ]
}

target "vegito-golang-base" {
  context    = VEGITO_DOCKER_IO_HUB_DIR
  dockerfile = "golang.Dockerfile"
}

target "golang-alpine-version-ci" {

  tags = [
    VEGITO_DOCKER_ALPINE_GO_IMAGE_VERSION,
  ]
  inherits = ["vegito-golang-base"]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_GOLANG_ALPINE_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_GOLANG_ALPINE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      "type=inline,ref=${VEGITO_DOCKER_ALPINE_GO_IMAGE_LATEST}"
    ]
  )
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${VEGITO_GOLANG_ALPINE_IMAGE_REGISTRY_CACHE},mode=max" : "type=inline"
  ]
  platforms = platforms
}

target "golang-alpine-latest-ci" {
  tags = [
    VEGITO_DOCKER_ALPINE_GO_IMAGE_LATEST,
  ]
  inherits = ["vegito-golang-base"]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_GOLANG_ALPINE_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_GOLANG_ALPINE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      "type=inline,ref=${VEGITO_DOCKER_ALPINE_GO_IMAGE_LATEST}"
    ]
  )
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${VEGITO_GOLANG_ALPINE_IMAGE_REGISTRY_CACHE},mode=max" : "",
    "type=inline"
  ]
  platforms = platforms
}

target "golang-alpine" {
  tags = [
    VEGITO_DOCKER_ALPINE_GO_IMAGE_VERSION,
    VEGITO_DOCKER_ALPINE_GO_IMAGE_LATEST,
  ]
  inherits = ["vegito-golang-base"]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_GOLANG_ALPINE_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_GOLANG_ALPINE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      "type=inline,ref=${VEGITO_DOCKER_ALPINE_GO_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_GOLANG_ALPINE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE
    ] : []
  )
}

variable "VEGITO_RUST_IMAGE_LATEST" {
  default = "${VEGITO_PRIVATE_REPOSITORY}/rust:latest"
}

variable "VEGITO_RUST_IMAGE_VERSION" {
  default = "${VEGITO_PRIVATE_REPOSITORY}/rust:${VERSION}"
}

variable "VEGITO_RUST_IMAGE_DOCKER_BUILDX_LOCAL_CACHE" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/rust"
}

variable "VEGITO_RUST_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE" {
  default = "type=local,mode=max,dest=${VEGITO_RUST_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "VEGITO_RUST_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  default = "type=local,src=${VEGITO_RUST_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "VEGITO_RUST_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_LOCAL_CACHE_IMAGES_BASE}/rust"
}

group "rust-ci" {
  targets = [
    "rust-version-ci",
    "rust-latest-ci",
  ]
}

target "vegito-rust-base" {
  context    = VEGITO_DOCKER_IO_HUB_DIR
  dockerfile = "rust.Dockerfile"
}

target "rust-version-ci" {
  tags = [
    VEGITO_RUST_IMAGE_VERSION,
  ]
  inherits = ["vegito-rust-base"]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_RUST_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_RUST_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      "type=inline,ref=${VEGITO_RUST_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_RUST_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE
    ] : [],
  )
  platforms = platforms
}

target "rust-latest-ci" {
  tags = [
    VEGITO_RUST_IMAGE_LATEST,
  ]
  inherits = ["vegito-rust-base"]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_RUST_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_RUST_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      "type=inline,ref=${VEGITO_RUST_IMAGE_LATEST}"
    ]
  )
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${VEGITO_RUST_IMAGE_REGISTRY_CACHE},mode=max" : "",
    "type=inline"
  ]
  platforms = platforms
}

target "rust" {
  tags = [
    VEGITO_RUST_IMAGE_LATEST,
    VEGITO_RUST_IMAGE_VERSION,
  ]
  inherits = ["vegito-rust-base"]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_RUST_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_RUST_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      "type=inline,ref=${VEGITO_RUST_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_RUST_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE
    ] : []
  )
}
