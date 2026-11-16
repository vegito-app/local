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

android-container-start.sh &
bg_pids+=($!)

if [[ "${LOCAL_ANDROID_EMULATOR_AVD_ON_START:-false}" == "true" ]]; then

    echo "⏳ Waiting for emulator APK readiness before Appium..."

    deadline=$((SECONDS + 600))
    until [[ -f /tmp/.android-avd-ready ]]; do

        if ! kill -0 "${bg_pids[0]}" 2>/dev/null; then
            echo "❌ Android container startup exited"
            exit 1
        fi

        if (( SECONDS >= deadline )); then
            echo "❌ Android emulator readiness timeout"
            exit 1
        fi
        sleep 1
    done
    
    echo "✅ Android emulator APK ready"
fi

appium --address 0.0.0.0 --port 4723 \
  --session-override --log-level info \
  --allow-insecure uiautomator2:adb_shell