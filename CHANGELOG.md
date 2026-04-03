# Changelog

All notable changes to this project will be documented in this file. See [standard-version](https://github.com/conventional-changelog/standard-version) for commit guidelines.

### [1.19.1](https://github.com/vegito-app/local/compare/v1.19.0...v1.19.1) (2026-04-03)

## [1.19.0](https://github.com/vegito-app/local/compare/v1.18.0...v1.19.0) (2026-04-03)


### Features

* **docker:** add new targets to local-release-ci group ([10ab452](https://github.com/vegito-app/local/commit/10ab4525ea30dd871771a0ba56a3cc770a952e52))
* **github-actions:** integrate application-pipeline locally ([cfa0d1e](https://github.com/vegito-app/local/commit/cfa0d1ec85cf491b3d23b7d630e39516789cfeea))

## [1.18.0](https://github.com/vegito-app/local/compare/v1.17.0...v1.18.0) (2026-04-03)


### Features

* **build-context:** use dynamic context for Dockerfile build ([31dd964](https://github.com/vegito-app/local/commit/31dd9644f43ee7b79484ec513042537f50677d96))
* **ci/cd:** add environment and release bucket mapping to GitHub application pipeline ([d43cc49](https://github.com/vegito-app/local/commit/d43cc4936a4726cc22425f60930dae98a8137111))
* **ci:** add staging and prod environments to Github Actions workflow ([7761672](https://github.com/vegito-app/local/commit/7761672f7ed19cadff5285cad39275e9ddc1a5bf))
* **docker:** add option to enable RAM builder in Docker buildx ([6c9ede0](https://github.com/vegito-app/local/commit/6c9ede0e1cc688a1ac22d1af2c90662f200e7266))
* **docker:** add vegito-example-application-services-ci to local-services-ci group ([159ff53](https://github.com/vegito-app/local/commit/159ff5344cbcaeba7d48b209bcd0e91261b78b08))
* **docker:** enable local-android-flutter-ci target in bake file ([99dae0c](https://github.com/vegito-app/local/commit/99dae0ca0a2ba7bcf1988363d619c7e258c14062))
* **docker:** streamline CI Docker images build process ([5ae43bf](https://github.com/vegito-app/local/commit/5ae43bf821b03ca16a73a8e64e6c434bd69f3994))
* **frontend-build:** migrate to server-side rendering (SSR) ([4640d6c](https://github.com/vegito-app/local/commit/4640d6c65990a64f31a0cdbd2c801137dffd780f))
* **github-actions:** change 'echo' to 'printf' for new changelogs in version-changelog.yml ([dbaefbf](https://github.com/vegito-app/local/commit/dbaefbfa4f83f312af15194e042fbd3be23731a5))
* **github-actions:** configure git user for standard-version in version-changelog.yml ([c9b2cfb](https://github.com/vegito-app/local/commit/c9b2cfb71e0fb0b636f017cd2d1df68e2dbe6f59))
* **github-workflows:** enhance versioning process with accurate commit SHA ([b24972c](https://github.com/vegito-app/local/commit/b24972c64b115021bb82a5b3164c2950c901493c))
* **release-workflow:** enhance release note generation with security metadata ([dd0b780](https://github.com/vegito-app/local/commit/dd0b7803a109160ee259d4e75c33f7f37dd1aaca))


### Bug Fixes

* **docker:** rename 'example-applications' to 'vegito-example-application-applications' ([aeb07e8](https://github.com/vegito-app/local/commit/aeb07e870541f368657f79073303fb65ec417106))

## [1.17.0](https://github.com/vegito-app/local/compare/v1.16.0...v1.17.0) (2026-04-01)


### Features

* **backend:** add target to delete backend image in GCloud ([ce80df3](https://github.com/vegito-app/local/commit/ce80df3fb9c31046c42ee08325aa0a92b6a51b59))
* **build-config:** Enhance Android and Docker configurations ([21a12e6](https://github.com/vegito-app/local/commit/21a12e6e96db1794004a274228797658d544514b))
* **build:** improve caching and retry logic for Go module downloads ([6d61ecd](https://github.com/vegito-app/local/commit/6d61ecdcfd75ff3c2b2a35253b3656d3cb2c0c61))
* **CI/CD:** add Google Cloud Project ID to GitHub functional tests workflow ([7e0713a](https://github.com/vegito-app/local/commit/7e0713a9023776ee9cfc7c56e736c14e09857965))
* **ci:** adjust dependencies and metadata extraction ([fb7a1f8](https://github.com/vegito-app/local/commit/fb7a1f86bdd69b290ddff75c0bba2abf4e25fd10))
* **CI:** update GitHub actions workflow with environment-specific artifact buckets ([10d3d6d](https://github.com/vegito-app/local/commit/10d3d6d22c02ea1571f276afd5fadd20a221d538))
* **CI:** use separate make target for running commands in CI ([ad8fde0](https://github.com/vegito-app/local/commit/ad8fde0b0ce950326b8cb79362ce8f6185721ed1))
* **dependencies:** update multiple Go dependencies ([b523c5c](https://github.com/vegito-app/local/commit/b523c5c74804540142704500f33e5c560347a731))
* **docker-bake:** replace debian_image argument with context in Docker targets ([f3b2225](https://github.com/vegito-app/local/commit/f3b2225247398fff434a885b2d3d90021d9a6dd1))
* **docker-bake:** split local-firebase-emulators-ci into version and latest targets ([daadc04](https://github.com/vegito-app/local/commit/daadc045da14c90aba0f8e55409b0e91fd20fde2))
* **docker:** add local-vault-dev-ci to local-services-ci group ([363d0a7](https://github.com/vegito-app/local/commit/363d0a72bed244fd4ee8ce4d4b4fb0ff06196c50))
* **docker:** introduce Dockerfile and update build configurations ([524752b](https://github.com/vegito-app/local/commit/524752b1aebf829983bd4a7a045462862490a0c4))
* **docker:** refactor target groups for CI in Appium, Flutter and Studio ([c683550](https://github.com/vegito-app/local/commit/c683550387b14db7b8f39d7cb8ebb046e256fcde))
* **docker:** update default Go version in docker-bake.hcl ([0f6194c](https://github.com/vegito-app/local/commit/0f6194cef8673015298de97ff31a81d79f34d126))
* **github-actions:** add new required env variable for workflows ([416858a](https://github.com/vegito-app/local/commit/416858a3ee13514c84e9eecfcd0fb79b1d78ad20))
* **trivy:** add image pull step before scan ([ed34235](https://github.com/vegito-app/local/commit/ed34235bae357fb186a3ba152171d59f6b0bc0db))
* **trivy:** add Trivy vulnerability scanner integration ([a7301e6](https://github.com/vegito-app/local/commit/a7301e6dbcdb68c7d3239d289e8cea09c81680c7))
* **workflow:** improve release metadata fetching in version-finalize ([0e46802](https://github.com/vegito-app/local/commit/0e468025be590107b9e5b94392d83ec32180b719))
* **workflows:** enhance release notes with GCloud metadata ([9d76ad9](https://github.com/vegito-app/local/commit/9d76ad9c585d5d16331efaa34b15e7dd0ca0771d))
* **workflows:** introduce use_registry_cache variable in workflows ([5b5b56d](https://github.com/vegito-app/local/commit/5b5b56dc704b9388785e3dad416bd8f298b984cc))


### Bug Fixes

* **config:** fix environment redundant name prefix ([a8d3fcf](https://github.com/vegito-app/local/commit/a8d3fcf16de9a39460e1eae5dc7d164cabe36073))
* **docker:** correct target name in local-applications-ci group ([2019d1b](https://github.com/vegito-app/local/commit/2019d1bbefdc0d50f5524ab07cdda0bd484f68ac))

## [1.16.0](https://github.com/vegito-app/local/compare/v1.15.4...v1.16.0) (2026-03-16)


### Features

* **android:** add optional Facebook app ID and client token configurations ([ebcb015](https://github.com/vegito-app/local/commit/ebcb0158634b05048cc6f4e3b4ee16e03aed3207))
* **build:** introduce separate targets for latest CI images ([764dbf8](https://github.com/vegito-app/local/commit/764dbf81956b3edf24bd59f2c93b0513bfed8a96))
* **ci:** add alias name for Android release keystore in build workflow ([8a59e8c](https://github.com/vegito-app/local/commit/8a59e8c766ed11197312abdcadef1a27d01b23e5))
* **dotenv:** add android package name environment variable ([034a7a3](https://github.com/vegito-app/local/commit/034a7a3bfb6ae14f49888267829e64a4d5ad998c))
* **emulators:** update export metadata and add storage export ([02f5f44](https://github.com/vegito-app/local/commit/02f5f44fc6402e4c11e96778a4f7d2d319518a00))
* **makefile:** add dynamic compose project name configuration ([86fad2f](https://github.com/vegito-app/local/commit/86fad2f7ec0dc7321eeb07ff1b430873a266137a))
* **workflow:** add android keystore path to CI configurations ([338e2cc](https://github.com/vegito-app/local/commit/338e2cc9f57ae75cf341ba0426a12a1869efeebd))
* **workflow:** add INFRA_ENV variable and update Trivy version ([4747925](https://github.com/vegito-app/local/commit/474792537af0aedf2eaf7155033e1a5385efb1b3))


### Bug Fixes

* **android-studio:** update Android Studio download URL for Canary version ([202128a](https://github.com/vegito-app/local/commit/202128a7b4a5f9367407dc19b3bbb1d2011541b1))

### [1.15.4](https://github.com/vegito-app/local/compare/v1.15.3...v1.15.4) (2026-02-24)

### [1.15.3](https://github.com/vegito-app/local/compare/v1.15.2...v1.15.3) (2026-02-18)

### [1.15.2](https://github.com/vegito-app/local/compare/v1.15.1...v1.15.2) (2026-02-17)


### Bug Fixes

* **workflow:** correct path for release notes in version-finalize ([f599fcb](https://github.com/vegito-app/local/commit/f599fcb5004130b42b6c60d92aafc6cc1d325a47))

### [1.15.1](https://github.com/vegito-app/local/compare/v1.15.0...v1.15.1) (2026-02-16)

## [1.15.0](https://github.com/vegito-app/local/compare/v1.14.0...v1.15.0) (2026-02-14)


### Features

* **ci:** add Google Cloud authentication to version-finalize workflow ([b2c4d67](https://github.com/vegito-app/local/commit/b2c4d679ae3443a5f5c96e7fa304cd6f167abb66))

## [1.14.0](https://github.com/vegito-app/local/compare/v1.13.0...v1.14.0) (2026-02-14)


### Features

* **ci:** enhance workflow with configurable release bucket options ([f7c5582](https://github.com/vegito-app/local/commit/f7c55827f348bb984b42ec0b6da242a0a6ed2da1))
* **robotframework:** add output directory and CI execution target ([87bdda1](https://github.com/vegito-app/local/commit/87bdda1e64daab33b2af15618a63391f50c95d4c))

## [1.13.0](https://github.com/vegito-app/local/compare/v1.12.0...v1.13.0) (2026-02-12)


### Features

* **devcontainer:** enhance vscode integration and update environment settings ([e364dc5](https://github.com/vegito-app/local/commit/e364dc52b36fef02e73a44f05bc3e188ccad0bdf))
* **devcontainers:** add support for VS Code Codespaces and enhance GitHub Actions setup ([5539a07](https://github.com/vegito-app/local/commit/5539a07b50d1dd20b369dc85196efbf2bd3755b3))
* **workflow:** add configurable bucket naming for GCS uploads ([a3b0077](https://github.com/vegito-app/local/commit/a3b0077a5a9122c708371a2d99010c5bfcd46aa9))

## [1.12.0](https://github.com/vegito-app/local/compare/v1.11.0...v1.12.0) (2026-02-09)


### Features

* **devcontainer:** improve KVM group handling ([f88429e](https://github.com/vegito-app/local/commit/f88429edd307525a714f5aa6ecbbb4d50d6595d9))
* **devcontainers:** add support for VS Code Codespaces and enhance GitHub Actions setup ([ee9a018](https://github.com/vegito-app/local/commit/ee9a018d37ef2e3b8dddd4647fa984f7530c022b))

## [1.11.0](https://github.com/vegito-app/local/compare/v1.10.0...v1.11.0) (2026-01-31)


### Features

* **android:** integrate android.mk in build process and enhance AVD script ([241a489](https://github.com/vegito-app/local/commit/241a48958151bf37fae9c28e4a16887fc34fc743))
* **devcontainer:** improve cache management and script execution ([80ee258](https://github.com/vegito-app/local/commit/80ee258436dd5ad9691c73423e49fcdcee97a9fc))


### Bug Fixes

* **entrypoint:** create symlink for containers directory in workspace ([3912662](https://github.com/vegito-app/local/commit/3912662c09f65a925111fcbf6133f6a5cc3afe8d))

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
