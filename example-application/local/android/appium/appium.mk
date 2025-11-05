LOCAL_ANDROID_APPIUM_DIR ?= $(LOCAL_ANDROID_DIR)/appium

local-android-appium-container-up: local-android-appium-container-rm
	@VERSION=latest $(LOCAL_ANDROID_APPIUM_DIR)/container-up.sh
.PHONY: local-android-appium-container-up