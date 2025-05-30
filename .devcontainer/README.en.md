# 🛠️ DevContainer – Advanced and Explicit Configuration

This `.devcontainer` directory contains the configuration used to run the development environment inside a Docker container driven by Visual Studio Code.  
We deliberately avoid relying on DevContainer “features” or implicit mounting mechanisms to preserve **clarity, reproducibility, and full control over the development setup**.

---

## 🧭 Technical choices

### 📌 Explicit workspace folder mounting

Instead of using features like `"workspaceMount"` or letting VS Code manage anonymous Docker volumes, we define a **clear and reproducible mount path** in `docker-compose.yml`:

```yaml
volumes:
  - ${PWD:-/workspaces/refactored-winner}:${PWD:-/workspaces/refactored-winner}:cached
```

And in `devcontainer.json`:

```json
"workspaceFolder": "/workspaces/refactored-winner"
```

✅ This guarantees:

- **Consistent file paths** across all containers
- **Compatibility with build and tooling scripts**
- **Seamless Docker-in-Docker support**
- **Predictable behavior**, independent of IDE or Docker internals

---

## ✅ Benefits

- 🔁 **Reproducibility**: no implicit logic, everything is Git-defined
- 🔒 **Full control**: no auto-mounts, no ephemeral volumes, no "magic"
- 💻 **Toolchain compatibility**: the workspace can be run with plain `docker-compose`
- 🧩 **Easily extensible**: any additional service/container inherits the same `$PWD` logic

---

## 🚫 What we intentionally avoid

- ❌ `"workspaceMount"` and auto-volume mapping
- ❌ `"features"` that inject tooling implicitly

---

## 🧪 Test recommendations

From the host (or over SSH):

```bash
cd /workspaces/refactored-winner
docker compose ps
make help  # or make test
```

From within VS Code:

- Terminal must open in `/workspaces/refactored-winner`
- Aliases and tooling should be available
- Reopening the DevContainer should be seamless

---

## 📎 For contributors

Please do not modify this structure unless discussed and approved.  
Changing the workspace mount mode or adding implicit logic would break **inter-container coordination and shared scripts**.
