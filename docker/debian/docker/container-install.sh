#!/bin/bash
set -euo pipefail


container_docker_install_success=false
# 🧹 Function called at the end of the script to check for success
check_success() {
    if [ $container_docker_install_success = true ]; then
        echo "♻️ Docker Debian container installed successfully."
    else
        echo "❌ Docker Debian container installation failed."
    fi
}

# 🚨 Register cleanup function to run on script exit
trap check_success EXIT

LOCAL_USER="$(id -un)"

if ! grep -q "^${LOCAL_USER}:" /etc/subuid; then
    echo "${LOCAL_USER}:100000:65536" | sudo tee -a /etc/subuid
fi

if ! grep -q "^${LOCAL_USER}:" /etc/subgid; then
    echo "${LOCAL_USER}:100000:65536" | sudo tee -a /etc/subgid
fi

# Set inotify watches limit
echo fs.inotify.max_user_watches=524288 |  sudo tee -a /etc/sysctl.conf; sudo sysctl -p
# Set inotify watches limit for rootless dockerd
echo fs.inotify.max_user_watches=524288 | sudo tee -a /run/user/$LOCAL_USER_ID/sysctl.conf
sudo sysctl -p /run/user/$LOCAL_USER_ID/sysctl.conf

container_cache=${LOCAL_DOCKER_CONTAINER_CACHE:-${LOCAL_DIR:-${PWD}}/.containers/docker}

mkdir -p ${HOME}/.bashrc.d

cat <<EOF > ~/.bashrc.d/20-docker.sh
export DOCKER_HOST=unix:///run/user/${LOCAL_USER_ID:-1000}/docker.sock
export DOCKER_CONFIG=${container_cache}/.docker
export DOCKER_BUILDKIT=1

export BUILDKIT_PROGRESS=plain
export COMPOSE_DOCKER_CLI_BUILD=1

alias dps='docker ps'
alias dpa='docker ps -a'

alias di='docker images'

alias dlog='docker logs -f'
alias dex='docker exec -it'
alias dcu='docker compose up'
alias dcud='docker compose up -d'
alias dcd='docker compose down'
alias dcb='docker compose build'
alias dbx='docker buildx'
alias dbxb='docker buildx bake'
alias dprune='docker system prune -af'
alias dvol='docker volume ls'
alias dnet='docker network ls'
EOF

container_docker_install_success=true