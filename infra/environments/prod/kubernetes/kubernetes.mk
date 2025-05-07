PROD_VAULT_GCLOUD_CLUSTER_NAME=vault-cluster

production-vault-kubernetes-cluster-get-credentials:
	@$(GCLOUD) container clusters get-credentials $(PROD_VAULT_GCLOUD_CLUSTER_NAME) --location $(GOOGLE_CLOUD_REGION)
.PHONY: production-vault-kubernetes-cluster-get-credentials

HELM_VAULT = helm --namespace vault

production-vault-uninstall-release-destroy:
	-$(HELM_VAULT) uninstall vault-helm
	-$(TERRAFORM) state rm module.vault.helm_release.vault
.PHONY: production-vault-uninstall-release-destroy

HELM_VAULT_CHART_VERSION = 0.30.0

vault-helm-chart-pull:
	-$(HELM_VAULT) repo add hashicorp https://helm.releases.hashicorp.com
	-$(HELM_VAULT) repo update
	-$(HELM_VAULT) pull hashicorp/vault --version $(HELM_VAULT_CHART_VERSION) --untar
.PHONY: vault-helm-chart-pull

PRODUCTION_VAULT_GKE_SERVICEACCOUNT_EMAIL = vault-sa@$(GOOGLE_CLOUD_PROJECT_ID).iam.gserviceaccount.com

production-vault-gke-serviceaccount-get-iam-policy:
	-$(GCLOUD) iam service-accounts get-iam-policy $(PRODUCTION_VAULT_GKE_SERVICEACCOUNT_EMAIL)
.PHONY: production-vault-gke-serviceaccount-get-iam-policy

production-vault-gke-describe-container-cluster:
	$(GCLOUD) container clusters describe vault-cluster \
	  --region $(GOOGLE_CLOUD_REGION) \
	  --format="yaml(workloadIdentityConfig)"
.PHONY: production-vault-gke-describe-container-cluster

production-vault-gke-describe-container-node-pools:
	$(GCLOUD) container node-pools describe default-pool \
	  --cluster vault-cluster \
	  --region $(GOOGLE_CLOUD_REGION) \
	  --format="yaml(workloadMetadataConfig)"
.PHONY: production-vault-gke-describe-container-cluster

production-vault-gke-update-container-node-pools:
	@echo $(GCLOUD) container node-pools update default-pool \
	  --workload-metadata=GKE_METADATA \
	  --cluster vault-cluster \
	  --region $(GOOGLE_CLOUD_REGION)
.PHONY: production-vault-gke-update-container-node-pools

production-vault-kubernetes-operation-list:
	$(GCLOUD) container operations list \
	  --project=$(GOOGLE_CLOUD_PROJECT_ID) \
	  --filter="targetLink:clusters/vault-cluster" \
	  --limit=1
.PHONY: production-vault-kubernetes-operation-list

VAULT_KEYRING = vault-keyring

production-vault-describe-kms-key:
	@kubectl get secrets -n vault # ← vérifier les clefs auto-unseal s’il y en a
	@gcloud kms keys list --keyring=$(VAULT_KEYRING) --location=global
	@gcloud kms keys describe vault-key --keyring=vault-keyring --location=global
.PHONY: production-vault-describe-kms-key

production-vault-restore-upgrade-kms-key-version:
	@[ ! $$KMS_KEY_VERSION ] && \
	  echo "please set KMS_KEY_VERSION and relaunch, using:" && \
	  echo KMS_KEY_VERSION=\<version\> make $@ && \
	  exit 1 || exit 0
	@echo $(GCLOUD) kms keys versions restore $(KMS_KEY_VERSION) \
	  --location=global \
	  --keyring=$(VAULT_KEYRING) \
	  --key=vault-key
	@echo $(GCLOUD) kms keys versions create \
	  --location=global \
	  --keyring=$(VAULT_KEYRING) \
	  --key=vault-key
	@echo $(GCLOUD) kms keys set-primary-version vault-key \
	  --location=global \
	  --keyring=$(VAULT_KEYRING) \
	  --version=$$(( KMS_KEY_VERSION + 1 ))

CONTAINER_OPERATION_ID ?= operation-1743791003472-67fb3488-cea1-4143-b191-159965f1403b

production-vault-gke-operation-describe:
	$(GCLOUD) container operations describe $(CONTAINER_OPERATION_ID) \
	  --region $(GOOGLE_CLOUD_REGION) \
	  --project=$(GOOGLE_CLOUD_PROJECT_ID)
.PHONY: production-vault-gke-operation-describe

KUBE_CONFIG_PATH ?= ~/.kube/config

KUBECTL_VAULT = kubectl --namespace vault

production-vault-kubectl-port-forward: $(GOOGLE_APPLICATION_CREDENTIALS)
	$(KUBECTL_VAULT) port-forward -n vault svc/vault-helm 8210:8200 8211:8201
.PHONY: production-vault-kubectl-port-forward

production-vault-kubectl-pods-delete:
	@echo $(KUBECTL_VAULT) delete pod -l app.kubernetes.io/name=vault
	@echo $(KUBECTL_VAULT) delete job vault-init-job
.PHONY: production-vault-kubectl-pods-delete

production-vault-kubectl-rollout-restart:
	@echo $(KUBECTL_VAULT) rollout restart statefulset vault-helm
.PHONY: production-vault-kubectl-rollout-restart

production-consul-kubectl-rollout-restart:
	@echo $(KUBECTL_VAULT) rollout restart statefulset consul-helm-consul-server
.PHONY: production-consul-kubectl-rollout-restart

production-vault-kubectl-get-jobs:
	$(KUBECTL_VAULT) get jobs
.PHONY: production-vault-kubectl-get-jobs

production-vault-kubectl-reset-init-job:
	@echo $(KUBECTL_VAULT) delete job vault-init-job
.PHONY: production-vault-kubectl-reset-init-job

production-vault-kubectl-reset-tf-apply-job:
	@echo $(KUBECTL_VAULT) delete job vault-tf-apply
.PHONY: production-vault-kubectl-reset-tf-apply-job

production-vault-kubernetes-init-job:
	@echo $(KUBECTL_VAULT) delete job vault-init-job || true
	@echo $(TERRAFORM) apply -target=module.vault.kubernetes_job.vault_init -auto-approve
	@echo $(MAKE) vault-rollout-restart
.PHONY: production-vault-kubernetes-init-job

production-vault-kubernetes-state-mv:
	$(TERRAFORM) state mv helm_release.consul module.k8s.helm_release.consul
.PHONY: production-vault-kubernetes-state-mv
