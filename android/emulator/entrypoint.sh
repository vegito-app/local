#!/bin/bash
set -e

echo "📦 Lancement de l'émulateur Android AVD..."

# Démarre l’émulateur en headless mode avec Xvfb
Xvfb :20 -screen 0 1280x720x16 &

# Démarre openbox (léger) pour GUI éventuel
openbox &

# Lance l’émulateur
$ANDROID_SDK/emulator/emulator -avd Pixel_8_Intel -no-snapshot -no-audio -no-boot-anim -gpu swiftshader_indirect &

# Attend que l’émulateur soit prêt
echo "⌛ Attente du démarrage de l’émulateur..."
adb wait-for-device

# Installe l’APK si dispo
if [ -f "$APPLICATION_MOBILE_APK_PATH" ]; then
    echo "📱 Installation de l'APK : $APPLICATION_MOBILE_APK_PATH"
    adb install -r "$APPLICATION_MOBILE_APK_PATH"
else
    echo "⚠️ APK non trouvé à $APPLICATION_MOBILE_APK_PATH"
fi

# Garde le conteneur ouvert (évite l'exit immédiat)
echo "✅ Émulateur prêt. Vous pouvez vous connecter en VNC ou debugger via adb."
tail -f /dev/null