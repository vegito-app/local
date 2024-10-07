Les **conventions de commits** sont un ensemble de règles standardisées pour rédiger les messages de commit dans un projet de manière claire et structurée. Elles sont particulièrement utiles dans les projets collaboratifs pour :

1. Faciliter la compréhension des changements.
2. Permettre une automatisation, comme l'incrémentation de versions avec des outils comme **standard-version** ou **semantic-release**.
3. Générer automatiquement des changelogs, des numéros de version, ou même des versions de packages.

### Convention la plus répandue : **Conventional Commits**

La spécification **Conventional Commits** est l'une des plus populaires et fournit des règles strictes sur la manière de formuler les messages de commit. Elle se base sur le **versionnement sémantique** (SemVer) pour relier les messages de commit à des changements de version.

#### Format de base

Un message de commit suivant la convention se compose de plusieurs parties : un **type**, éventuellement un **scop**e, et un **message**. Voici la structure générale :

```text
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

#### Explication des composants :
1. **Type** : Il décrit la nature du changement. Exemples courants :
   - **feat** : Ajout d'une nouvelle fonctionnalité.
   - **fix** : Correction d'un bug.
   - **docs** : Modifications de la documentation uniquement.
   - **style** : Changement de format, sans impact sur le code (indentation, formatage, etc.).
   - **refactor** : Modifications du code qui n'ajoutent ni ne corrigent de fonctionnalités.
   - **test** : Ajout ou modification de tests existants.
   - **chore** : Maintenance ou changements qui n’affectent pas les fonctionnalités (mise à jour des dépendances).

2. **Scope** (optionnel) : La partie du projet concernée par ce commit. Par exemple, si tu modifies une partie spécifique du projet (comme une fonctionnalité ou un module), tu peux le préciser.

3. **Description** : Un court résumé de la modification (à la suite des deux points). Elle doit être concise et informative.

4. **Body** (optionnel) : Une description plus longue du commit si nécessaire, par exemple pour donner des détails techniques supplémentaires ou des explications sur la mise en œuvre.

5. **Footer** (optionnel) : Utilisé pour des informations additionnelles comme des notes sur les "breaking changes" (changements non rétrocompatibles) ou pour référencer des tickets ou issues.

#### Exemple de commits

1. **Ajout d'une fonctionnalité** :
   ```text
   feat(auth): add email authentication feature
   ```

2. **Correction d'un bug** :
   ```text
   fix(api): resolve incorrect response format
   ```

3. **Changement non rétrocompatible** (breaking change) :
   ```text
   feat(payment): add support for new currency API

   BREAKING CHANGE: The payment service now uses the new currency conversion API, which is not backward-compatible.
   ```

4. **Mise à jour de documentation** :
   ```text
   docs(readme): update installation guide with Docker instructions
   ```

### Avantages des Conventions de Commits

1. **Automatisation** : Ces conventions facilitent l'automatisation des processus comme la génération de changelogs, l'incrémentation des versions (patch, minor, major), et la publication automatique.

   Par exemple, un outil comme **standard-version** va lire le message de commit :
   - Si le type est `fix`, il augmentera la version **patch** (`v1.0.0` devient `v1.0.1`).
   - Si le type est `feat`, il augmentera la version **minor** (`v1.0.0` devient `v1.1.0`).
   - Si le commit contient `BREAKING CHANGE`, il augmentera la version **major** (`v1.0.0` devient `v2.0.0`).

2. **Clarté et historique** : Chaque commit est lisible et indique clairement ce qui a été modifié, facilitant la révision du code ou le débogage.

3. **Collaboration améliorée** : Dans un projet à plusieurs contributeurs, l'uniformité des messages de commit rend le suivi des modifications et la gestion des branches beaucoup plus faciles.

### Exemple d'outil utilisant ces conventions

- **Commitizen** : Un outil CLI qui aide les développeurs à rédiger des commits en suivant les conventions de commits.
- **Semantic-release** : Un outil qui publie automatiquement une nouvelle version de votre projet (ainsi que les changelogs, tags, etc.) basé sur le type de commits (feat, fix, breaking changes).

### Exemple d’un projet avec des conventions de commits

Disons que tu travailles sur un projet avec la fonctionnalité d'authentification utilisateur. Voici comment tu pourrais formuler des commits :

- **feat(auth): implement OAuth2 login flow**
- **fix(auth): resolve bug in token refresh logic**
- **chore(deps): update bcrypt to latest version**

Cela permet non seulement d’avoir des messages de commit standardisés, mais cela te permet également d’automatiser la gestion des versions et d’améliorer la lisibilité pour l’ensemble de l’équipe.

---

La mise à jour des versions d'un logiciel est souvent gérée avec un système de **versionnement sémantique** (SemVer) de type `v1.2.3`, où chaque chiffre correspond à un certain type de changement :

- **v1** (major) : changements incompatibles avec les versions précédentes (breaking changes).
- **v2** (minor) : ajouts de nouvelles fonctionnalités, mais rétrocompatibles.
- **v3** (patch) : corrections de bugs ou améliorations mineures.

### 1. Création de nouveaux tags manuellement
Les tags dans Git (y compris sur GitHub) peuvent être créés manuellement pour marquer des versions spécifiques du projet. Le processus est manuel lorsqu'on veut simplement marquer une version précise, généralement après un certain nombre de changements validés.

Voici comment créer manuellement un tag sur une branche (par exemple, `main`) :

```bash
# Créer un nouveau tag
git tag v1.2.3

