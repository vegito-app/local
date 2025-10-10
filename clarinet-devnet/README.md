# Clarinet Devnet – Environnement de développement Stacks & Clarity

Ce dossier contient un environnement complet basé sur Docker permettant le développement, le test et le déploiement de smart contracts en Clarity sur un **devnet local Stacks**.

## 📦 Conteneurs inclus

Voici les principaux services qui composent le devnet local :

| Service                | Description                                      | Port(s) exposé(s)             |
|------------------------|--------------------------------------------------|-------------------------------|
| `stacks-node`          | Nœud Stacks Devnet (blockchain locale)           | 20443-20444                   |
| `stacks-api`           | API REST Stacks                                  | 3999                          |
| `stacks-explorer`      | Interface web de visualisation de la blockchain  | 8000                          |
| `bitcoin-node`         | Nœud Bitcoin simulé utilisé par Stacks           | 18443-18444                   |
| `bitcoin-explorer`     | Interface web de la blockchain Bitcoin simulée   | 8001                          |
| `postgres`             | Base de données utilisée par `stacks-api`        | 5432                          |
| `stacks-signer`        | Génère les blocs pour le devnet                  | -                             |

> Ces services sont définis et lancés via `docker-compose` ou via un conteneur `clarinet` supervisant l'ensemble.

---

## 🚀 Utilisation

### 1. Lancer l’environnement

```bash
docker compose up -d
```

Ou via le conteneur `clarinet` si déjà lancé dans l'environnement.

### 2. Accéder aux interfaces

- **Stacks Explorer** : [http://localhost:8000](http://localhost:8000)
- **Bitcoin Explorer** : [http://localhost:8001](http://localhost:8001)
- **Stacks API** : [http://localhost:3999](http://localhost:3999)

### 3. Déployer un contrat Clarity

Depuis le conteneur `clarinet` :

```bash
clarinet integrate
```

Ou, avec `@stacks/cli` ou `@stacks/transactions`, depuis un script local :

```bash
stx contract deploy \
  --contract-name mon-contrat \
  --code-file ./contracts/mon-contrat.clar \
  --sender ST12... \
  --private-key 0x... \
  --rpc-url http://localhost:20443
```

> Utilise le faucet local ou l'explorer pour créditer ton wallet STX.

---

## 🧪 Tests

Tu peux lancer des tests unitaires Clarity avec :

```bash
clarinet test
```

Et des tests sur le réseau local avec :

```bash
clarinet integrate test
```

---

## 🔍 Astuces & Débogage

- **Voir les logs** :

```bash
docker logs stacks-node.counter.devnet -f
```

- **PSQL (base de données)** :

```bash
psql -h localhost -p 5432 -U postgres
```

---

## 🔐 Objectif à terme

L’objectif de cet environnement est de :

- Développer des smart contracts Clarity
- Gérer le déploiement sur le devnet Stacks
- Débloquer des transferts conditionnels via smart contract
- Permettre à un wallet d’interagir avec ces contrats, recevoir des tokens, etc.

Un example complet de déploiement automatisé (TypeScript + @stacks/transactions) sera bientôt ajouté.

---

## 📁 Arborescence (à compléter)

```
clarinet/
├── contracts/
│   └── mon-contrat.clar
├── settings/
│   └── Devnet.toml
├── README.md
```

---

## 🔗 Références utiles

- [Stacks Docs](https://docs.stacks.co/)
- [Clarity Book](https://book.clarity-lang.org)
- [Clarinet](https://docs.hiro.so/clarinet/overview)
- [Stacks.js](https://stacks.js.org)
