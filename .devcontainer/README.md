# 🛠️ DevContainer – Configuration avancée et explicite

Ce répertoire `.devcontainer` contient la configuration utilisée pour exécuter l'environnement de développement à l'intérieur d'un conteneur Docker piloté par Visual Studio Code.  
Nous avons fait le choix délibéré de **ne pas nous appuyer sur les fonctionnalités automatiques ou implicites introduites par les DevContainer "features" modernes**, afin de préserver **la cohérence, la transparence et la maîtrise complète de l’environnement de développement**.

---

## 🧭 Choix techniques

### 📌 Montage explicite du dossier de travail (`workspace`)

Plutôt que d'utiliser les mécanismes par défaut comme `"workspaceMount"` ou les volumes Docker anonymes gérés par VS Code, nous utilisons un **montage explicite du dossier de travail à la racine du projet**, dans le fichier `docker-compose.yml` :

```yaml
volumes:
  - ${PWD:-/workspaces/refactored-winner}:${PWD:-/workspaces/refactored-winner}:cached
```

Et dans le fichier `devcontainer.json` :

```json
"workspaceFolder": "/workspaces/refactored-winner"
```

✅ Cela garantit :

- Des **chemins identiques** dans tous les conteneurs, facilitant les scripts, le CI et les appels de Makefile
- Une **cohérence entre environnement local, CI, et cloud** (par ex. sur GCP)
- Une **compatibilité avec Docker-in-Docker** (utilisation du Docker socket partagé)
- Aucune dépendance implicite sur des surcouches comme les features GitHub Codespaces

---

## ✅ Avantages

- 🔁 **Reproductibilité** : aucun comportement magique, tout est défini dans Git
- 🔒 **Maîtrise totale** : pas d'auto-mount, pas de volumes surprises, pas de dépendance VS Code
- 💻 **Compatibilité multi-outils** : peut être lancé avec `docker-compose` seul, sans extension VS Code
- 🧩 **Extensibilité facile** : chaque conteneur peut exploiter le même `PWD` sans adapter les scripts ou les chemins

---

## 🚫 Ce que nous évitons volontairement

- ❌ `"workspaceMount"` implicite
- ❌ `"features"` injectant des outils sans visibilité (comme `ghcr.io/devcontainers/features/docker`)

---

## 🧪 Tests recommandés

Depuis l’hôte (ou en SSH) :

```bash
cd /workspaces/refactored-winner
docker compose ps
make help  # ou make test
```

Et dans VS Code :

- Vérifiez que le terminal s’ouvre dans `/workspaces/refactored-winner`
- Que vos alias sont fonctionnels
- Que le DevContainer redémarre sans perte de contexte

---

## 📎 Pour les contributeurs

Merci de ne pas modifier ce mode de fonctionnement sans discussion préalable.  
Toute modification visant à utiliser les `features`, ou à changer le point de montage, risque de **casser la cohérence inter-conteneurs et scripts partagés**.
