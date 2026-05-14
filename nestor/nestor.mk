LOCAL_ANDROID_ADB ?= $(LOCAL_ANDROID_CONTAINER_EXEC) adb

LOCAL_NESTOR_SCREENSHOT_PATH ?= $(LOCAL_ANDROID_MOBILE_DIR)/release-$(VERSION)-screenshot.png

local-nestor-screenshot:
	@echo "Capturing screenshot from Android Emulator..."
	@$(LOCAL_ANDROID_ADB) exec-out screencap -p > $(LOCAL_NESTOR_SCREENSHOT_PATH)
	@echo "✅ Screenshot saved to $(LOCAL_NESTOR_SCREENSHOT_PATH)"
.PHONY: local-nestor-screenshot

local-nestor-wait-for-boot:
	@echo "ORIGIN LOCAL_ANDROID_CONTAINER_NAME = $(origin LOCAL_ANDROID_CONTAINER_NAME)"
	@echo "FLAVOR LOCAL_ANDROID_CONTAINER_NAME = $(flavor LOCAL_ANDROID_CONTAINER_NAME)"
	@echo "VALUE  LOCAL_ANDROID_CONTAINER_NAME = '$(LOCAL_ANDROID_CONTAINER_NAME)'"
	@echo "ORIGIN LOCAL_ANDROID_CONTAINER_EXEC = $(origin LOCAL_ANDROID_CONTAINER_EXEC)"
	@echo "VALUE  LOCAL_ANDROID_CONTAINER_EXEC = '$(LOCAL_ANDROID_CONTAINER_EXEC)'"
	@echo "ORIGIN LOCAL_ANDROID_ADB = $(origin LOCAL_ANDROID_ADB)"
	@echo "VALUE  LOCAL_ANDROID_ADB = '$(LOCAL_ANDROID_ADB)'"
	@echo "------------------------------------"
	@$(LOCAL_ANDROID_ADB) wait-for-device
	@$(LOCAL_ANDROID_ADB) shell getprop sys.boot_completed | grep -m 1 '1'
.PHONY: local-nestor-wait-for-boot

local-nestor-logs:
	@echo "Fetching last 10 lines of Android Emulator logs..."
	@$(LOCAL_ANDROID_ADB) logcat -T 10
.PHONY: local-nestor-logs

local-nestor-app-logs:
	@echo "Fetching Android Emulator application logs only..."
	PID=`$(LOCAL_ANDROID_ADB) shell pidof $(LOCAL_ANDROID_PACKAGE_NAME) 2>/dev/null` && \
	if [ -z "$$PID" ]; then \
	  echo "❌ Application $(LOCAL_ANDROID_PACKAGE_NAME) is not running"; \
	  exit 1; \
	fi && \
	echo "📌 Using PID=$$PID" && \
	$(LOCAL_ANDROID_ADB) logcat --pid=$$PID -v brief
.PHONY: local-nestor-app-logs

local-nestor-adb-devices-list:
	@echo "Listing connected Android Emulator devices..."
	@$(LOCAL_ANDROID_ADB) devices -l
.PHONY: local-nestor-adb-devices-list

local-nestor-app-uninstall:
	@echo "Uninstalling the app from the emulator"
	@$(LOCAL_ANDROID_ADB) uninstall $(LOCAL_ANDROID_PACKAGE_NAME) || true
.PHONY: local-nestor-app-uninstall

local-nestor-avd-start:
	@$(LOCAL_ANDROID_CONTAINER_EXEC) nestor-avd-start.sh
.PHONY: local-nestor-avd-start

local-nestor-avd-restart:
	@echo "Restarting android-studio emulator..."
	@echo LOCAL_ANDROID_CONTAINER_NAME=$(LOCAL_ANDROID_CONTAINER_NAME)
	@echo LOCAL_ANDROID_CONTAINER_EXEC=$(LOCAL_ANDROID_CONTAINER_EXEC)
	@echo LOCAL_ANDROID_STUDIO_DIR=$(LOCAL_ANDROID_STUDIO_DIR)
	@echo LOCAL_NESTOR_DATA_DIR=$(LOCAL_NESTOR_DATA_DIR)
	@echo LOCAL_NESTOR_DATA_DIR=$(LOCAL_NESTOR_DATA_DIR)
	@echo LOCAL_NESTOR_DATA_DIR=$(LOCAL_NESTOR_DATA_DIR)
	$(LOCAL_ANDROID_CONTAINER_EXEC) bash -c ' \
	  echo "[*] Killing emulator & adb..." ; \
	  pkill -x emulator ; \
	  pkill -x qemu-system ; \
	  pkill -x adb ; \
	  adb kill-server ; \
	  rm -rf ~/.android/avd/*/*.lock ; \
	  rm -f ~/.android/*.lock ; \
	  rm -f ~/.android/adb*.ini.lock ; \
	  adb start-server ; \
	  nestor-avd-start.sh ; \
	'
.PHONY: local-nestor-avd-restart

local-nestor-kernel:
	@echo "Showing emulator kernel..."
	@$(LOCAL_ANDROID_CONTAINER_EXEC) bash -c ' \
	  echo "[*] Showing emulator kernel..." ; \
	  emulator -avd $$LOCAL_NESTOR_AVD_NAME -no-snapshot-save -wipe-data -show-kernel ; \
	  echo "[*] Emulator kernel shown." ; \
	'
.PHONY: local-nestor-kernel

local-nestor-dump: 
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
.PHONY: local-nestor-dump

local-nestor-data-load:
	@$(LOCAL_ANDROID_CONTAINER_EXEC) \
	make -C ../.. local-nestor-data-load-mobile-images
	@echo "Data loaded to android-studio emulator"
.PHONY: local-nestor-data-load

local-nestor-data-load-mobile-images:
	@bash -c ' \
	set -e ; \
	echo "Load android-studio emulator data, inputs folder : $$(pwd)" ; \
	$(LOCAL_ANDROID_STUDIO_DIR)/emulator-data-load.sh \
		$(VEGITO_EXAMPLE_APPLICATION_DIR)/tests/mobile_images ; \
	'
.PHONY: local-nestor-data-load-mobile-images

local-nestor-app-sha1-debug-fingerprint:
	@echo "Android Studio Emulator SHA1 fingerprint:" 
	@$(LOCAL_ANDROID_CONTAINER_EXEC) \
	  keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
.PHONY: local-nestor-app-sha1-debug-fingerprint

local-nestor-app-sha1:
	@echo "Fetching SHA1 of installed APK..."
	@$(LOCAL_ANDROID_CONTAINER_EXEC) sh -c '\
	  set -e; \
	  APK_PATH=$$(adb shell pm path $(LOCAL_ANDROID_PACKAGE_NAME) | sed "s/package://"); \
	  echo "📦 APK path: $$APK_PATH"; \
	  adb pull $$APK_PATH /tmp/app.apk > /dev/null; \
	  apksigner verify --print-certs /tmp/app.apk; \
	'
.PHONY: local-nestor-app-sha1

local-nestor-crash:
	@echo "Fetching Android Emulator crash logs..."
	@$(LOCAL_ANDROID_ADB) logcat -v brief AndroidRuntime:E *:S
.PHONY: local-nestor-crash
