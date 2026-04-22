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
avd_name="${LOCAL_ANDROID_EMULATOR_AVD_NAME:-Pixel_8_Pro}"
gpu_mode="${LOCAL_ANDROID_GPU_MODE:-swiftshader_indirect}"

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
  headless_args=${LOCAL_ANDROID_EMULATOR_AVD_HEADLESS_ARGS:-""}
fi


echo "Starting AVD named: ${avd_name} (gpu=${gpu_mode})"
emulator -avd "${avd_name}" \
  -gpu "${gpu_mode}" \
  -cores 4 \
  -netdelay none \
  -netspeed full \
  ${headless_args} \
  ${accel_args} \
  -noaudio -no-snapshot-load \
  -no-boot-anim \
  -wipe-data &
emulator_pid=$!
bg_pids+=($emulator_pid)

echo "⏳ Waiting for adb device..."

# 1. Device visible + online
until adb get-state 2>/dev/null | grep -q "device"; do
  echo "⏳ adb not ready..."
  sleep 2
done

# 2. Boot terminé
echo "⏳ Waiting for Android boot..."
timeout 300 bash -c '
until adb shell getprop sys.boot_completed 2>/dev/null | grep -q "1"; do
  sleep 2
done
'

# 3. Shell réellement OK
echo "⏳ Waiting for adb shell..."
until adb shell echo ok 2>/dev/null | grep -q "ok"; do
  sleep 2
done

echo "✅ Emulator fully ready"

emulator_data="${LOCAL_ANDROID_EMULATOR_DATA:-./images}"
echo "Loading test data from: ${emulator_data}"

emulator-data-load.sh "${emulator_data}"

# 🔐 Injection du token App Check si fourni
if [[ "$apk_path" == *"release.apk" && -n "${FIREBASE_APP_CHECK_DEBUG_TOKEN:-}" ]]; then
  echo "💠 App Check debug token detected. Injecting..."
  echo "FIREBASE_APP_CHECK_DEBUG_TOKEN=${FIREBASE_APP_CHECK_DEBUG_TOKEN:-}" > /data/local/tmp/app_check.env
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