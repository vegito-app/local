#!/bin/bash

set -euo pipefail

# 🚀 Setup background services
sudo chmod o+rw /var/run/docker.sock

project-container-start.sh