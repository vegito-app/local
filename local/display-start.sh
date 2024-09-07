#!/bin/bash

LGUltraFine5KRes=2560x1440 # LG UltraFine
LGUltraFine5KRes_b=2148x1152 # LG UltraFine
LGUltraFine5KRes_b_half=1074x1152 # LG UltraFine
MacBookAirRes=1440x900
MacBookAirResHalf=720x900

# Lancez xvfb en arrière-plan
Xvfb ${DISPLAY} -nolisten tcp -cc 4 -screen 0, ${LGUltraFine5KRes_b_half}x24 &

# Boucle d'attente pour permettre à xvfb de démarrer
until xdpyinfo -display ${DISPLAY} > /dev/null 2>&1; do 
    echo Waiting X display frame buffer
    sleep 1
done

x11vnc -noxdamage -display ${DISPLAY} -nopw -forever &

openbox&
