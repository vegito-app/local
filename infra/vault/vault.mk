VAULT_GCLOUD_CLUSTER_NAME=vault-cluster

vault-gcloud-cluster-get-credentials:
	@$(GCLOUD) containers get-credentials $(VAULT_GCLOUD_CLUSTER_NAME) --location $(GOOGLE_CLOUD_REGION)
.PHONY: vault-gcloud-cluster-get-credentials

HELM_VAULT = helm --namespace vault

vault-helm-uninstall-release-destroy:
	-$(HELM_VAULT) uninstall vault-helm
	-$(TERRAFORM) state rm module.vault.helm_release.vault
.PHONY: vault-helm-uninstall-release-destroy

HELM_VAULT_CHART_VERSION = 0.30.0

vault-helm-chart-pull:
	-$(HELM_VAULT) repo add hashicorp https://helm.releases.hashicorp.com
	-$(HELM_VAULT) repo update
	-$(HELM_VAULT) pull hashicorp/vault --version $(HELM_VAULT_CHART_VERSION) --untar
.PHONY: vault-helm-chart-pull

VAULT_HELM_GCLOUD_SERVICEACCOUNT_EMAIL = vault-sa@$(GOOGLE_CLOUD_PROJECT_ID).iam.gserviceaccount.com

vault-helm-serviceaccount-get-iam-policy:
	-$(GCLOUD) iam service-accounts get-iam-policy $(VAULT_HELM_GCLOUD_SERVICEACCOUNT_EMAIL)
.PHONY: vault-helm-serviceaccount-get-iam-policy

KUBECTL_VAULT = kubectl --namespace vault

vault-helm-pods-delete:
	-$(KUBECTL_VAULT) delete pod -l app.kubernetes.io/name=vault
	-$(KUBECTL_VAULT) delete job vault-init-job
.PHONY: vault-helm-pods-delete

vault-helm-rollout-restart:
	$(KUBECTL_VAULT) rollout restart statefulset vault-helm
.PHONY: vault-helm-rollout-restart

consul-helm-rollout-restart:
	$(KUBECTL_VAULT) rollout restart statefulset consul-helm-consul-server
.PHONY: consul-helm-rollout-restart

vault-gcloud-cluster-get-jobs:
	$(KUBECTL_VAULT) get jobs
.PHONY: vault-gcloud-cluster-get-jobs

vault-gcloud-cluster-reset-init-job:
	$(KUBECTL_VAULT) delete job vault-init-job
.PHONY: vault-gcloud-cluster-reset-init-job

vault-gke-cluster-init:
	@$(KUBECTL_VAULT) delete job vault-init-job || true
	@$(TERRAFORM) apply -target=module.vault.kubernetes_job.vault_init -auto-approve
	@$(MAKE) vault-rollout-restart
.PHONY: vault-gke-cluster-init

VAULT_INIT_SECRET_JSON = $(CURDIR)/infra/vault/vault-init.json

VAULT_ADDR ?= localhost:8200

vault-helm-operator-init: $(VAULT_INIT_SECRET_JSON)
	vault operator unseal $(jq -r .unseal_keys_b64[0] vault-init.json)
	vault operator unseal $(jq -r .unseal_keys_b64[1] vault-init.json)
	vault operator unseal $(jq -r .unseal_keys_b64[2] vault-init.json)
.PHONY: vault-helm-operator-init

$(VAULT_INIT_SECRET_JSON):
	@echo "Vault root secrets generation: '$@'"
	@vault operator init -key-shares=5 -key-threshold=3 > $(VAULT_INIT_SECRET_JSON)spl