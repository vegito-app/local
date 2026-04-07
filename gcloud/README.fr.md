## 🔐 Gestion des identités `gcloud` et bonnes pratiques

L’authentification `gcloud` peut se faire de deux manières :

1. Via un **compte utilisateur Gmail ou professionnel** (`gcloud auth login`)
2. Via un **compte de service (SA)** avec une **clé privée JSON** (`gcloud auth activate-service-account`)

### 🧠 Points importants à connaître

#### 🎭 1. Une identité peut "coller" à gcloud

- Une fois connecté avec un compte email, `gcloud` continue d’utiliser cette identité même si tu appelles une autre cible.
- Cela peut provoquer des erreurs subtiles comme :
  - `invalid_grant`
  - `Invalid JWT Signature`
  - `403 Permission denied`

#### ✅ Solution :

- Révoquer l’authentification en cours :
  ```bash
  make gcloud-auth-reset
  ```

---

#### 🔐 2. Les comptes de service ont des limites de **nombre de clés**

- Un SA ne peut avoir **que 10 clés privées actives** à la fois.
- Si tu dépasses cette limite, la commande de création échouera.

#### ✅ Solutions :

- Pour **voir les clés existantes** :

  ```bash
  make gcloud-user-iam-sa-keys-list
  ```

- Pour **supprimer les 3 plus anciennes clés** :

  ```bash
  make gcloud-user-iam-sa-keys-clean-oldest-3
  ```

- Ensuite, tu peux régénérer une nouvelle clé :
  ```bash
  make gcloud-auth-login-sa
  ```

---

### 📚 Cas d’usage des cibles `make`

| Situation                                                  | Commande à utiliser                           |
| ---------------------------------------------------------- | --------------------------------------------- |
| Tu veux te connecter avec ton email (Gmail, pro...)        | `make gcloud-auth-login-email`                |
| Tu veux utiliser un compte de service (SA)                 | `make gcloud-auth-login-sa`                   |
| Tu veux régénérer une clé SA (si supprimée ou expirée)     | `make gcloud-auth-login-sa`                   |
| Tu veux voir les clés SA existantes                        | `make gcloud-user-iam-sa-keys-list`           |
| Tu veux supprimer les plus vieilles clés (limite atteinte) | `make gcloud-user-iam-sa-keys-clean-oldest-3` |
| Tu veux tout réinitialiser et changer d'identité `gcloud`  | `make gcloud-auth-reset`                      |

---

👉 Ces étapes sont importantes pour éviter des erreurs intermittentes, en particulier dans les environnements CI/CD ou devcontainer.

---

### ⚠️ Important — Définir `VEGITO_PROJECT_USER` dans `.env`

Pour que les noms des comptes de service (SA) soient correctement générés, tu dois définir la variable `VEGITO_PROJECT_USER` dans le fichier `.env` local, par exemple :

VEGITO_VEGITO_PROJECT_USER=user-id

```

> 🐳 Ce fichier `.env` est propagé automatiquement à l’environnement après une reconstruction du conteneur (`Rebuild Container` via DevContainer) suivie d’un `make dev`.

Sans cette variable, les commandes peuvent générer des identifiants erronés comme `user-id-here-dev@...`, entraînant des erreurs `NOT_FOUND: Unknown service account`.
```
