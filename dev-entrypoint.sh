#!/bin/sh

set -eu

trap "echo Exited with code $?." EXIT

# Bash history
cat <<'EOF' >> ~/.bashrc
export HISTSIZE=50000
export HISTFILESIZE=100000
EOF

export DISPLAY=":1"

display-start.sh

exec "$@"