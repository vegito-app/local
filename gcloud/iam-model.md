# IAM Model in Terraform for Google Cloud

This document explains the differences between `iam_member`, `iam_binding`, and `iam_policy`, and why certain identities like `principalSet://` (used in Workload Identity Federation) can only be used with full IAM policies.

---

## 🔐 Core Concepts

- **Role**: A collection of permissions (e.g. `roles/viewer`, `roles/editor`).
- **Member**: An identity (user, service account, group, or external identity like `principalSet://`).
- **Binding**: A tuple `<role> => [members]`.
- **Policy**: A full document containing multiple bindings. This is what is actually attached to a GCP resource.

---

## 🧩 Terraform IAM Resources

| Resource Type          | Description                                      | Supports `principalSet://`? | Overwrites all bindings? |
| ---------------------- | ------------------------------------------------ | --------------------------- | ------------------------ |
| `google_*_iam_member`  | Adds one member to one role                      | ❌ No                       | ❌ No                    |
| `google_*_iam_binding` | Adds multiple members to one role                | ❌ No                       | ❌ No                    |
| `google_*_iam_policy`  | Sets the full IAM policy (bindings + conditions) | ✅ Yes                      | ✅ Yes                   |

---

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
