#!/bin/bash

set -eu

# Headless by default; if DISPLAY is not set, run emulator with -no-window
HEADLESS_ARGS="-no-window"
if xdpyinfo >/dev/null 2>&1; then
  HEADLESS_ARGS=""
fi


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

avd_to_use="${LOCAL_ANDROID_AVD_NAME:-Pixel_8_Pro}"
echo "AVD to use: ${avd_to_use}"

# Detect KVM availability
ACCEL_ARGS="-accel on"
if [ ! -e /dev/kvm ]; then
  echo "⚠️ /dev/kvm not present, falling back to software accel"
  ACCEL_ARGS="-accel off"
fi

GPU_MODE="${LOCAL_ANDROID_GPU_MODE:-swiftshader_indirect}"

echo "Starting AVD named: ${avd_to_use} (gpu=${GPU_MODE})"
emulator -avd "${avd_to_use}" \
  -gpu "${GPU_MODE}" \
  ${HEADLESS_ARGS} \
  ${ACCEL_ARGS} \
  -noaudio -no-snapshot-load \
  -no-boot-anim \
  -wipe-data \
  -qemu &
bg_pids+=($!)

# Wait for device and boot completion
adb wait-for-device
until adb shell getprop sys.boot_completed 2>/dev/null | grep -q "1"; do
  echo "⏳ Waiting for Android to report boot_completed..."
  sleep 2
done

echo "Starting Appium server..."
appium --address 0.0.0.0 --port 4723 \
  --session-override --log-level info \
  --allow-insecure=adb_shell &
bg_pids+=($!)
echo "Appium is ready to accept connections on port 4723."

emulator-data-load.sh ${LOCAL_APPLICATION_TESTS_MOBILE_IMAGES_DIR:-./images}

echo "Checking if an APK is present and installing..."
if [ -f ${LOCAL_APPLICATION_MOBILE_APK_PATH} ]; then
  echo "APK found, attempting installation..."
  if adb install -r ${LOCAL_APPLICATION_MOBILE_APK_PATH}; then
    echo "✅ APK installed successfully."
    echo "🚀 Attempting to launch the app..."
    adb shell monkey -p ${LOCAL_APPLICATION_MOBILE_ANDROID_PACKAGE_NAME} -c android.intent.category.LAUNCHER 1
  else
    echo "❌ APK installation failed."
  fi
else
  echo "⚠️ No APK found at ${LOCAL_APPLICATION_MOBILE_APK_PATH}; skipping installation."
fi
echo "The emulator is ready and running."
echo "You can now run your Appium tests."
echo "📜 Kernel & system log tails (Ctrl+C to stop):"
adb logcat -v time | sed -n '1,200p' || true
adb logcat --pid=$(adb shell pidof -s com.android.systemui) -v threadtime &
bg_pids+=($!)
sleep infinity