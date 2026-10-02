#!/bin/bash
set -euo pipefail

mkdir -p ~/.bashrc.d

if ! grep -q "__BASHRC_D" ~/.bashrc; then
cat <<'EOF' >> ~/.bashrc
# __BASHRC_D
if [ -d "${HOME}/.bashrc.d" ]; then
    for f in "${HOME}"/.bashrc.d/*.sh; do
        [ -r "$f" ] && source "$f"
    done
fi

EOF
fi

cat <<EOF > ~/.bashrc.d/100-stripe.sh
#!/bin/sh
source ~/.stripe_env
EOF