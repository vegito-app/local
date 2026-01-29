LOCAL_ANDROID_ADB ?= $(LOCAL_ANDROID_CONTAINER_EXEC) adb

LOCAL_ANDROID_EMULATOR_SCREENSHOT_PATH ?= $(LOCAL_ANDROID_MOBILE_DIR)/release-$(VERSION)-screenshot.png

local-android-emulator-screenshot:
	@echo "Capturing screenshot from Android Emulator..."
	@$(LOCAL_ANDROID_ADB) exec-out screencap -p > $(LOCAL_ANDROID_EMULATOR_SCREENSHOT_PATH)
	@echo "✅ Screenshot saved to $(LOCAL_ANDROID_EMULATOR_SCREENSHOT_PATH)"
.PHONY: local-android-emulator-screenshot

local-android-emulator-wait-for-boot:
	@echo "ORIGIN LOCAL_ANDROID_CONTAINER_NAME = $(origin LOCAL_ANDROID_CONTAINER_NAME)"
	@echo "FLAVOR LOCAL_ANDROID_CONTAINER_NAME = $(flavor LOCAL_ANDROID_CONTAINER_NAME)"
	@echo "VALUE  LOCAL_ANDROID_CONTAINER_NAME = '$(LOCAL_ANDROID_CONTAINER_NAME)'"
	@echo "ORIGIN LOCAL_ANDROID_CONTAINER_EXEC = $(origin LOCAL_ANDROID_CONTAINER_EXEC)"
	@echo "VALUE  LOCAL_ANDROID_CONTAINER_EXEC = '$(LOCAL_ANDROID_CONTAINER_EXEC)'"
	@echo "ORIGIN LOCAL_ANDROID_ADB = $(origin LOCAL_ANDROID_ADB)"
	@echo "VALUE  LOCAL_ANDROID_ADB = '$(LOCAL_ANDROID_ADB)'"
	@echo "------------------------------------"
	@$(LOCAL_ANDROID_ADB) wait-for-device
	$(LOCAL_ANDROID_ADB) shell getprop sys.boot_completed | grep -m 1 '1'
.PHONY: local-android-emulator-wait-for-boot

local-android-emulator-logs:
	@echo "Fetching last 10 lines of Android Emulator logs..."
	@$(LOCAL_ANDROID_ADB) logcat -T 10
.PHONY: local-android-emulator-logs

local-android-emulator-app-logs:
	@echo "Fetching Android Emulator application logs only..."
	PID=`$(LOCAL_ANDROID_ADB) shell pidof $(LOCAL_ANDROID_PACKAGE_NAME) 2>/dev/null` && \
	if [ -z "$$PID" ]; then \
	  echo "❌ Application $(LOCAL_ANDROID_PACKAGE_NAME) is not running"; \
	  exit 1; \
	fi && \
	echo "📌 Using PID=$$PID" && \
	$(LOCAL_ANDROID_ADB) logcat --pid=$$PID -v brief
.PHONY: local-android-emulator-app-logs

local-android-emulator-adb-devices-list:
	@echo "Listing connected Android Emulator devices..."
	@$(LOCAL_ANDROID_ADB) devices -l
.PHONY: local-android-emulator-adb-devices-list

local-android-emulator-app-uninstall:
	@echo "Uninstalling the app from the emulator"
	@$(LOCAL_ANDROID_ADB) uninstall dev.vegito.app.android || true
.PHONY: local-android-emulator-app-uninstall

local-android-emulator-avd-start:
	@$(LOCAL_ANDROID_CONTAINER_EXEC) android-emulator-avd-start.sh
.PHONY: local-android-emulator-avd-start

local-android-emulator-avd-restart:
	@echo "Restarting android-studio emulator..."
	@echo LOCAL_ANDROID_CONTAINER_NAME=$(LOCAL_ANDROID_CONTAINER_NAME)
	@echo LOCAL_ANDROID_CONTAINER_EXEC=$(LOCAL_ANDROID_CONTAINER_EXEC)
	@echo LOCAL_ANDROID_STUDIO_DIR=$(LOCAL_ANDROID_STUDIO_DIR)
	@echo LOCAL_ANDROID_EMULATOR_DATA_DIR=$(LOCAL_ANDROID_EMULATOR_DATA_DIR)
	@echo LOCAL_ANDROID_EMULATOR_DATA_DIR=$(LOCAL_ANDROID_EMULATOR_DATA_DIR)
	@echo LOCAL_ANDROID_EMULATOR_DATA_DIR=$(LOCAL_ANDROID_EMULATOR_DATA_DIR)
	$(LOCAL_ANDROID_CONTAINER_EXEC) bash -c ' \
	  pkill -x emulator ; \
	  pkill -x qemu-system ; \
	  pkill -x adb ; \
	  adb kill-server ; \
	  rm -rf ~/.android/avd/*/*.lock ; \
	  rm -f ~/.android/*.lock ; \
	  rm -f ~/.android/adb*.ini.lock ; \
	  adb start-server ; \
	  android-emulator-avd-start.sh ; \
	'
.PHONY: local-android-emulator-avd-restart

local-android-emulator-kernel:
	@echo "Showing emulator kernel..."
	@$(LOCAL_ANDROID_CONTAINER_EXEC) bash -c ' \
	  echo "[*] Showing emulator kernel..." ; \
	  emulator -avd $(LOCAL_ANDROID_AVD_NAME) -no-snapshot-save -wipe-data -show-kernel ; \
	  echo "[*] Emulator kernel shown." ; \
	'
.PHONY: local-android-emulator-kernel

local-android-emulator-dump: 
	@$(LOCAL_ANDROID_CONTAINER_EXEC) bash -c ' \
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
	@$(LOCAL_ANDROID_CONTAINER_EXEC) \
	make -C ../.. local-android-emulator-data-load-mobile-images
	@echo "Data loaded to android-studio emulator"
.PHONY: local-android-emulator-data-load

local-android-emulator-data-load-mobile-images:
	@bash -c ' \
	set -e ; \
	echo "Load android-studio emulator data, inputs folder : $$(pwd)" ; \
	$(LOCAL_ANDROID_STUDIO_DIR)/emulator-data-load.sh \
		$(VEGITO_EXAMPLE_APPLICATION_DIR)/tests/mobile_images ; \
	'
.PHONY: local-android-emulator-data-load-mobile-images

local-android-emulator-app-sha1-debug-fingerprint:
	@echo "Android Studio Emulator SHA1 fingerprint:" 
	@$(LOCAL_ANDROID_CONTAINER_EXEC) \
	  keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
.PHONY: local-android-emulator-app-sha1-debug-fingerprint

local-android-emulator-app-sha1:
	@echo "Fetching SHA1 of installed APK..."
	@$(LOCAL_ANDROID_CONTAINER_EXEC) sh -c '\
	  set -e; \
	  APK_PATH=$$(adb shell pm path $(LOCAL_ANDROID_PACKAGE_NAME) | sed "s/package://"); \
	  echo "📦 APK path: $$APK_PATH"; \
	  adb pull $$APK_PATH /tmp/app.apk > /dev/null; \
	  apksigner verify --print-certs /tmp/app.apk; \
	'
.PHONY: local-android-emulator-app-sha1
local-android-emulator-crash:
	@echo "Fetching Android Emulator crash logs..."
	@$(LOCAL_ANDROID_ADB) logcat -v brief AndroidRuntime:E *:S
.PHONY: local-android-emulator-crash