


# 📦 Vegito Local

Ce répertoire contient le socle commun de développement local et CI/CD pour les projets Vegito.

## Objectif

Permettre à n'importe quel dépôt de :

- disposer d'un environnement local reproductible (via `devcontainer`),
- automatiser les tâches (via Makefile),
- mutualiser les workflows CI/CD (via `.github/workflows`),
- gérer les services locaux (Firebase emulators, Vault dev, Clarinet, etc.).

## Intégration via Git Subtree

Ce dossier peut être intégré dans n’importe quel projet comme sous-arbre Git :

```bash
git subtree add --prefix local https://github.com/vegito-app/local main
```

## Commandes disponibles

```bash
make dev                # Démarre l’environnement local complet
make test               # Lance les tests
make build              # Construit les binaires/app
make firebase-emulators  # Démarre Firebase local
```

## CI/CD

Les workflows utilisent les makefiles locaux pour standardiser les étapes de build, test, déploiement.

## Convention

Le dépôt parent doit définir :

- un `Makefile` racine déléguant vers `local/`,
- une structure de projet cohérente (`mobile/`, `backend/`, etc.),
- les secrets GitHub nécessaires au workflow (keystore, WIF GCP…).

---

🔁 Ce module est réutilisable dans tous les projets conformes à Vegito.