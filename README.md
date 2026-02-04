# codespaces-hub

This repository provides a persistent development hub based on GitHub Codespaces.

It acts as a shared, VM-like environment exposing:

- `/workspaces`
- `/runner`
- NFS (via ganesha)
- SSH
- WireGuard

The goal is to reproduce a local Linux dev machine inside a Codespace,
allowing multiple projects to be cloned and worked on without duplicating
complex Devcontainer logic.

This repository is not an application and does not contain project code.
