# Changelog

All notable changes to this project will be documented in this file. See [standard-version](https://github.com/conventional-changelog/standard-version) for commit guidelines.

## [1.8.0](https://github.com/vegito-app/example-application/compare/v1.7.2...v1.8.0) (2026-10-29)


### Features

* **makefiles:** add docker-login and docker-buildx-setup targets ([b440574](https://github.com/vegito-app/example-application/commit/b440574df30ba354c1b9d1ee66cd1997208108ed))
* **trivy:** ajouter la version de l'image Trivy à la configuration ([edecf42](https://github.com/vegito-app/example-application/commit/edecf42946aa1b49e9701ab9ccdd588080baeb85))


### Bug Fixes

* **application-main-release:** corriger le dépôt Docker du projet en le remplaçant par example-application ([47f6ff1](https://github.com/vegito-app/example-application/commit/47f6ff1a3c9ef38cdb5336610aa1dfc558b6ecda))
* **application-pipeline:** ajouter le mode de registre Docker aux paramètres de construction ([ebb5729](https://github.com/vegito-app/example-application/commit/ebb5729be4e9ceb29e6a6fa471f8206b01fbaf03))
* **application-pipeline:** corriger la stratégie des tests fonctionnels en utilisant les entrées directement ([efc7366](https://github.com/vegito-app/example-application/commit/efc73664a3488181fd65d013f46d5175aba42d49))
* **build:** correct image naming and set default env values ([8a19514](https://github.com/vegito-app/example-application/commit/8a195145affb6dcabfa7f5bc0e23de55d3f91844))
* **build:** mettre à jour les variables d'image Docker pour la cohérence et la clarté ([7e3fa21](https://github.com/vegito-app/example-application/commit/7e3fa21576301af599df6b34d357d37f1358b433))
* **devcontainer:** corriger les variables d'environnement pour l'installation des conteneurs Android Studio et Clarinet ([a97dbe8](https://github.com/vegito-app/example-application/commit/a97dbe8baae809056136c08e85cb76cbe898cac0))
* **docker-bake, local.mk, local/docker-bake.hcl:** mettre à jour la version des images Docker à v0.0.3 et ajuster les contextes d'image ([a540fd8](https://github.com/vegito-app/example-application/commit/a540fd8ec1836210de6b6515f335e37184f29339))
* **docker-bake.hcl:** améliorer la gestion des images Docker et des contextes pour les applications mobile et tests ([e8073c9](https://github.com/vegito-app/example-application/commit/e8073c95a5d3428a909717ebab1ba519b035e4ce))
* **docker-bake:** mettre à jour la version par défaut des images Docker à "latest" ([122e13a](https://github.com/vegito-app/example-application/commit/122e13a764272dab045712cd7ef3dba151b93af4))
* **docker-bake:** supprimer la référence au cache d'image Flutter dans la cible locale Android Studio ([193a2a3](https://github.com/vegito-app/example-application/commit/193a2a37b2c9cd5dd8507fb3bdadf604d33cacec))
* **docker:** corriger les variables d'image et améliorer la gestion des conteneurs dans docker-compose ([f84e347](https://github.com/vegito-app/example-application/commit/f84e347d5bd43ef85b485d9b7409567148abb3d8))
* **docker:** refactor Dockerfile and docker-bake.hcl for improved cache management and variable consistency ([a07011d](https://github.com/vegito-app/example-application/commit/a07011d788d856f81e2908899f743b897e14fd15))
* **docker:** update image base references to use VEGITO_DOCKER_PUBLIC_REPOSITORY ([45a1382](https://github.com/vegito-app/example-application/commit/45a1382a3c405cecd8c964924a19715b17d84d97))
* **docker:** update user configuration and context references in Dockerfiles ([6f372da](https://github.com/vegito-app/example-application/commit/6f372da87d251d52870e963a96c3874af63982e2))
* **dotenv:** améliorer la configuration des services Docker pour la gestion GPU ([c56430d](https://github.com/vegito-app/example-application/commit/c56430d2aba6c92a87920c0ecd8787522856f305))
* **dotenv:** corriger la création du fichier docker-compose-gpu-override en supprimant la ligne de service inutile ([375160e](https://github.com/vegito-app/example-application/commit/375160e42595daacb031740347a51034277b14c9))
* **dotenv:** remplacer VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME par LOCAL_DOCKER_PUBLIC_IMAGES_BASE_NAME dans les images Docker ([16422c7](https://github.com/vegito-app/example-application/commit/16422c76f9016a12c3910a3c69327ab85d2e6bf4))
* **example-application.mk:** remplacer la commande --push par --load pour la configuration des images Docker ([27581c4](https://github.com/vegito-app/example-application/commit/27581c4180efc1fad4b7af874d287402aa2a7acc))
* **go.mod, go.mk:** mettre à jour la version de Go et les dépendances ([add8eda](https://github.com/vegito-app/example-application/commit/add8eda04cb3fd44415507ddb0cd7551b4ab2ed6))
* **go:** mettre à jour les versions de Go et des dépendances dans go.mod et go.mk ([4113c3c](https://github.com/vegito-app/example-application/commit/4113c3c740129f162281742ecaef49c2ffb36dee))
* **local.mk, robotframework.mk:** mettre à jour la version locale à v1.25.0 et corriger la référence de l'image robotframework ([565ec29](https://github.com/vegito-app/example-application/commit/565ec29424bb21c27cc4ea715474fe75314395e6))
* **local.mk:** ajouter la version de l'image Trivy pour l'environnement de développement local ([0f46b42](https://github.com/vegito-app/example-application/commit/0f46b42d270e360d9e81019964a09c249b6b2a2c))
* **local.mk:** corriger la version de l'image robotframework pour la cohérence ([6dc1ed3](https://github.com/vegito-app/example-application/commit/6dc1ed3fa5422325ce9e9c041eae64fb7b7ead29))
* **local.mk:** mettre à jour la version locale à v1.24.0 ([f075dde](https://github.com/vegito-app/example-application/commit/f075dde5676095df55c0234256ab53d9c6bc633a))
* **local.mk:** supprimer la version de l'image robotframework pour la cohérence ([dfc4ce7](https://github.com/vegito-app/example-application/commit/dfc4ce7234773d1f70c352908d7192ddcc0ea3f1))
* **Makefile:** corriger l'assignation de GIT_HEAD_VERSION pour une meilleure cohérence ([dce3259](https://github.com/vegito-app/example-application/commit/dce3259df3a88786e279285dca08c986d5b1d33e))
* **makefiles:** adjust include directives for local.mk and docker.mk ([f1e2481](https://github.com/vegito-app/example-application/commit/f1e2481050da6a4b3fb22be40425d7b6a904459b))
* **makefiles:** exporter les variables d'environnement pour une meilleure intégration et mise à jour des dépendances ([d5aba51](https://github.com/vegito-app/example-application/commit/d5aba515bdf7fdc5570aed2813bd4e523ea4e7bb))
* **makefiles:** update image base name to use VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME ([ca90ff9](https://github.com/vegito-app/example-application/commit/ca90ff986c25e710946b9d79e6b707c074197ceb))
* **pipeline:** mettre à jour les workflows vers la version 1.27.0 pour la cohérence ([00a28e0](https://github.com/vegito-app/example-application/commit/00a28e0844ccf5f04c89fb56fb747c190cd90da8))
* **pubspec:** mettre à jour les versions des dépendances et les checksums dans pubspec.lock ([443944b](https://github.com/vegito-app/example-application/commit/443944ba7870f3d2ad1528e5224a263e15f0b745))
* **robotframework.mk:** corriger la version de l'image robotframework pour utiliser LOCAL_VERSION ([9b6ae3c](https://github.com/vegito-app/example-application/commit/9b6ae3cf1c603291a6d272cccc7b4cc4557858b6))
* **workflows, local.mk:** mettre à jour les versions des workflows et de l'environnement local à v1.26.0 et v0.0.3 respectivement ([8ab9c3b](https://github.com/vegito-app/example-application/commit/8ab9c3bca975f7fbebfb646326a2c67426a142c0))
* **workflows:** mettre à jour les références des workflows à la version v1.24.0 ([04ee2f4](https://github.com/vegito-app/example-application/commit/04ee2f492e66db21effd2c81fabbed59b7bc6d3d))
* **workflows:** mettre à jour les versions des workflows à v1.24.0 ([f544652](https://github.com/vegito-app/example-application/commit/f5446525dbfbc5a40d62276d66c521d6d1ccbaba))
* **workflows:** remove build-staging-prod job and add Docker Hub credentials ([fe0dbf7](https://github.com/vegito-app/example-application/commit/fe0dbf7c31d028827b4b03d878434b24c4e04fa3))

### [1.7.2](https://github.com/vegito-app/example-application/compare/v1.7.1...v1.7.2) (2026-04-07)


### Bug Fixes

* **docker:** ensure permissions and directory creation for Go cache ([f49ec7b](https://github.com/vegito-app/example-application/commit/f49ec7bb86cd690012c5816a47a0ca80d5112260))
* **security:** patch CVE-2026-34986 in go-jose (DoS via JWE panic) ([08927e5](https://github.com/vegito-app/example-application/commit/08927e5296617b37f1d3c61120a3d429810cb446))

### [1.7.1](https://github.com/vegito-app/example-application/compare/v1.7.0...v1.7.1) (2026-04-03)

## [1.7.0](https://github.com/vegito-app/example-application/compare/v1.6.1...v1.7.0) (2026-04-03)


### Features

* **build-system:** support server-side rendering with updated build path ([a39aa3f](https://github.com/vegito-app/example-application/commit/a39aa3f6411c886857bf44cd62152704e059d830))


### Bug Fixes

* **tests-build:** update Robot Framework context variable names ([a8fe8fc](https://github.com/vegito-app/example-application/commit/a8fe8fc5bd1c87623bb3eaf105f74434da41d9bf))

### [1.6.1](https://github.com/vegito-app/example-application/compare/v1.6.0...v1.6.1) (2026-03-31)

## [1.6.0](https://github.com/vegito-app/example-application/compare/v1.5.0...v1.6.0) (2026-03-31)


### Features

* **docker-bake:** add CI target group and rename groups for clarity ([f9f6a92](https://github.com/vegito-app/example-application/commit/f9f6a92433383ed9a8ab9c16aae4204ac4dfb65f))

## [1.5.0](https://github.com/vegito-app/example-application/compare/v1.4.2...v1.5.0) (2026-03-28)

### Features

- **build:** introduce Docker configuration for example-application ([1f9e12f](https://github.com/vegito-app/example-application/commit/1f9e12f99c60309fc961529cef9254592989ab3c))
- **devcontainer:** enhance dev setup with new Docker and environment configs ([f421401](https://github.com/vegito-app/example-application/commit/f4214019812ab5f450bada34d0eea519e7b5037e))
- **dotenv:** add KVM group ID environment variable ([d85fbd7](https://github.com/vegito-app/example-application/commit/d85fbd7bf39fd5c22717d84a0d728495b195dc84))

### Bug Fixes

- **ci:** correct use_registry_cache condition in release workflow ([88f6779](https://github.com/vegito-app/example-application/commit/88f6779a7aca760a719578700e6e77eed58c7942))
- **docker:** remove redundant DBus volume from docker-compose ([a56d491](https://github.com/vegito-app/example-application/commit/a56d491488a774b4fefb0ff34de198bed2766b02))
- **workflow:** correct secrets reference for release reader ([7f06f70](https://github.com/vegito-app/example-application/commit/7f06f70ff3fd41f1a49bec2a647c99958aaed4e7))
- **workflow:** update paths for functional_tests_dir and android_release_keystore_path ([ce253ed](https://github.com/vegito-app/example-application/commit/ce253ed98f046c451e61d98353bbf318dfe6e199))

## [1.4.0](https://github.com/vegito-app/example-application/compare/v1.3.0...v1.4.0) (2025-11-03)

### Features

- **ci:** add target list printout for docker images ([b14baf4](https://github.com/vegito-app/example-application/commit/b14baf43a1016ef26db8d493ec56ec6c132abd7d))

## [1.2.0](https://github.com/vegito-app/example-application/compare/v1.1.2...v1.2.0) (2025-10-31)

### Features

- **ci/docker:** enhance documentation and add Makefile targets for Docker tag listing ([bf1e030](https://github.com/vegito-app/example-application/commit/bf1e03052a8fa91f18c0187b9fb0c80660fc1d68))

### [1.1.1](https://github.com/vegito-app/example-application/compare/v1.1.0...v1.1.1) (2025-10-31)

## 1.1.0 (2025-10-30)

### Features

- **devcontainer:** add comprehensive devcontainer setup ([de22259](https://github.com/vegito-app/example-application/commit/de22259dff954cbd2f80e839c1ce5f5104b8d948))
- **makefiles:** enhance container management and introduce timeouts ([0a1665c](https://github.com/vegito-app/example-application/commit/0a1665c29f55ced3e99bac89734ccb19bd36fe60))
- **tests:** establish end-to-end testing infrastructure ([313be8c](https://github.com/vegito-app/example-application/commit/313be8c4a42cd869aa883a712e3576b5f62843ad))
- **workflows:** add GitHub Actions for dev, feature, and release processes ([fe5f3d8](https://github.com/vegito-app/example-application/commit/fe5f3d86d58e84241c0f607904ef78e999e0d033))
