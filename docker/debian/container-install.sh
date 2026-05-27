#!/bin/bash
set -euo pipefail


container_debian_install_success=false
# 🧹 Function called at the end of the script to check for success
check_success() {
    if [ $container_debian_install_success = true ]; then
        echo "♻️ Debian container installed successfully."
    else
        echo "❌ Debian container installation failed."
    fi
}

# 🚨 Register cleanup function to run on script exit
trap check_success EXIT

mkdir -p ~/.bashrc.d

cat <<EOF > ~/.bashrc.d/00-debian.sh
export HISTSIZE=50000
export HISTFILESIZE=100000
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias c='clear'
alias h='history'
alias j='jobs -l'

alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

alias ll='ls -lah'
alias reload='source ~/.bashrc'

alias svim='sudo vim'

alias svimrc='vim ~/.bashrc'

alias path='echo $PATH | tr ":" "\n"'
alias ports='ss -tulpn'

alias mem='free -h'
alias cpu='htop'
alias io='iotop'
alias disk='df -h'
alias mounts='findmnt'
alias pci='lspci'
alias usb='lsusb'
EOF

# Git config (optional but useful)
GIT_CONFIG_GLOBAL=${HOME}/.gitconfig
if [ -f "$GIT_CONFIG_GLOBAL" ]; then
  mkdir -p ${local_container_cache}/git
  rsync -av "$GIT_CONFIG_GLOBAL" ${local_container_cache}/git/
  rm -f "$GIT_CONFIG_GLOBAL"
  ln -s ${local_container_cache}/git/.gitconfig $GIT_CONFIG_GLOBAL
fi

cat <<EOF > ~/.bashrc.d/10-git.sh
alias g='git'

alias ga='git add'
alias gaa='git add .'

alias gc='git commit'
alias gcm='git commit -m'

alias gp='git push'
alias gl='git pull'

alias gst='git status -sb'
alias gco='git checkout'
alias gb='git branch'

alias glog='git log --oneline --graph --decorate --all'

alias gclean='git clean -xfd'

alias gs='git status'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate'
EOF

mkcd() {
    mkdir -p "$1" && cd "$1"
}

container_debian_install_success=true