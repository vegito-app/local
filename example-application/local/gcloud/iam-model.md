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
