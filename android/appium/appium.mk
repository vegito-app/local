LOCAL_ANDROID_APPIUM_DIR ?= $(LOCAL_ANDROID_DIR)/appium
LOCAL_ANDROID_APPIUM_IMAGE_DOCKER_BUILDX_LOCAL_CACHE ?= $(LOCAL_ANDROID_APPIUM_DIR)/.containers/docker-buildx-cache/android-appium
$(LOCAL_ANDROID_APPIUM_IMAGE_DOCKER_BUILDX_LOCAL_CACHE):;	@mkdir -p "$@"
ifneq ($(wildcard $(LOCAL_ANDROID_APPIUM_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)/index.json),)
LOCAL_ANDROID_APPIUM_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ = type=local,src=$(LOCAL_ANDROID_APPIUM_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)
endif
LOCAL_ANDROID_APPIUM_IMAGE_DOCKER_BUILDX_CACHE_WRITE= type=local,mode=max,dest=$(LOCAL_ANDROID_APPIUM_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)
LOCAL_ANDROID_APPIUM_IMAGE_LATEST ?= $(VEGITO_LOCAL_PUBLIC_IMAGES_BASE):android-appium-latest

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
	  LOCAL_ANDROID_GPU_MODE=$(LOCAL_ANDROID_CONTAINER_GPU_MODE) \
	  	appium-emulator-avd.sh ; \
	  sleep infinity ; \
	'
.PHONY: local-android-appium-emulator-avd-restart

local-android-appium-emulator-avd:
	@$(LOCAL_ANDROID_STUDIO) appium-emulator-avd.sh
.PHONY: local-android-appium-emulator-avd

local-android-appium-container-up: local-android-appium-container-rm
	VERSION=latest $(LOCAL_ANDROID_APPIUM_DIR)/docker-compose-up.sh &
	@$(LOCAL_DOCKER_COMPOSE) logs android-appium
	@echo
	@echo Started Androïd appium display: 
	@echo Run "'make $(@:%-up=%-logs)'" to retrieve more logs
.PHONY: local-android-appium-container-up