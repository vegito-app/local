ADB = $(LOCAL_ANDROID_CONTAINER_EXEC) adb

LOCAL_ANDROID_MOBILE_SCREENSHOT_PATH ?= $(LOCAL_ANDROID_MOBILE_DIR)/release-$(VERSION)-screenshot.png

local-android-emulator-screenshot:
	@echo "Capturing screenshot from Android Emulator..."
	@$(ADB) exec-out screencap -p > $(LOCAL_ANDROID_MOBILE_SCREENSHOT_PATH)
	@echo "✅ Screenshot saved to $(LOCAL_ANDROID_MOBILE_SCREENSHOT_PATH)"
.PHONY: local-android-emulator-screenshot

local-android-emulator-wait-for-boot:
	@echo "Waiting for Android Emulator to boot..."
	@$(ADB) wait-for-device
	@$(ADB) shell getprop sys.boot_completed | grep -m 1 '1'
.PHONY: local-android-emulator-wait-for-boot

local-android-emulator-logs:
	@echo "Fetching last 10 lines of Android Emulator logs..."
	@$(ADB) logcat -T 10
.PHONY: local-android-emulator-logs

local-android-emulator-adb-devices-list:
	@echo "Listing connected Android Emulator devices..."
	@$(ADB) devices -l
.PHONY: local-android-emulator-adb-devices-list

local-android-emulator-avd-start:
	@$(LOCAL_ANDROID_BUILDER_CONTAINER_EXEC) android-emulator-avd-start.sh
.PHONY: local-android-emulator-avd-start

local-android-emulator-avd-restart:
	@echo "Restarting android-studio emulator..."
	@echo LOCAL_ANDROID_CONTAINER_NAME=$(LOCAL_ANDROID_CONTAINER_NAME)
	@echo LOCAL_ANDROID_BUILDER_CONTAINER_EXEC=$(LOCAL_ANDROID_BUILDER_CONTAINER_EXEC)
	@echo LOCAL_ANDROID_STUDIO_DIR=$(LOCAL_ANDROID_STUDIO_DIR)
	@echo LOCAL_ANDROID_EMULATOR_DATA_DIR=$(LOCAL_ANDROID_EMULATOR_DATA_DIR)
	@echo LOCAL_ANDROID_EMULATOR_DATA_DIR=$(LOCAL_ANDROID_EMULATOR_DATA_DIR)
	@echo LOCAL_ANDROID_EMULATOR_DATA_DIR=$(LOCAL_ANDROID_EMULATOR_DATA_DIR)
	$(LOCAL_ANDROID_BUILDER_CONTAINER_EXEC) bash -c ' \
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
	  	android-emulator-avd-start.sh ; \
	  sleep infinity ; \
	'
.PHONY: local-android-emulator-avd-restart
.PHONY: local-android-emulator-avd-start
local-android-emulator-kernel:
	@echo "Showing emulator kernel..."
	@$(LOCAL_ANDROID_BUILDER_CONTAINER_EXEC) bash -c ' \
	  echo "[*] Showing emulator kernel..." ; \
	  emulator -avd $(LOCAL_ANDROID_AVD_NAME) -no-snapshot-save -wipe-data -show-kernel ; \
	  echo "[*] Emulator kernel shown." ; \
	'
.PHONY: local-android-emulator-kernel

local-android-emulator-dump: 
	@$(LOCAL_ANDROID_BUILDER_CONTAINER_EXEC) bash -c ' \
	  set -e ; \
	  output_dir=$(LOCAL_ANDROID_STUDIO_DIR)/_emulator_dump ; \
	  mkdir -p $$output_dir ; \
	  cd $$output_dir ; \
	  echo Capture android-studio mobile, outputs folder : $$(pwd) ; \
	  adb shell uiautomator dump --compressed ; \
	  adb pull /sdcard/window_dump.xml ; \
	  adb shell rm /sdcard/window_dump.xml ; \
	  adb shell screencap -p /sdcard/popup.png ; \
	  adb pull /sdcard/popup.png ; \
	  adb shell rm /sdcard/popup.png ; \
	  adb shell uiautomator dump /sdcard/dump.xml ; \
	  adb pull /sdcard/dump.xml ./dump.xml ; \
	  adb shell rm /sdcard/dump.xml ; \
	  sudo chmod o+rw -R $$(pwd) ; \
	  echo "Capture android-studio mobile done, outputs folder : $$(pwd)" ; \
	'
.PHONY: local-android-emulator-dump

local-android-emulator-data-load:
	@$(LOCAL_ANDROID_BUILDER_CONTAINER_EXEC) \
	make -C ../.. local-android-emulator-data-load-mobile-images
	@echo "Data loaded to android-studio emulator"
.PHONY: local-android-emulator-data-load

local-android-emulator-data-load-mobile-images:
	@bash -c ' \
	set -e ; \
	echo "Load android-studio emulator data, inputs folder : $$(pwd)" ; \
	$(LOCAL_ANDROID_STUDIO_DIR)/emulator-data-load.sh \
		$(EXAMPLE_APPLICATION_DIR)/tests/mobile_images ; \
	'
.PHONY: local-android-emulator-data-load-mobile-images

local-android-emulator-app-sha1-fingerprint:
	@echo "Android Studio Emulator SHA1 fingerprint:" 
	$(LOCAL_ANDROID_STUDIO) \
	  keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
.PHONY: local-android-emulator-app-sha1-fingerprint
