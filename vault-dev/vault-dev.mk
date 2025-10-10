LOCAL_VAULT_DEV_IMAGE_VERSION ?= $(VEGITO_LOCAL_PUBLIC_IMAGES_BASE):vault-dev-$(VERSION)

LOCAL_VAULT_DEV_DIR ?= $(LOCAL_DIR)/vault-dev

local-vault-dev-container-up: local-vault-dev-container-rm
	@VERSION=latest $(LOCAL_VAULT_DEV_DIR)/docker-compose-up.sh &
	@$(LOCAL_DOCKER_COMPOSE) logs vault-dev
	@echo
	@echo Started Androïd studio display: 
	@echo Run "'make $(@:%-up=%-logs)'" to retrieve more logs
.PHONY: local-vault-dev-container-up
