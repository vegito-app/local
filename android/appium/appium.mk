
local-android-appium-emulator-avd-restart:
	@$(LOCAL_ANDROID_STUDIO) bash -c ' \
	  echo "[*] Killing emulator & adb..." ; \
	  pkill -9 emulator ; \
	  pkill -9 qemu-system ; \
	  adb kill-server ; \
	  echo "[*] Cleaning up locks..." ; \
	  rm -rf ~/.android/avd/*/*.lock ; \
	  rm -f ~/.android/*.lock ; \
	  rm -f ~/.android/adb*.ini.lock ; \
	  rm -f /tmp/.X20-lock ; \
	  echo "[*] Restarting ADB..." ; \
	  adb start-server ; \
	  echo "[*] Launching emulator..." ; \
	  echo "Starting android-studio emulator..." ; \
	  LOCAL_ANDROID_AVD_NAME=$(LOCAL_ANDROID_STUDIO_ANDROID_AVD_NAME) \
	  LOCAL_ANDROID_GPU_MODE=$(LOCAL_ANDROID_STUDIO_ANDROID_GPU_MODE) \
	  	appium-emulator-avd.sh ; \
	  sleep infinity ; \
	'
.PHONY: local-android-appium-emulator-avd-restart

local-android-appium-emulator-avd:
	@$(LOCAL_ANDROID_STUDIO) appium-emulator-avd.sh
.PHONY: local-android-appium-emulator-avd
