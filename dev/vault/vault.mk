VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE=$(CURDIR)/dev/.containers/docker-buildx-cache/vault-dev
$(VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE):;	@mkdir -p "$@"
ifneq ($(wildcard $(VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)/index.json),)
VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ = type=local,src=$(VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)
endif
VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE= type=local,dest=$(VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)

vault-dev-image: docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print vault-dev
	@$(DOCKER_BUILDX_BAKE) --load vault-dev
.PHONY: vault-dev-image

vault-dev-image-push: docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print vault-dev
	@$(DOCKER_BUILDX_BAKE) --push vault-dev
.PHONY: vault-dev-image-push

vault-dev-image-ci: docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print vault-dev
	@$(DOCKER_BUILDX_BAKE) --push vault-dev-ci
.PHONY: vault-dev-image-ci

vault-dev-docker-compose-up: vault-dev-docker-compose-rm
	@VERSION=latest $(CURDIR)/dev/vault/docker-compose-up.sh &
	@$(DOCKER_COMPOSE) logs vault-dev
	@echo
	@echo Started Androïd studio display: 
	@echo Run "'make $(@:%-up=%-logs)'" to retrieve more logs
.PHONY: vault-dev-docker-compose-up
