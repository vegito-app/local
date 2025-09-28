LOCAL_ANDROID_APPIUM_DIR ?= $(LOCAL_ANDROID_DIR)/appium

local-android-appium-emulator-avd-restart:
	@$(LOCAL_ANDROID_CONTAINER_EXEC) bash -c ' \
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
	  LOCAL_ANDROID_AVD_NAME=$(LOCAL_ANDROID_AVD_NAME) \
	  LOCAL_ANDROID_GPU_MODE=$(LOCAL_ANDROID_CONTAINER_GPU_MODE) \
	  	appium-emulator-avd.sh ; \
	  sleep infinity ; \
	'
.PHONY: local-android-appium-emulator-avd-restart

local-android-appium-emulator-avd-wipe-data:
	@echo "Android Emulator Wipe Data:"
	@$(LOCAL_ANDROID_CONTAINER_EXEC) bash -c ' \
		emulator -avd $(LOCAL_ANDROID_AVD_NAME) -no-snapshot-save -wipe-data \
		--gpu $(LOCAL_ANDROID_CONTAINER_GPU_MODE) ; \
	'
.PHONY: local-android-appium-emulator-avd-wipe-data

local-android-appium-emulator-avd:
	@$(LOCAL_ANDROID_CONTAINER_EXEC) appium-emulator-avd.sh
.PHONY: local-android-appium-emulator-avd

local-android-appium-container-up: local-android-appium-container-rm
	VERSION=latest $(LOCAL_ANDROID_APPIUM_DIR)/docker-compose-up.sh &
	@$(LOCAL_DOCKER_COMPOSE) logs android-appium
	@echo
	@echo Started Androïd appium display: 
	@echo Run "'make $(@:%-up=%-logs)'" to retrieve more logs
.PHONY: local-android-appium-container-up