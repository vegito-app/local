## 🏗️ Architecture des runners GitHub Actions auto-isolés

> Chaque runner CI démarre dans un conteneur Docker isolé et enregistre dynamiquement un builder `buildx` nommé selon son `$HOSTNAME`.

Ce design permet :
- le support multi-arch via QEMU
- une isolation forte entre runners
- une scalabilité horizontale
- et un cache par builder

```mermaid
flowchart TD
    subgraph GitHub Actions Workflow
        trigger[🔁 Push/PR<br/>CI Trigger]
    end

    trigger --> startRunner[🧱 Launch self-hosted runner<br/>+ auto-registration]
    startRunner --> entrypoint[🔧 ENTRYPOINT: init.sh]

    entrypoint --> hostnameStep[📛 Compute hostname → $HOSTNAME]
    hostnameStep --> createBuilder[docker buildx create<br/>--name=gha-builder-$HOSTNAME]
    createBuilder --> useBuilder[docker buildx use gha-builder-$HOSTNAME]

    useBuilder --> buildProcess[🏗️ docker buildx build<br/>--platform=linux/amd64,arm64]

    subgraph QEMU emulation
        buildProcess --> qemu[⚙️ QEMU emulation]
    end

    buildProcess --> result[📦 Multi-arch image built]

    result --> cleanup[🧹 Optional: docker buildx rm]

    style trigger fill:#e8f3ff,stroke:#2c80b4,stroke-width:1px
    style startRunner fill:#f4f4f4,stroke:#666,stroke-width:1px
    style hostnameStep fill:#ffffff,stroke:#666,stroke-width:1px
    style createBuilder fill:#d1ffd1,stroke:#22aa22,stroke-width:1px
    style buildProcess fill:#ffe4b5,stroke:#cc6600,stroke-width:1px
    style result fill:#d0f0ff,stroke:#2277aa,stroke-width:1px
    style qemu fill:#f9f9f9,stroke:#aaa,stroke-dasharray: 5 3
    style cleanup fill:#eee,stroke:#bbb,stroke-dasharray: 5 3
```