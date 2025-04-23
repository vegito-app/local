# Vault - Intégration Kubernetes + Consul + Terraform

## Sommaire

- [Aperçu général](#aperçu-général)
- [Architecture technique](#architecture-technique)
- [Fonctionnement de l'injection de secrets](#fonctionnement-de-linjection-de-secrets)
- [Développement local](#développement-local)
- [État PoC vs Production](#état-poc-vs-production)
- [Checklist recommandations production](#checklist-recommandations-production)

### Aperçu général

- Présentation de l'intégration de Vault avec Kubernetes et Consul.
- Utilisation d'un Agent Sidecar pour l'injection de secrets.
- Helm utilisé pour le déploiement avec valeurs personnalisées.
- Intégration Terraform pour créer les rôles Vault, policies et ressources GCP nécessaires.

### Architecture technique

- Vault utilise Consul comme backend de stockage (mode HA désactivé pour l’instant).
- Authentification Kubernetes (via ServiceAccounts).
- Auto-unseal configuré avec GCP KMS.
- Les secrets sont récupérés via le mécanisme `template` + `sink` de Vault Agent.
- Terraform gère :
  - IAM GCP
  - Secrets Kubernetes
  - Policies Vault
  - Namespace
  - Helm Chart Vault

### Fonctionnement de l'injection de secrets

- Utilisation d’un sidecar Vault Agent pour injecter dynamiquement les secrets dans les conteneurs.
- Tests en cours : injection dynamique du fichier `firebase.json` dans le backend Go.

### Développement local

- Devcontainer utilisé pour garantir la reproductibilité des tests.
- Vault peut être lancé localement avec les mêmes configs que sur GKE.

### Connexion manuelle à Vault en local (mode développeur)

Si vous utilisez Terraform en local, vous pouvez contourner l'auth GCP automatique du provider Vault (auth_login) en utilisant un script local :

```bash
$ make production-vault-login-local
```

Cela :

- Génère un JWT signé avec un TTL court
- Authentifie ce JWT contre Vault
- Récupère un `VAULT_TOKEN`
- L’exporte dans l’environnement

Cela permet d’utiliser Terraform avec un provider Vault sans modifier le bloc `auth_login`.

### Accés local au cluster (production)

Use cluster from local access

1 local port forward : `make production-vault-kubectl-port-forward`

```
$ make production-vault-kubectl-port-forward
kubectl --namespace vault port-forward -n vault svc/vault-helm 8210:8200 8211:8201
Forwarding from 127.0.0.1:8210 -> 8200
Forwarding from [::1]:8210 -> 8200
Forwarding from 127.0.0.1:8211 -> 8201
Forwarding from [::1]:8211 -> 8201
Handling connection for 8210
Handling connection for 8210
Handling connection for 8210
Handling connection for 8210
Handling connection for 8210
```

2 retrieve cluster configuration `make production-vault-kubernetes-cluster-get-credentials`

```
$ make production-vault-kubernetes-cluster-get-credentials
Fetching cluster endpoint and auth data.
kubeconfig entry generated for vault-cluster.
```

3 terraform plan: `make production-vault-terraform-plan`

4 terraform apply: `make production-vault-terraform-apply-auto-approve`

### État PoC vs Production

**Pour un PoC :** ✅ Suffisant.

**Pour une Prod :** 🔧 Quelques points à renforcer.

| Risque                                 | Détail                                                                                      |
| -------------------------------------- | ------------------------------------------------------------------------------------------- |
| 🔓 Accès `kubectl exec`                | Toute personne avec ce droit + `cluster-admin` + accès au SA GCP peut exfiltrer les secrets |
| 🔐 Clés GCP montées dans tous les pods | Normal pour l’auto-unseal, mais à protéger strictement (0400, `readOnly`)                   |
| 📦 Pas de rotation des root tokens     | Après `vault operator init`, il faut gérer les clés et tokens avec rigueur                  |

### Checklist recommandations production

| Étape                         | Description                                                            |
| ----------------------------- | ---------------------------------------------------------------------- |
| 🛑 Restreindre `kubectl exec` | Supprimer les droits `exec` hors ops. Utiliser des RoleBindings précis |
| 🔒 Gestion clés sensibles     | Passer par Secret Manager ou init container à durée de vie courte      |
| 🧪 Tests de santé             | Liveness/readiness probes + `vault status` automatisé                  |

# Contenu du script vault_login_local.sh

# Ajout de la cible Makefile dans vault.mk

```make
production-vault-login-local:
	./infra/environments/prod/vault/vault_login_local.sh
.PHONY: production-vault-login-local
```

```bash
chmod +x infra/environments/prod/vault/vault_login_local.sh
```
