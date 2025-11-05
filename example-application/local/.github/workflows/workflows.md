# 🌱 Vegito CI/CD Workflow Template – `main-release-template.yml`

Ce fichier décrit le fonctionnement et les possibilités de réutilisation du workflow GitHub Actions `main-release-template.yml` présent dans ce dépôt.

---

## 🔁 Réutilisation du Workflow

Le workflow `main-release-template.yml` a été conçu pour être **réutilisé par tous les dépôts de l'organisation `vegito-app`**, et notamment ceux disposant :

- d'un Makefile compatible (`build-release-images`, `extract-release-artifacts`, etc.)
- d'un projet backend (Go, Cloud Run)
- d'un projet mobile (Flutter, Android)
- d'une logique de tagging (`standard-version`) et de publication

### 📦 Exemple d'utilisation dans un dépôt externe :

```yaml
# .github/workflows/deploy.yml
name: Reuse Vegito Release Workflow

on:
  push:
    branches: [main]

jobs:
  ci:
    uses: vegito-app/local/.github/workflows/main-release-template.yml@main
    with:
      environment: dev
    secrets:
      GOOGLE_CLOUD_PROJECT_ID: ${{ secrets.GOOGLE_CLOUD_PROJECT_ID }}
      GOOGLE_CLOUD_PROJECT_NUMBER: ${{ secrets.GOOGLE_CLOUD_PROJECT_NUMBER }}
      ANDROID_RELEASE_KEYSTORE: ${{ secrets.ANDROID_RELEASE_KEYSTORE }}
      ANDROID_RELEASE_KEYSTORE_STORE_PASS: ${{ secrets.ANDROID_RELEASE_KEYSTORE_STORE_PASS }}
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

⸻

### 🚀 Fonctionnement Général

Le workflow est structuré autour des étapes suivantes :

    1. 🐳 Build des images Docker multi-env
    2. 📱 Extraction d’artefacts Android (APK, AAB)
    3. 📝 Génération automatique de changelog (CHANGELOG.md)
    4. 🏷️ Création d’une release GitHub incluant les artefacts
    5. ☁️ Publication des métadonnées sur Google Cloud Storage (GCS)
    6. 🧼 Nettoyage des conteneurs et environnements temporaires

Chaque environnement (dev, staging, prod) utilise ses propres secrets et configurations injectées automatiquement.

⸻

### 🔎 Accès aux Releases publiées

Les versions publiées, leurs artefacts, les changelogs, les APK et les tags Docker sont disponibles sur la page publique :

🔗 https://release.vegito.app

Cette page est générée à partir des fichiers index.json et metadata.json poussés dans GCS par ce workflow.
