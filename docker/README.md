
![Release Version](https://img.shields.io/github/v/release/vegito-app/docker?sort=semver)
![CI](https://github.com/vegito-app/docker/actions/workflows/docker-release.yml/badge.svg?branch=main)

# docker

Standalone OCI foundation images extracted from `vegito-app/local`.

This repository contains reusable Docker and runtime foundations used by the Vegito platform:

- Debian development base images
- GPU and desktop runtime images
- X11 / Wayland / Xpra remote desktop stack
- Rootless Docker-in-Docker images
- Rust and Golang base images

## Goals

- Reduce BuildKit DAG complexity in `vegito-app/local`
- Stabilize reusable OCI foundations
- Improve CI build times and cache reuse
- Decouple foundation image releases from application repositories

## CI

The repository uses a standalone GitHub Actions pipeline:

```text
version-changelog
    ↓
build-foundation-images
```

The generated OCI images are intended to be consumed from external repositories using immutable image references instead of `target:` BuildKit dependencies.

## Repository Role

This repository provides:

- OCI foundation/runtime images
- reusable desktop/container runtimes
- base developer environments

This repository does not contain:

- business applications
- mobile application releases
- Stripe/Firebase application environments
- integration test orchestration

Those concerns remain in higher-level repositories such as `vegito-app/local` and application repositories.
