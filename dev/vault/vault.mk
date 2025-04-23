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

vault-dev-docker-compose-startvp:
	@-$(DOCKER_COMPOSE) startvp vault-dev 2>/dev/null
.PHONY: vault-dev-docker-compose-startvp

vault-dev-docker-compose-stop:
	@-$(DOCKER_COMPOSE) stop vault-dev 2>/dev/null
.PHONY: vault-dev-docker-compose-stop

vault-dev-docker-compose-rm: vault-dev-docker-compose-stop
	@$(DOCKER_COMPOSE) rm -f vault-dev
.PHONY: vault-dev-docker-compose-rm

vault-dev-docker-compose-logs:
	@$(DOCKER_COMPOSE) logs --follow vault-dev
.PHONY: vault-dev-docker-compose-logs

vault-dev-audit-logs:
	@$(DOCKER_COMPOSE) exec vault-dev tail -f /vault/audit/audit-logs.json | jq
.PHONY: vault-dev-audit-logs

vault-dev-docker-compose-sh:
	@$(DOCKER_COMPOSE) exec -it vault-dev bash
.PHONY: vault-dev-docker-compose-sh
