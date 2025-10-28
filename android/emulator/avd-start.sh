#!/bin/bash

set -euo pipefail

# 📌 List of PIDs of background processes
bg_pids=()

# 🧹 Function called at the end of the script to kill background processes
kill_jobs() {
    echo "🧼 Cleaning up background processes..."
    for pid in "${bg_pids[@]}"; do
        kill "$pid" || true
        wait "$pid" 2>/dev/null || true
    done
}

# 🚨 Register cleanup function to run on script exit
trap kill_jobs EXIT

echo "Starting adb server if not running..."
if ! pgrep -x "adb" >/dev/null; then
  adb start-server &
  bg_pids+=($!)
  echo "ADB server started."
fi

echo "List of available AVDs:"

emulator -list-avds

# 📦 Détection automatique de l'APK si non fourni
apk_path="${LOCAL_ANDROID_DEBUG_APK_PATH:-}"
if [[ -z "$apk_path" ]]; then
  if [[ -f "/build/output/app-release.apk" ]]; then
    apk_path="/build/output/app-release.apk"
  elif [[ -f "/build/output/app-debug.apk" ]]; then
    apk_path="/build/output/app-debug.apk"
  else
    echo "❌ No APK found. Please set LOCAL_ANDROID_DEBUG_APK_PATH or provide app-release.apk/app-debug.apk in /build/output/"
    exit 1
  fi
fi
avd_name="${LOCAL_ANDROID_AVD_NAME:-Pixel_8_Pro}"
gpu_mode="${LOCAL_ANDROID_gpu_mode:-swiftshader_indirect}"

# 📛 Détection du nom du package si non fourni
if [[ -z "${LOCAL_ANDROID_PACKAGE_NAME:-}" ]]; then
  if command -v aapt >/dev/null; then
    package_name=$(aapt dump badging "${apk_path}" | awk -F"'" '/package: name=/{print $2}')
    echo "📦 Package name auto-detected: $package_name"
  else
    echo "❌ aapt is not available to auto-detect the package name. Please provide LOCAL_ANDROID_PACKAGE_NAME."
    exit 1
  fi
else
  package_name="${LOCAL_ANDROID_PACKAGE_NAME}"
fi

echo "Using APK path: ${apk_path}"
echo "Using package name: ${package_name}"
echo "Using GPU mode: ${gpu_mode}"
echo "Using AVD name: ${avd_name}"  

# Detect KVM availability
accel_args="-accel on"
if [ ! -e /dev/kvm ]; then
  echo "⚠️ /dev/kvm not present, falling back to software accel"
  accel_args="-accel off"
fi

headless_args="-no-window"
if xdpyinfo >/dev/null 2>&1; then
  headless_args=""
fi

echo "Starting AVD named: ${avd_name} (gpu=${gpu_mode})"
emulator -avd "${avd_name}" \
  -gpu "${gpu_mode}" \
  ${headless_args} \
  ${accel_args} \
  -noaudio -no-snapshot-load \
  -no-boot-anim \
  -wipe-data \
  -qemu &
emulator_pid=$!
bg_pids+=($emulator_pid)

# Wait for device and boot completion
adb wait-for-device
until adb shell getprop sys.boot_completed 2>/dev/null | grep -q "1"; do
  echo "⏳ Waiting for Android to report boot_completed..."
  sleep 2
done

# 🔄 Attente que le device soit en ligne (plus offline)
echo "🧪 Waiting for adb to become 'device' (not 'offline')..."
while true; do
  state=$(adb get-state 2>/dev/null || echo unknown)
  if [[ "$state" == "device" ]]; then
    echo "✅ ADB reports device is online."
    break
  fi
  echo "⏳ Current ADB state: $state"
  sleep 2
done

# ⏳ Vérifie que adb shell est réactif
echo "🔍 Checking ADB shell responsiveness..."
until adb shell echo ok | grep -q "ok"; do
  echo "⏳ Waiting for ADB shell to respond..."
  sleep 2
done
echo "✅ ADB shell is responsive."

emulator_data="${LOCAL_ANDROID_EMULATOR_DATA:-./images}"
echo "Loading test data from: ${emulator_data}"

emulator-data-load.sh "${emulator_data}"


# 🔐 Injection du token App Check si fourni
if [[ "$apk_path" == *"release.apk" && -n "$FIREBASE_APP_CHECK_DEBUG_TOKEN" ]]; then
  echo "💠 App Check debug token detected. Injecting..."
  echo "FIREBASE_APP_CHECK_DEBUG_TOKEN=$FIREBASE_APP_CHECK_DEBUG_TOKEN" > /data/local/tmp/app_check.env
fi

echo "Checking if an APK is present and installing..."
if [ -f "${apk_path}" ]; then
  echo "APK found ${package_name} ${apk_path}, attempting installation..."
  if adb install -r "${apk_path}"; then
    echo "✅ APK installed ${package_name}."

    echo "🚀 Attempting to launch the app..."
    adb shell monkey -p "${package_name}" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1

    sleep 2

    if adb shell pidof "${package_name}" >/dev/null; then
      echo "✅ App is running."
    else
      echo "⚠️ App did not launch. Trying again..."
      adb shell monkey -p "${package_name}" -c android.intent.category.LAUNCHER 1
    fi

  else
    echo "❌ APK installation failed."
  fi
else
  echo "⚠️ No APK found at ${apk_path}; skipping installation."
fi

wait $emulator_pid