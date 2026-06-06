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

appium --address 0.0.0.0 --port 4723 \
  --session-override --log-level info \
  --allow-insecure uiautomator2:adb_shell