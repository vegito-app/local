# CAR2GO

CAR2GO est fait pour proposer un service de déplacement par véhicule.

### Build project images

The project is making use of your existing GOOGLE_APPLICATION_CREDENTIALS for authentication.
The values used by defauls can be configured if required.

#### Locally

Build project service images for the local machine architecture only.

```
    make images
```

Project have images for:

- **builder**: contains project tools (`gcloud`, `terraform`, `flutter`, ...). See [local/builder.Dockerfile](local/builder.Dockerfile).
- **backend**: minified image with only application and _application-backend_ web server. See [application/backend/Dockerfile](application/backend/Dockerfile).
- **github action runner**: used to provide Github Action Workflow local hosted-runners. See [infra/github/Dockerfile](infra/github/Dockerfile).

#### CI - Github Actions worflows

Build and push multi-architecture project images.

```
    make images-ci
```

Pipeline which runs this target is available under the Github project repository Actions section at https://github.com/7d4b9/refactored-winner/actions.

## Local

Folder `./local/` provides a dedicated development environment to work on this project locally, remotly, in CI...
This _local_ environment is also used by [Devcontainer](https://containers.dev), see locale [.devcontainer/devcontainer.json](.devcontainer/devcontainer.json) file.

Exemple to run the application on the local native machine (no docker):

```bash
# Local Backend run:
$ make local-run
# Application is available at [http://localhost:8080](http://localhost:8080).
```

More local Makefile targets are available to work on the project locally, see [local/local.mk](local/local.mk):

    local-android-studio-docker-compose           local-builder-image                           local-firebase-emulators-functions-serve      local-github-runner-image-ci
    local-android-studio-docker-compose-logs      local-firebase-emulators                      local-firebase-emulators-init                 local-github-runner-token-exist
    local-android-studio-docker-compose-rm        local-firebase-emulators-docker-compose       local-firebase-emulators-install              local-install
    local-android-studio-docker-compose-sh        local-firebase-emulators-docker-compose-bash  local-firebase-emulators-prepare              local-builder-image-ci
    local-android-studio-docker-compose-stop      local-firebase-emulators-docker-compose-logs  local-firebase-emulators-start                local-run
    local-android-studio-docker-compose-up        local-firebase-emulators-docker-compose-rm    local-github-runner-docker-compose-rm
    local-android-studio-image                    local-firebase-emulators-docker-compose-stop  local-github-runner-docker-compose-up
    local-android-studio-image-push               local-firebase-emulators-docker-compose-up    local-github-runner-image

## Infrastructure

Infrastructure is based on google cloud. It is managed _as code_ using the google and google-beta providers with Terraform.

See [infra/infra.mk](infra/infra.mk) for more details on the specific provided Makefile targets to manage the project infrastructure:

    terraform-apply-auto-approve  terraform-destroy
    terraform-import              terraform-init
    terraform-output              terraform-plan
    terraform-providers           terraform-refresh
    terraform-state-backup        terraform-state-list
    terraform-state-rm            terraform-state-show
    terraform-state-show-all      terraform-taint-backend
    terraform-unlock              terraform-upgrade
    terraform-validate

---

There is also a nested `infra/gcloud` specific folder with specific target to use gcloud directly as helper and memo:

    gcloud-admin-developper-utrade-storage-admin           gcloud-images-builder-untag-all-public
    gcloud-apikeys-list                                    gcloud-images-list
    gcloud-auth-default-application-credentials            gcloud-images-list-tags
    gcloud-auth-docker                                     gcloud-images-list-tags-public
    gcloud-auth-func-deploy                                gcloud-infra-auth-npm-install
    gcloud-auth-func-logs                                  gcloud-services-apis-disable
    gcloud-auth-login                                      gcloud-services-apis-enable
    gcloud-backend-image-delete                            gcloud-services-disable-cloudbilling-api
    gcloud-builder-image-delete                            gcloud-services-disable-serviceusage-api
    gcloud-docker-registry-temporary-token                 gcloud-services-enable-cloudbilling-api
    gcloud-firebase-adminsdk-service-account-roles-list     gcloud-services-enable-serviceusage-api
    gcloud-images-builder-untag-all                        gcloud-storage-admin

More details about thos targets: [infra/gcloud/gcloud.mk](infra/gcloud/gcloud.mk)
