DEV_DOCKER_COMPOSE_SERVICES += local-android-studio

ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE=$(CURDIR)/local/.containers/docker-buildx-cache/android-studio
$(ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE):;	@mkdir -p "$@"
ifneq ($(wildcard $(ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)/index.json),)
ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ = type=local,src=$(ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)
endif
ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE= type=local,dest=$(ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)
ANDROID_STUDIO_IMAGE = ${PUBLIC_IMAGES_BASE}:android-studio-latest

local-android-studio-docker-compose-up: local-android-studio-docker-compose-rm
	@VERSION=latest $(CURDIR)/local/android-studio/docker-compose-up.sh &
	@$(LOCAL_DOCKER_COMPOSE) logs android-studio
	@echo
	@echo Started Androïd studio display: 
	@echo Run "'make $(@:%-up=%-logs)'" to retrieve more logs
.PHONY: local-android-studio-docker-compose-up

LOCAL_ANDROID_STUDIO_DOCKER_COMPOSE_EXEC = $(LOCAL_DOCKER_COMPOSE) exec android-studio

local-android-studio-emulator-logs:
	@$(LOCAL_ANDROID_STUDIO_DOCKER_COMPOSE_EXEC) adb logcat -T 10
.PHONY: local-android-studio-emulator-logs

local-android-studio-appium-emulator-avd:
	@$(LOCAL_ANDROID_STUDIO_DOCKER_COMPOSE_EXEC) appium-emulator-avd.sh
.PHONY: local-android-studio-appium-emulator-avd

local-android-studio-emulator-dump: 
	@$(LOCAL_ANDROID_STUDIO_DOCKER_COMPOSE_EXEC) bash -c ' \
	  set -e ; \
	  output_dir=$(CURDIR)/local/android-studio/_emulator_dump ; \
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
.PHONY: local-android-studio-emulator-dump

local-android-studio-emulator-data-load:
	@$(LOCAL_ANDROID_STUDIO_DOCKER_COMPOSE_EXEC) \
	make -C ../.. local-android-studio-emulator-data-load-mobile-images
	@echo "Data loaded to android-studio emulator"
.PHONY: local-android-studio-emulator-data-load

local-android-studio-emulator-data-load-mobile-images:
	@bash -c ' \
	set -e ; \
	echo "Load android-studio emulator data, inputs folder : $$(pwd)" ; \
	$(CURDIR)/local/android-studio/load_tests_data.sh \
		$(CURDIR)/application/tests/mobile_images ; \
	'
.PHONY: local-android-studio-emulator-data-load-mobile-images