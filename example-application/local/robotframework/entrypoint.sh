#!/bin/sh

set -euo pipefail

trap "echo Exited with code $?." EXIT

if [ "${LOCAL_ROBOTFRAMEWORK_CACHES_REFRESH:-false}" = "true" ]; then
    robotframework-caches-refresh.sh
fi

LOCAL_ROBOTFRAMEWORK_CONTAINER_CACHE=${LOCAL_WORKSPACE}/.containers/e2e-tests
mkdir -p $LOCAL_ROBOTFRAMEWORK_CONTAINER_CACHE

kill_jobs() {
    echo "Killing background jobs"
    for pid in "$${bg_pids[@]}"; do
        kill "$$pid"
        wait "$$pid" 2>/dev/null
    done
}

trap kill_jobs EXIT

cat << 'EOF' >> ~/.bashrc
alias rf='robot --outputdir ${LOCAL_ROBOTFRAMEWORK_TESTS_DIR} tests/robot'
alias h='htop'
alias i='sudo iftop'
alias ll='ls -lha'
alias l='ls -lh'
alias la='ls -Ah'
alias lla='ls -lhA'
EOF

mkdir -p ${LOCAL_ROBOTFRAMEWORK_TESTS_DIR}

cd ${LOCAL_ROBOTFRAMEWORK_TESTS_DIR} && python3 -m http.server 8088 &
bg_pids+=($!)

# Needed with github Codespaces which can change the workspace mount specified inside docker-compose.
current_workspace=$PWD
if [ "$current_workspace" != "$LOCAL_WORKSPACE" ] ; then
    sudo ln -s $current_workspace $LOCAL_WORKSPACE 2>&1 || true
    echo "Linked current workspace $current_workspace to $LOCAL_WORKSPACE"
fi

exec "$@"