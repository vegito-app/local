# 🌱 Vegito CI/CD Workflow Template – `main-release-template.yml`

This document describes how the `main-release-template.yml` GitHub Actions workflow works and how it can be reused across repositories.

---

## 🔁 Workflow Reusability

The `main-release-template.yml` workflow is designed to be **reused across all repositories in the `vegito-app` organization**, especially those that include:

- a compatible Makefile (`build-release-images`, `extract-release-artifacts`, etc.)
- a backend project (Go, Cloud Run)
- a mobile project (Flutter, Android)
- a release/tagging logic (`standard-version` or equivalent)

### 📦 Example usage in an external repository:

```yml
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

---

## 🚀 General Workflow Overview

The workflow is structured around the following steps:

1. 🐳 Build multi-environment Docker images
2. 📱 Extract Android artifacts (APK, AAB)
3. 📝 Automatically generate changelog (`CHANGELOG.md`)
4. 🏷️ Create a GitHub release including artifacts
5. ☁️ Publish metadata to Google Cloud Storage (GCS)
6. 🧼 Cleanup temporary containers and environments

Each environment (dev, staging, prod) uses its own configuration and secrets.

---

## 🔎 Access to Published Releases

Published versions, artifacts, changelogs, APKs, and Docker tags are available at:

🔗 https://release.vegito.app

This page is generated from `index.json` and `metadata.json` files pushed to GCS by this workflow.

---

## 🧠 Design Philosophy

### [application-pipeline.yml](application-pipeline.yml)
This workflow is intentionally kept **simple, generic, and agnostic**.

It acts as a **wrapper (or orchestration layer)** around reusable internal workflows.

### Key principles:

- ❌ No complex business logic in this wrapper
- ❌ No public/private release handling logic here
- ❌ No repository-specific behavior

- ✅ Reusable core logic lives in dedicated workflows:
  - `version-finalize.yml`
  - `version-metadata.yml`
  - other specialized workflows

- ✅ This file only orchestrates execution

---

## 🔧 Customization Strategy

If a repository requires specific behavior (for example: filtered public releases, custom metadata, or additional steps):

👉 It is expected to:

- either **compose additional jobs around this workflow**
- or **create a custom wrapper workflow**

This keeps the base workflow:

- stable
- maintainable
- reusable across all projects

---

## 📌 Summary

This workflow is a **thin abstraction layer** that:

- standardizes CI/CD across Vegito projects
- delegates complex logic to reusable components
- avoids over-engineering and conditional complexity
