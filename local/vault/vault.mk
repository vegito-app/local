VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE=$(CURDIR)/local/.containers/docker-buildx-cache/vault-dev
$(VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE):;	@mkdir -p "$@"
ifneq ($(wildcard $(VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)/index.json),)
VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ = type=local,src=$(VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)
endif
VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE= type=local,dest=$(VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)

local-vault-docker-compose-up: local-vault-docker-compose-rm
	@VERSION=latest $(CURDIR)/local/vault/docker-compose-up.sh &
	@$(DOCKER_COMPOSE) logs vault-dev
	@echo
	@echo Started Androïd studio display: 
	@echo Run "'make $(@:%-up=%-logs)'" to retrieve more logs
.PHONY: local-vault-docker-compose-up
