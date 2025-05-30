#!/bin/bash

set -u

pkill -f studio || true 

studio-caches-refresh.sh 

xset r on

studio