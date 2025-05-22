

# 🧪 Tests E2E – Environnement Robot Framework

Ce dossier contient l’ensemble de l’environnement de test E2E de l’application, basé sur **[Robot Framework](https://robotframework.org/)**, exécuté dans un conteneur Docker isolé.

---

## 🎯 Objectifs

- Valider des **parcours utilisateurs complets** via Appium ou via API.
- Garantir la stabilité de l’application dans un environnement isolé et reproductible.
- Offrir une base robuste pour écrire des **tests lisibles**, maintenables et versionnés.

---

## 🏗️ Architecture

Le conteneur `application-tests` fait partie intégrante du `docker-compose.yml` et accède aux autres services via le réseau `dev`.

### Services accessibles :
| Service             | Adresse dans les tests                |
|---------------------|---------------------------------------|
| Backend Go          | `http://backend:8080`                 |
| Firebase Emulator   | `http://firebase-emulators:5001`      |
| Vault Dev           | `http://vault-dev:8200`               |
| Clarinet Devnet     | `http://clarinet-devnet:20443`        |
| Android Emulateur   | `http://android-studio`               |

### Fichiers importants :
- `Dockerfile` → environnement de test basé sur Python + Robot + Appium
- `entrypoint.sh` → configuration du cache, des alias, etc.
- `tests/robot/` → dossiers contenant les tests `.robot`

---

## 🚀 Lancer l'environnement de test

```bash
make local-e2e-tests-docker-compose-up
```

Cela :
- démarre le conteneur `application-tests`
- initialise le cache local pour pip et Robot
- ouvre un shell interactif prêt à exécuter des tests

---

## 🧪 Exécuter les tests

Une fois dans le conteneur :

```bash
rf                # alias pour lancer tous les tests .robot
rf -t "Nom du test"  # pour exécuter un test spécifique
```

Les rapports sont générés dans `application/tests/output/`.

---

## 🛠️ Ajouter un test

1. Crée un fichier dans `tests/robot/` avec l'extension `.robot`
2. Suis la syntaxe de Robot Framework :

```robot
*** Settings ***
Library  RequestsLibrary

*** Test Cases ***
Vérifier l'API backend
    Create Session  backend  http://backend:8080
    GET  backend  /ping
    Status Should Be  200
```

3. Lance-le avec `rf`.

---

## 📁 Cache local

Les données volumineuses sont stockées dans `local/.containers/e2e-tests/`, pour éviter les volumes Docker persistants :
- `pip/` → cache des paquets Python
- `robot/` → logs de test (`output.xml`, `report.html`, `log.html`)

---

## 👥 Bonnes pratiques

- Écris des tests **lisibles**, simples, et orientés **comportement utilisateur**
- Regroupe les cas par feature dans `tests/robot/<feature>.robot`
- Ne pas polluer le code avec des instructions internes (conserve le côté "spécification exécutable")

---

## 📌 TODO (prochaines étapes)

- [ ] Ajouter des tests Appium utilisant l’émulateur Android déjà disponible
- [ ] Intégration CI (GitHub Actions ou Cloud Build)
- [ ] Générer automatiquement les rapports dans une pipeline
- [x] Intégrer les tests E2E dans `make test-all`

---

## 🙏 Contributeurs bienvenus

Ce dossier est pensé comme une **base de travail collective** : tu peux proposer tes améliorations, raccourcis, ou nouveaux tests en créant une PR propre.

---