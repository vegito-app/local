LOCAL_VAULT_DEV_DIR ?= $(LOCAL_DIR)/vault-dev
LOCAL_VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE ?= $(LOCAL_VAULT_DEV_DIR)/.containers/docker-buildx-cache/vault-dev
$(LOCAL_VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE):;	@mkdir -p "$@"
ifneq ($(wildcard $(LOCAL_VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)/index.json),)
LOCAL_VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ = type=local,src=$(LOCAL_VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)
endif
LOCAL_VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE= type=local,mode=max,dest=$(LOCAL_VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)

local-vault-dev-container-up: local-vault-dev-container-rm
	@LOCAL_VERSION=latest $(LOCAL_VAULT_DEV_DIR)/docker-compose-up.sh &
	@$(LOCAL_DOCKER_COMPOSE) logs vault-dev
	@echo
	@echo Started Androïd studio display: 
	@echo Run "'make $(@:%-up=%-logs)'" to retrieve more logs
.PHONY: local-vault-dev-container-up
