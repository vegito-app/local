################################################################################
# ANDROID HIGH LEVEL TARGETS
################################################################################
VEGITO_MOBILE_CONTAINER_NAME = example-application-mobile
VEGITO_ANDROID_STUDIO_CONTAINER_NAME = android-studio

################################################################################
# ANDROID LOGS
################################################################################
android-logs: local-android-emulator-logs
.PHONY: android-logs

android-logs-mobile:
	@echo "Fetching last 10 lines of Android Mobile logs..."
	@$(MAKE) android-logs \
	  LOCAL_ANDROID_CONTAINER_NAME=$(VEGITO_MOBILE_CONTAINER_NAME)
.PHONY: android-logs-mobile
################################################################################
# ANDROID FLUTTER (APPLICATION-LEVEL) LOGS
################################################################################
android-flutter-logs:
	@echo "📱 Fetching Android Flutter application logs ($(VEGITO_ANDROID_STUDIO_CONTAINER_NAME))..."
	@$(MAKE) local-android-emulator-app-logs
.PHONY: android-flutter-logs

android-flutter-logs-mobile:
	@echo "📱 Fetching Android Flutter application logs ($(VEGITO_MOBILE_CONTAINER_NAME))..."
	@$(MAKE) local-android-emulator-app-logs \
	  LOCAL_ANDROID_CONTAINER_NAME=$(VEGITO_MOBILE_CONTAINER_NAME)
.PHONY: android-flutter-logs-mobile
################################################################################
# ANDROID DEVICES LIST
################################################################################
android-devices: local-android-emulator-adb-devices-list
.PHONY: android-devices

android-devices-mobile:
	@echo "Listing connected Android Mobile devices..."
	@$(MAKE) android-devices \
	  LOCAL_ANDROID_CONTAINER_NAME=$(VEGITO_MOBILE_CONTAINER_NAME)
.PHONY: android-devices-mobile
################################################################################
# ANDROID CRASH LOGS
################################################################################
android-crash: local-android-emulator-crash
.PHONY: android-crash

android-crash-mobile:
	@echo "Fetching Android Mobile crash logs..."
	@$(MAKE) android-crash \
	  LOCAL_ANDROID_CONTAINER_NAME=$(VEGITO_MOBILE_CONTAINER_NAME)
.PHONY: android-crash-mobile
################################################################################
# ANDROID APP SHA1
################################################################################
android-app-sha1: local-android-emulator-app-sha1
.PHONY: android-app-sha1

android-app-sha1-mobile:
	@echo "Fetching SHA1 of installed APK on Mobile..."
	@$(MAKE) android-app-sha1 \
	  LOCAL_ANDROID_CONTAINER_NAME=$(VEGITO_MOBILE_CONTAINER_NAME)
.PHONY: android-app-sha1-mobile
################################################################################
# ANDROID AVD RESTART
################################################################################
android-avd-restart:
	@echo "Restarting Android Emulator AVD ($(VEGITO_ANDROID_STUDIO_CONTAINER_NAME))..."
	@$(MAKE) local-android-emulator-avd-restart
.PHONY: android-avd-restart

android-avd-restart-mobile:
	@echo "Restarting Android Emulator AVD ($(VEGITO_MOBILE_CONTAINER_NAME))..."
	@$(MAKE) local-android-emulator-avd-restart \
	  LOCAL_ANDROID_CONTAINER_NAME=$(VEGITO_MOBILE_CONTAINER_NAME)
.PHONY: android-avd-restart-mobile
################################################################################
# ANDROID APPLICATION WAIT FOR BOOT
################################################################################
android-vegito-wait-for-boot: local-android-emulator-wait-for-boot
.PHONY: android-vegito-wait-for-boot

android-vegito-wait-for-boot-mobile:
	@echo "Waiting for Android Emulator Mobile application to boot..."
	@$(MAKE) android-vegito-wait-for-boot \
	  LOCAL_ANDROID_CONTAINER_NAME=$(VEGITO_MOBILE_CONTAINER_NAME)
.PHONY: android-vegito-wait-for-boot-mobile
################################################################################
# ANDROID HELP
################################################################################
android-help:
	@echo ""
	@echo "📱 Android commands:"
	@echo "  make android-logs            # logs ($(VEGITO_ANDROID_STUDIO_CONTAINER_NAME))"
	@echo "  make android-logs-mobile     # logs ($(VEGITO_MOBILE_CONTAINER_NAME))"
	@echo "  make android-crash-mobile    # crash only"
	@echo "  make android-app-sha1-mobile # SHA1 APK installed"
	@echo "  make android-devices-mobile  # list connected devices"
	@echo "  make android-avd-restart-mobile # restart AVD"
	@echo "  make android-vegito-wait-for-boot-mobile # wait for
	@echo ""
.PHONY: android-help