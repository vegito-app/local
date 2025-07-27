# Welcome to the `local/` environment 🧰

This folder contains **everything you need to work locally** on the project, whether you're a backend, frontend, mobile, or fullstack developer.

## ⚡ Prerequisites

- Docker installed and running.
- VSCode with the "Dev Containers" extension (or any compatible `docker-compose` environment).
- Clone the repository:
  ```bash
  git clone git@github.com:<orga>/<repo>.git
  cd <repo>
  ```

## 🚀 Quick Start

Launch the complete development environment (main `dev` container + linked services):

```bash
make dev
```

This command starts all services defined in `local/docker-compose.yml`, including:

- the main `dev` container (your shell and workspace),
- the backend application,
- Firebase emulators,
- Clarinet (smart contracts),
- Android Studio,
- Vault (in dev mode).

Once the `dev` container is running, you can execute all the usual `make` commands **from inside the container**, or use the automatic integration if you're using **VSCode DevContainer**.

> 💡 Tip: You can also open the project through the VSCode interface with "Open in Container", which automatically uses `make dev`.

---

## 🔐 GCP Authentication

To interact with cloud infrastructure (Firebase, Terraform, etc.), you need to authenticate.

Use:

```bash
make gcloud-auth-login-sa
```

This will:

- log you into Google Cloud with your collaborator email,
- generate a `google-credentials.json` file located in `infra/[dev|staging|prod]`,
- give you access to the resources you're authorized to use or modify.

> 🧠 Your permissions are **managed as code** in the `infra/` folder and reflect your actual role on the project (read, write, etc.).

---

## 🧰 Local services: available commands

Each service launched via `docker-compose` has **dedicated `make` commands**. From inside the `dev` container, you can for example run:

```bash
make android-studio-container-start     # Start Android Studio
make android-studio-container-logs      # View logs
make android-studio-container-sh        # Shell into the container
make android-studio-container-stop      # Stop the service
```

The same logic applies to:

- Clarinet (Clarity contracts)
- Vault (secrets management)
- Firebase Emulators
- The Go backend, etc.

---

## 🔎 Want to go further?

- Explore the [`infra/`](../infra/) and [`application/run/`](../application/run/) folder to see how local/staging/prod environments are run.
- Check out the `Makefile`, `dev.mk`, and `docker-compose.yml` files to understand how everything fits together.
- Dive deeper into the [`docs/`](../docs/) folder (Firebase, Terraform workflows, NFC, reputation, etc.).

---

## 💡 Best Practices

- The environment is designed to be **reproducible**, **shared**, and **modular**.
- Feel free to create your own `make` commands or `.mk` files in `local/` if needed.
- If you have any questions or improvement ideas: open an issue or reach out to the infra team.

---

Welcome to the project, and happy hacking! 🚀
