#!/bin/sh
set -e

test -f /tmp/.dockerd-rootless-ready
# test -f /tmp/.xpra-ready
test -f /tmp/.xdisplay-ready
# test -f /tmp/.ai-runtime-ready
test -f /tmp/.nestor-agent-ready

exit 0