# Changelog

All notable changes to this project will be documented in this file. See [standard-version](https://github.com/conventional-changelog/standard-version) for commit guidelines.

## [1.10.0](https://github.com/vegito-app/local/compare/v1.9.1...v1.10.0) (2026-01-22)


### Features

* **docker, mobile:** add Docker image tags CI target and fix mobile makefile typo ([50ec4be](https://github.com/vegito-app/local/commit/50ec4befc8fd47e380744fb51778069ce27f0ab2))
* **workflow:** enhance GCS upload with environment-specific artifact handling ([4ba487d](https://github.com/vegito-app/local/commit/4ba487d5739e5be3daff3154e7cb0b7206e6cb73))
* **workflows:** enhance backend release and Trivy scan workflows with GCS integration ([9c04626](https://github.com/vegito-app/local/commit/9c04626e21a28f969204e477042cc91b6245315b))


### Bug Fixes

* **workflow:** replace 'gcloud-auth-docker' with 'docker-login' ([a9bf794](https://github.com/vegito-app/local/commit/a9bf794d4c9bb42b40ffa68e340a8f5bd05090ac))

### [1.9.1](https://github.com/vegito-app/local/compare/v1.9.0...v1.9.1) (2025-12-31)

## [1.9.0](https://github.com/vegito-app/local/compare/v1.8.6...v1.9.0) (2025-12-28)


### Features

* **trivy:** add HTML report template and workflow for Docker image scanning ([23c1fee](https://github.com/vegito-app/local/commit/23c1fee6357f34f9193014f11c13e56dddbc8314))
* **workflows:** add version calculation and finalization GitHub Actions ([6e881a9](https://github.com/vegito-app/local/commit/6e881a99b8a22da56e823099068e3656c8509ec2))

### [1.8.6](https://github.com/vegito-app/local/compare/v1.8.5...v1.8.6) (2025-11-18)

### [1.8.5](https://github.com/vegito-app/local/compare/v1.8.4...v1.8.5) (2025-11-11)

### [1.8.4](https://github.com/vegito-app/local/compare/v1.8.3...v1.8.4) (2025-11-01)

### [1.8.3](https://github.com/vegito-app/local/compare/v1.8.2...v1.8.3) (2025-10-31)

### [1.8.2](https://github.com/vegito-app/local/compare/v1.8.1...v1.8.2) (2025-10-31)


### Bug Fixes

* **docker:** remove suppressed error output during tag listing ([98830dd](https://github.com/vegito-app/local/commit/98830ddc69994ba4cffbc84eef75711b4a88e604))

### [1.8.1](https://github.com/vegito-app/local/compare/v1.8.0...v1.8.1) (2025-10-31)

### [1.8.1](https://github.com/vegito-app/local/compare/v1.8.0...v1.8.1) (2025-10-31)

## [1.8.0](https://github.com/vegito-app/local/compare/v1.7.2...v1.8.0) (2025-10-31)


### Features

* **build:** update docker build group naming and add tag listings ([c05d0bb](https://github.com/vegito-app/local/commit/c05d0bbba177b2733b2f4e9e0e7b916c2658b3f8))

### [1.7.2](https://github.com/vegito-app/local/compare/v1.7.1...v1.7.2) (2025-10-31)


### Bug Fixes

* **entrypoint:** ensure symlink creation does not fail if it exists ([ce71d2c](https://github.com/vegito-app/local/commit/ce71d2cc8dccc06616753bbd2e5f5a1f82e536fb))

### [1.7.1](https://github.com/vegito-app/local/compare/v1.7.0...v1.7.1) (2025-10-30)

## [1.7.0](https://github.com/vegito-app/local/compare/v1.6.9...v1.7.0) (2025-10-30)


### Features

* **workflows:** enhance release and test logging ([59754d1](https://github.com/vegito-app/local/commit/59754d1424d2f58b81b44167367f80b6a6dc9c15))

### [1.6.9](https://github.com/vegito-app/local/compare/v1.6.8...v1.6.9) (2025-10-29)


### Bug Fixes

* **release-script:** correct image path for android preview ([b8ee522](https://github.com/vegito-app/local/commit/b8ee522347b7ccf23e5db207b3a3fdc229be5102))

### [1.6.8](https://github.com/vegito-app/local/compare/v1.6.7...v1.6.8) (2025-10-29)

### [1.6.7](https://github.com/vegito-app/local/compare/v1.6.6...v1.6.7) (2025-10-29)

### [1.6.6](https://github.com/vegito-app/local/compare/v1.6.5...v1.6.6) (2025-10-28)

### [1.6.5](https://github.com/vegito-app/local/compare/v1.6.4...v1.6.5) (2025-10-27)

### [1.6.3](https://github.com/vegito-app/local/compare/v1.6.2...v1.6.3) (2025-10-25)

### [1.6.2](https://github.com/vegito-app/local/compare/v1.6.1...v1.6.2) (2025-10-25)

### [1.6.1](https://github.com/vegito-app/local/compare/v1.6.0...v1.6.1) (2025-10-25)

## [1.6.0](https://github.com/vegito-app/local/compare/v1.5.3...v1.6.0) (2025-10-21)


### Features

* **docs:** add French README and rename release workflow ([b1e1394](https://github.com/vegito-app/local/commit/b1e13946e999e781e82dad56191364d97b9fccc8))
* **github-actions:** enhance Docker build process and add README for self-hosted runners ([39b34be](https://github.com/vegito-app/local/commit/39b34be04216b1bf2ecd9ab140df98711d5edea2))

### [1.5.3](https://github.com/vegito-app/local/compare/v1.5.2...v1.5.3) (2025-10-10)


### Bug Fixes

* **docker-compose:** increase replicas and parallelism for GitHub Actions runner ([49dfcc3](https://github.com/vegito-app/local/commit/49dfcc3591c768328e240a103e871e665fce3620))

### [1.5.2](https://github.com/vegito-app/local/compare/v1.5.1...v1.5.2) (2025-10-10)

### [1.5.1](https://github.com/vegito-app/local/compare/v1.5.0...v1.5.1) (2025-10-10)


### Bug Fixes

* **workflow:** correct formatting in docker image tag generation output ([9945781](https://github.com/vegito-app/local/commit/994578170307dbfe4a82f95c0211a960770b8679))

## [1.5.0](https://github.com/vegito-app/local/compare/v1.4.0...v1.5.0) (2025-10-10)


### Features

* **ci:** improve changelog and storage path structure ([fe1854e](https://github.com/vegito-app/local/commit/fe1854e3d43cc3e3f43a3c245e5d2a01097addfb))

## [1.4.0](https://github.com/vegito-app/local/compare/v1.3.0...v1.4.0) (2025-10-10)


### Features

* **android:** improve docker and CI workflow for Android development ([9e40479](https://github.com/vegito-app/local/commit/9e404798fb6ac681780d5c8f1a2e736693a0369c))

## [1.3.0](https://github.com/vegito-app/local/compare/v1.2.0...v1.3.0) (2025-10-08)


### Features

* **ci:** add step to download Android artifacts in workflow ([eb9faf2](https://github.com/vegito-app/local/commit/eb9faf29f2aa028afd45a9563cd84a607ac278cc))

## [1.2.0](https://github.com/vegito-app/local/compare/v1.1.0...v1.2.0) (2025-10-08)


### Features

* **android:** improve docker and CI workflow for Android development ([7f0310f](https://github.com/vegito-app/local/commit/7f0310f819fc7d323d61b3f001a14dc8532486c9))
* **containers:** integrate swiftshader for GPU emulation, update scripts ([be30394](https://github.com/vegito-app/local/commit/be3039412b7fcd087fdd3dae67212e347767990f))
* **devcontainer:** add .envrc initialization and improve directory structure ([663c144](https://github.com/vegito-app/local/commit/663c14465450693b8312b6884342fb0a42e279fc))
* **devcontainer:** improve container persistence and environment variables ([094aa80](https://github.com/vegito-app/local/commit/094aa809dcc4353cf3a2f3950f8674b165f828fc))
* **docker:** activate docker buildx for arm64 platforms ([c42666d](https://github.com/vegito-app/local/commit/c42666d0ed4d97836563a9142209453cae287f13))
* **github-actions:** enhance release and cleanup workflows ([094250f](https://github.com/vegito-app/local/commit/094250f0c2519dafe076bbb83e526ae89623604f))
* **github-actions:** update workflows and docker makefile for CI/CD improvements ([1dd61b7](https://github.com/vegito-app/local/commit/1dd61b7e44564c5e9fa0609a92bed979df87eed4))
* **security:** integrate Gitleaks for secret scanning ([edbf34c](https://github.com/vegito-app/local/commit/edbf34c29010d5c2fd5f962f8856fbebc0ace7f5))
* **workflow, dockerfile:** enhance changelog and keystore handling ([4808571](https://github.com/vegito-app/local/commit/4808571967d5c755afc0faf7a8a3f73959c37998))

### [0.0.3](https://github.com/vegito-app/local/compare/v0.0.2...v0.0.3) (2025-09-07)

### [0.0.2](https://github.com/vegito-app/local/compare/v0.0.1...v0.0.2) (2025-09-06)


### Features

* **docker:** refine CI/CD build scripts and docker composition ([91b7eca](https://github.com/vegito-app/local/commit/91b7eca792eb2aa85d50ea019d43896070dd53ec))

### [0.0.1](https://github.com/vegito-app/local/compare/v0.0.0...v0.0.1) (2025-09-06)
