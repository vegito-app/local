#!/bin/sh

set -euo pipefail


container_install_success=false
# 🧹 Function called at the end of the script to check for success
check_success() {
    if [ $container_install_success = true ]; then
        echo "♻️ AI container installed successfully."
    else
        echo "❌ AI container installation failed."
    fi
}

# 🚨 Register cleanup function to run on script exit
trap check_success EXIT

AI_WORKSPACES=${AI_WORKSPACES:-/workspaces/ai}

mkdir -p ${AI_WORKSPACES}/ollama/models
mkdir -p ${AI_WORKSPACES}/ollama/cache
mkdir -p ${AI_WORKSPACES}/huggingface
mkdir -p ${AI_WORKSPACES}/torch
mkdir -p ${AI_WORKSPACES}/torch_extensions
mkdir -p ${AI_WORKSPACES}/chromadb
mkdir -p ${HOME}/.ollama
mkdir -p ${HOME}/.cache

ln -sfn ${AI_WORKSPACES}/ollama/models ${HOME}/.ollama/models
ln -sfn ${AI_WORKSPACES}/ollama/cache  ${HOME}/.ollama/cache

ln -sfn ${AI_WORKSPACES}/huggingface      ${HOME}/.cache/huggingface
ln -sfn ${AI_WORKSPACES}/torch            ${HOME}/.cache/torch
ln -sfn ${AI_WORKSPACES}/torch_extensions ${HOME}/.cache/torch_extensions
ln -sfn ${AI_WORKSPACES}/chromadb         ${HOME}/.cache/chromadb

container_install_success=true