# Pousser ce tag vers le dépôt distant (GitHub)
git push origin v1.2.3
```

Cela marque un commit spécifique comme étant une version, mais ce processus nécessite une intervention manuelle.

### 2. Incrémenter automatiquement le tag avec GitHub Actions

Tu peux automatiser l'incrémentation des versions (par exemple, augmenter automatiquement la version patch) lors de chaque commit dans la branche `main` à l'aide de **GitHub Actions**. Voici une manière de le faire :

#### Étape 1 : Créer un fichier GitHub Actions
Tu dois d'abord créer un fichier de workflow dans le dossier `.github/workflows/` de ton dépôt, par exemple, `release.yml`.

Voici un exemple de configuration de workflow :

```yaml
name: Auto Bump Version and Tag

on:
  push:
    branches:
      - main

jobs:
  bump_version:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout repository
      uses: actions/checkout@v2

    - name: Set up Node.js (required for standard-version)
      uses: actions/setup-node@v2
      with:
        node-version: '14'

    - name: Install standard-version
      run: npm install -g standard-version

    - name: Bump version and push tags
      run: |
        # Bump the version based on commit messages (default patch bump)
        standard-version

        # Push the new commit and the new tag
        git push --follow-tags origin main
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

#### Explications :
- Ce workflow est déclenché à chaque **push** sur la branche `main`.
- Il utilise l'outil **standard-version**, qui suit les conventions des messages de commit pour déterminer si la version doit être augmentée (patch, minor, ou major).
- L'outil modifie automatiquement le fichier `package.json` (ou d'autres fichiers si nécessaire), puis crée un commit et un tag pour cette nouvelle version.
- Ensuite, il pousse ce tag vers GitHub.

#### Étape 2 : Configurer les messages de commit
Pour que l'incrémentation fonctionne correctement, il faut suivre un format spécifique pour les messages de commit :

- `fix:` pour les corrections de bugs (augmente la version **patch**).
- `feat:` pour les nouvelles fonctionnalités (augmente la version **minor**).
- `BREAKING CHANGE:` pour des changements incompatibles (augmente la version **major**).

Par exemple :

```bash
git commit -m "fix: correct a typo in the documentation"
git commit -m "feat: add new user authentication feature"
```

### Conclusion
- Les tags peuvent être créés manuellement, mais l'automatisation avec GitHub Actions est une solution efficace pour gérer les versions et incrémenter automatiquement les numéros de version lors des nouveaux commits.
- L'approche que je t'ai montrée ici repose sur les conventions de commits pour déterminer le type d'incrémentation.

---
