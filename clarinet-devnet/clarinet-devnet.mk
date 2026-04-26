LOCAL_CLARINET_DEVNET_DIR ?= $(LOCAL_DIR)/clarinet-devnet

LOCAL_CLARINET_DEVNET_IMAGE_VERSION ?= $(VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME):clarinet-$(VERSION)

CONTRACTS := \
  my-first-contract \
  counter \
  order
  
BITCOIND_DOCKER_NETWORK_NAME = my-first-contract.devnet
BITCOIND_DOCKER_CONTAINER_NAME = bitcoin-node.$(BITCOIND_DOCKER_NETWORK_NAME)

LOCAL_CLARITY_CONTRACTS_DIR   = $(LOCAL_DIR)/example-application/contracts
LOCAL_CLARITY_CONTRACTS_DEPLOYMENT_DIR = $(LOCAL_CLARITY_CONTRACTS_DIR)/deployment
LOCAL_CLARINET       = clarinet 

local-clarinet-check: ## Vérifie la validité des contrats
	@echo "🔍 Vérification des contrats Clarity..."
	@for contract in $(LOCAL_CLARITY_CONTRACTS_DIR)/*.clar; do \
		$(LOCAL_CLARINET) check $$contract || exit 1; \
	done
	@echo "✅ Tous les contrats sont valides."
.PHONY: local-clarinet-check 

local-clarinet-deploy-devnet: ## Déploie les contrats sur le Devnet
	@echo "🚀 Déploiement sur le Devnet..."
	@clarity-cli deploy --config $(LOCAL_CLARITY_CONTRACTS_DEPLOYMENT_DIR)/devnet.yaml
	@echo "✅ Déploiement terminé sur le Devnet."
.PHONY: local-clarinet-deploy-devnet 

local-clarinet-deploy-staging: ## Déploie les contrats sur le Staging
	@echo "🚀 Déploiement sur Staging..."
	@clarity-cli deploy --config $(LOCAL_CLARITY_CONTRACTS_DEPLOYMENT_DIR)/staging.yaml
	@echo "✅ Déploiement terminé sur Staging."
.PHONY: local-clarinet-deploy-staging 

local-clarinet-clean: ## Supprime les artefacts générés
	@echo "🧹 Nettoyage..."
	@rm -f $(LOCAL_CLARITY_CONTRACTS_DIR)/*.wasm
	@echo "✅ Nettoyage terminé."
.PHONY: local-clarinet-clean 

local-clarinet-devnet-start:
	@-docker rm -f `docker ps -aq --filter name=devnet` 2>/dev/null
	@-docker network rm -f `docker network ls -q --filter name=devnet` 2>/dev/null
	@cd $(LOCAL_CLARINET_DEVNET_DIR) && clarinet devnet start --no-dashboard
.PHONY: local-clarinet-devnet-start

local-clarinet-devnet-container-up: local-clarinet-devnet-container-rm
	@echo "🚀 Starting container Clarinet Devnet..."
	@$(LOCAL_CLARINET_DEVNET_DIR)/container-up.sh
.PHONY: local-clarinet-devnet-container-up