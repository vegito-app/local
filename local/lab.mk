VEGITO_DOCKER_LAB_REGISTRIES ?= public private cache 

vegito-docker-lab-login: $(VEGITO_DOCKER_LAB_REGISTRIES:%=vegito-lab-%-docker-login)
.PHONY: vegito-docker-lab-login

$(VEGITO_DOCKER_LAB_REGISTRIES:%=vegito-lab-%-docker-login):
	@echo "Logging into Vegito lab '$(@:vegito-lab-%-docker-login=%)' Docker registry internally not required"
#	@printf '%s' "$$VEGITO_LAB_REGISTRY_PASSWORD" | docker login registry-$(@:vegito-lab-%-docker-login=%).vegito.app \
	  --username "$$VEGITO_LAB_REGISTRY_USERNAME" \
	  --password-stdin
.PHONY: $(VEGITO_DOCKER_LAB_REGISTRIES:%=vegito-lab-%-docker-login)

VEGITO_DOCKER_LAB_REGISTRY_PUBLIC ?= registry-public.vegito.app
VEGITO_DOCKER_LAB_REGISTRY_PRIVATE ?= registry-private.vegito.app
VEGITO_DOCKER_LAB_REGISTRY_CACHE ?= registry-cache.vegito.app

vegito-docker-lab-images-release: vegito-docker-images-release
.PHONY: vegito-docker-lab-images-release

vegito-docker-lab-images-release-ci: vegito-docker-images-release-ci
.PHONY: vegito-docker-lab-images-release-ci