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
