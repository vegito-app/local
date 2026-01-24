#!/usr/bin/env bash
set -e

VSIX_DIR=".devcontainer/vsix"
mkdir -p "$VSIX_DIR"

download() {
  local ext="$1"     # publisher.name
  local version="$2"

  local publisher="${ext%%.*}"
  local name="${ext#*.}"
  local out="${VSIX_DIR}/${ext}-${version}.vsix"

  if [ -f "$out" ]; then
    echo "✓ $out already exists"
    return
  fi

  echo "↓ downloading $ext@$version"
  curl -L \
    "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/${publisher}/vsextensions/${name}/${version}/vspackage" \
    -o "$out"
}

# --- liste MINIMALE, pas philosophique ---
download golang.go 0.52.1
download dart-code.flutter 3.126.0
download hashicorp.terraform 2.37.6
download ms-azuretools.vscode-docker 2.0.0
download ms-azuretools.vscode-containers 2.3.0

# 4ops.terraform-0.2.5
# alexisvt.flutter-snippets-3.0.0
# bierner.markdown-mermaid-1.29.0
# chflick.firecode-1.3.0
# circlecodesolution.ccs-flutter-color-2.2.0
# codeium.codeium-1.48.2
# cosmicsarthak.cosmicsarthak-neon-theme-4.4.7
# dart-code.dart-code-3.126.0
# dart-code.flutter-3.126.0
# dbaeumer.vscode-eslint-3.0.20
# diemasmichiels.emulate-1.8.1
# esbenp.prettier-vscode-12.3.0
# extensions.json
# genieai.chatgpt-vscode-0.0.13
# github.copilot-1.388.0
# github.copilot-chat-0.36.2
# github.vscode-github-actions-0.30.0
# golang.go-0.52.1
# googlecloudtools.cloudcode-2.37.0
# google.geminicodeassist-2.68.0
# gornivv.vscode-flutter-files-4.9.1
# hasanakg.firebase-snippets-0.0.1
# hashicorp.hcl-0.6.0
# hashicorp.terraform-2.37.6-linux-x64
# huang-an-sheng.firebase-web-app-snippets-1.1.6
# lakshits11.best-themes-redefined-0.4.6
# luanpotter.dart-import-0.3.1
# marcelovelasquez.flutter-tree-1.0.0
# marufhassan.flutter-snippets-1.0.6
# me-dutour-mathieu.vscode-github-actions-3.0.1
# ms-azuretools.vscode-containers-2.3.0
# ms-azuretools.vscode-docker-2.0.0
# ms-ceintl.vscode-language-pack-fr-1.108.2026012109
# msjsdiag.vscode-react-native-1.13.0
# ms-kubernetes-tools.vscode-kubernetes-tools-1.3.29
# nash.awesome-flutter-snippets-4.0.1
# openai.chatgpt-0.4.66-linux-x64
# pjmiravalle.terraform-advanced-syntax-highlighting-1.4.3
# pkief.material-icon-theme-5.31.0
# redhat.vscode-xml-0.29.0-linux-x64
# redhat.vscode-yaml-1.19.1
# shd101wyy.markdown-preview-enhanced-0.8.20
# standard.vscode-standard-2.1.3
# toba.vsfire-1.4.1
# tylerharris.terraform-link-docs-0.3.1
# xynny.hackerred-0.0.1