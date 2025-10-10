## 🔐 Managing `gcloud` identities and best practices

Authentication with `gcloud` can be done in two ways:

1. Via a **Gmail or professional user account** (`gcloud auth login`)
2. Via a **Service Account (SA)** with a **private JSON key** (`gcloud auth activate-service-account`)

### 🧠 Important things to know

#### 🎭 1. An identity can "stick" to gcloud

- Once logged in with a user account, `gcloud` will continue using that identity even if you run a different target.
- This can cause subtle errors like:
  - `invalid_grant`
  - `Invalid JWT Signature`
  - `403 Permission denied`

#### ✅ Solution:

- Revoke the current authentication:
  ```bash
  make gcloud-auth-reset
  ```

---

#### 🔐 2. Service Accounts have a limit on the **number of keys**

- An SA can have **only 10 active private keys** at a time.
- If you exceed this limit, key creation will fail.

#### ✅ Solutions:

- To **list existing keys**:

  ```bash
  make gcloud-user-iam-sa-keys-list
  ```

- To **delete the 3 oldest keys**:

  ```bash
  make gcloud-user-iam-sa-keys-clean-oldest-3
  ```

- Then, you can regenerate a new key:
  ```bash
  make gcloud-auth-login-sa
  ```

---

### 📚 When to use each `make` target

| Situation                                               | Command to use                                |
| ------------------------------------------------------- | --------------------------------------------- |
| You want to log in with your email (Gmail, work...)     | `make gcloud-auth-login-email`                |
| You want to use a service account (SA)                  | `make gcloud-auth-login-sa`                   |
| You want to regenerate a SA key (if deleted or expired) | `make gcloud-auth-login-sa`                   |
| You want to view existing SA keys                       | `make gcloud-user-iam-sa-keys-list`           |
| You want to delete the oldest keys (limit reached)      | `make gcloud-user-iam-sa-keys-clean-oldest-3` |
| You want to fully reset and switch `gcloud` identity    | `make gcloud-auth-reset`                      |

---

👉 These steps are important to avoid intermittent errors, especially in CI/CD or devcontainer environments.

---

### ⚠️ Important — Set `PROJECT_USER` in `.env`

To ensure service account (SA) names are generated correctly, you must define the `PROJECT_USER` variable in your local `.env` file, for example:

```dotenv
PROJECT_USER=david-berichon
```

> 🐳 This `.env` file is automatically propagated into the environment after rebuilding the container (`Rebuild Container` via DevContainer), followed by a `make dev`.

If this variable is missing, commands may default to `user-id-here-dev@...`, leading to errors such as `NOT_FOUND: Unknown service account`.
