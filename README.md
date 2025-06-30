# local

Local development folder of any project - let's customize

# 🧱 DevLocal Docker GPU Stack

Welcome to **DevLocal-Docker**, a fully portable, GPU-accelerated local development stack designed for high-performance Flutter + Android + GPU projects. This stack provides a complete development environment, including Android Studio with emulator support, GPU rendering, server-side rendering with V8Go, and full headless compatibility via Xpra + Xorg.

---

## ✨ Features

- ⚡ **GPU-accelerated Android Emulator** (e.g. Google Maps, camera, media)
- 🧠 **AI/ML-compatible GPU runtime** (CUDA, OpenGL, Vulkan-ready)
- 🐋 **Headless container** powered by Docker + Xorg + Xpra
- 🎯 **OpenGL via NVIDIA GPU passthrough**
- 🧪 **Emulator testing & CI pipeline-ready**
- 🪄 **Devcontainers compatible** (VS Code, GitHub Codespaces)
- 🌐 **Web-based GUI access** via Xpra HTML5
- 🔄 **Composable Docker build system** with Makefile targets

---

## 📦 Components

| Layer              | Stack                                                      |
|-------------------|------------------------------------------------------------|
| 🧰 Base            | Debian 12 + Docker + NVIDIA Container Toolkit              |
| 🧠 GPU             | NVIDIA RTX / CUDA-enabled environment                      |
| 📱 Mobile Dev      | Android SDK, Emulator, Flutter SDK                        |
| 🧠 SSR             | V8Go + React SSR                                           |
| 🎮 GUI Headless    | Xorg + Openbox + Xpra with web VNC support                 |
| 🧪 Testing         | Automated emulator testing via `glxinfo`, `adb`, etc.      |

---

## 🔧 Setup

```bash
# 1. Build and run the container
make local-android-studio-image-pull
make local-android-studio-docker-compose-sh

# 2. Inside the container, start the display
display-start-xpra.sh

# 3. Access the desktop via browser
http://localhost:5900/
```

---

## 🖥️ GPU Acceleration (Success Example)

```bash
DISPLAY=:1 glxinfo | grep -E "renderer|OpenGL"

OpenGL vendor string: NVIDIA Corporation
OpenGL renderer string: NVIDIA GeForce RTX 2080 Ti/PCIe/SSE2
OpenGL core profile version string: 4.6.0 NVIDIA 535.247.01
...
```

---

## 🧪 Use Cases

- 🚀 Mobile emulator testing with real OpenGL (no CPU lag)
- 🎥 Flutter + Maps integration preview
- 🧠 ML inferencing with shared GPU
- 🧪 CI pipelines with rendering tests
- ☁️ Remote dev with full graphical support

---

## 🧭 Vision

This project serves as the foundation of a powerful dev experience:

- As a **portable open-source kit** for Android/GPU developers
- As a **base layer** for building SaaS platforms:
  - Provision remote GPU-powered Android workspaces
  - Run ephemeral builds/tests with GPU emulation
  - Power SSR previews for design+QA workflows

---

## 📜 License

MIT — use freely, contribute openly, and stay sharp.

---

## 🙌 Special Thanks

To all GPU warriors, DevOps tinkerers, and caffeine-driven dreamers 🚀
