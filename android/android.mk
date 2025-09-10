LOCAL_ANDROID_DIR ?= $(LOCAL_DIR)/android

-include $(LOCAL_ANDROID_DIR)/emulator/emulator.mk
-include $(LOCAL_ANDROID_DIR)/flutter/flutter.mk
-include $(LOCAL_ANDROID_DIR)/appium/appium.mk
-include $(LOCAL_ANDROID_DIR)/studio/studio.mk

LOCAL_ANDROID_DOCKER_BAKE_GROUPS ?= \
  runners \
  builders \
  services

local-android-docker-images: 
	@$(MAKE) -j $(LOCAL_ANDROID_DOCKER_BAKE_GROUPS:%=local-android-%-group)
.PHONY: local-android-docker-images

$(LOCAL_ANDROID_DOCKER_BAKE_GROUPS:%=local-android-%-group): docker-buildx-setup
	@echo Showing docker images build configuration for buildx bake group $(@:%-group=%)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:%-group=%)
	@echo Building and pushing the docker images for buildx bake group $(@:%-group=%)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --load $(@:%-group=%)
.PHONY: $(LOCAL_ANDROID_DOCKER_BAKE_GROUPS:%=local-android-%-group)

local-android-docker-images-ci: $(LOCAL_ANDROID_DOCKER_BAKE_GROUPS:%=local-android-%-group-ci)
.PHONY: local-android-docker-images-ci

$(LOCAL_ANDROID_DOCKER_BAKE_GROUPS:%=local-android-%-group-ci): docker-buildx-setup
	@echo Showing CI docker images build configuration for buildx bake group $(@:%-group-ci=%-ci)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:%-group-ci=%-ci)
	@echo Building and pushing the docker images for buildx bake group $(@:%-group-ci=%-ci)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push $(@:%-group-ci=%-ci)
.PHONY: $(LOCAL_ANDROID_DOCKER_BAKE_GROUPS:%=local-android-%-group-ci)

LOCAL_ANDROID_DOCKER_BUILDX_BAKE_IMAGES ?= \
  appium \
  emulator \
  flutter \
  studio

$(LOCAL_ANDROID_DOCKER_BUILDX_BAKE_IMAGES:%=local-android-%-image): docker-buildx-setup
	@echo Showing docker images build configuration for buildx bake target $(@:%-image=%)
	$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:%-image=%)
	@echo Building and loading the docker image for buildx bake target $(@:%-image=%)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --load $(@:%-image=%)
.PHONY: $(LOCAL_ANDROID_DOCKER_BUILDX_BAKE_IMAGES:%=local-android-%-image)

$(LOCAL_ANDROID_DOCKER_BUILDX_BAKE_IMAGES:%=local-android-%-image-ci): docker-buildx-setup
	@echo Showing CI build configuration for docker bake target $(@:%-image-ci=%-ci)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:%-image-ci=%-ci)
	@echo Building and pushing the docker image for buildx bake target $(@:%-image-ci=%-ci)
	@$(LOCAL_DOCKER_BUILDX_BAKE) --push $(@:%-image-ci=%-ci)
.PHONY: $(LOCAL_ANDROID_DOCKER_BUILDX_BAKE_IMAGES:%=local-android-%-image-ci)

LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES ?= \
  studio \
  appium

$(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=android-%): 
	@echo "Starting container for android service $(@:android-%=local-%-container-up)"
	@$(MAKE) $(@:%=local-%-container-up)
.PHONY: $(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=android-%)

$(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=local-android-%-container-rm): 
	@echo "Removing container for $(@:local-%-container-rm=%)"
	@$(MAKE) $(@:%-rm=%-stop)
	@$(LOCAL_DOCKER_COMPOSE) rm -f $(@:local-%-container-rm=%)
.PHONY: $(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=local-android-%-container-rm)

$(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=local-android-%-container-start):
	@echo "Starting container for $(@:local-%-container-start=%)"
	@-$(LOCAL_DOCKER_COMPOSE) start $(@:local-%-container-start=%) 2>/dev/null
.PHONY: $(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=local-android-%-container-start)

$(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=local-android-%-container-stop):
	@echo "Stopping container for $(@:local-%-container-stop=%)"
	@-$(LOCAL_DOCKER_COMPOSE) stop $(@:local-%-container-stop=%) 2>/dev/null
.PHONY: $(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=local-android-%-container-stop)

$(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=local-android-%-container-logs):
	@echo "Viewing container logs for $(@:local-%-container-logs=%)"
	@$(LOCAL_DOCKER_COMPOSE) logs $(@:local-%-container-logs=%)
.PHONY: $(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=local-android-%-container-logs)

$(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=local-android-%-container-logs-f):
	@echo "Following container logs for $(@:local-%-container-logs-f=%)"
	@$(LOCAL_DOCKER_COMPOSE) logs --follow $(@:local-%-container-logs-f=%)
.PHONY: $(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=local-android-%-container-logs-f)

$(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=local-android-%-container-sh):
	@echo "Opening container shell for $(@:local-%-container-sh=%)"
	@$(LOCAL_DOCKER_COMPOSE) exec -it $(@:local-%-container-sh=%) bash
.PHONY: $(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=local-android-%-container-sh)

$(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=local-android-%-image-pull):
	@echo Pulling the container image for $(@:local-%-image-pull=%)
	@$(LOCAL_DOCKER_COMPOSE) pull $(@:local-%-image-pull=%)
.PHONY: $(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=local-android-%-image-pull)

local-android-docker-images-pull: $(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=local-android-%-image-pull)
.PHONY: local-android-docker-images-pull

local-android-docker-images-pull-parallel: 
	@echo Pulling all android images in parallel...
	@$(MAKE) -j local-android-docker-images-pull
.PHONY: local-android-docker-images-pull-parallel

$(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=local-android-%-image-push):
	@echo Pushing the image for $(@:local-%-image-push=%)
	@$(LOCAL_DOCKER_COMPOSE) push $(@:local-%-image-push=%)
.PHONY: $(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=local-android-%-image-push)

local-android-docker-images-push: $(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=local-android-%-image-push)
.PHONY: local-android-docker-images-push

local-android-docker-images-push-parallel: 
	@echo Pushing all android images in parallel...
	@$(MAKE) -j local-android-docker-images-push
.PHONY: local-android-docker-images-push-parallel

local-android-appium-emulator-avd-wipe-data:
	@echo "Android Studio Emulator Wipe Data:"
	@$(LOCAL_ANDROID_STUDIO) bash -c ' \
		emulator -avd $(LOCAL_ANDROID_STUDIO_ANDROID_AVD_NAME) -no-snapshot-save -wipe-data \
		--gpu $(LOCAL_ANDROID_CONTAINER_GPU_MODE) ; \
	'
.PHONY: local-android-appium-emulator-avd-wipe-data

local-android-app-sha1-fingerprint:
	@echo "Android Studio Emulator SHA1 fingerprint:" 
	@$(LOCAL_ANDROID_STUDIO) \
	  keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
.PHONY: local-android-emulator-app-sha1-fingerprint

INFRA_ENV ?= dev

LOCAL_ANDROID_RELEASE_KEYSTORE_ALIAS_NAME ?= vegito
LOCAL_ANDROID_RELEASE_KEYSTORE_STORE_PASS ?= android
LOCAL_ANDROID_RELEASE_KEYSTORE_KEY_PASS ?= android
LOCAL_ANDROID_RELEASE_KEYSTORE_PATH ?= ~/.android/release-$(INFRA_ENV).keystore

################################################################################
## 🔐 ANDROID RELEASE KEYSTORE + APK SIGNING
################################################################################

local-android-release-keystore: $(LOCAL_ANDROID_RELEASE_KEYSTORE_PATH)
.PHONY: local-android-release-keystore

$(LOCAL_ANDROID_RELEASE_KEYSTORE_PATH):
	@echo "🔐 Generating release keystore at: $(LOCAL_ANDROID_RELEASE_KEYSTORE_PATH)";
	@$(LOCAL_ANDROID_STUDIO) \
	  keytool -genkey -v \
	    -keystore $(LOCAL_ANDROID_RELEASE_KEYSTORE_PATH) \
	    -alias $(LOCAL_ANDROID_RELEASE_KEYSTORE_ALIAS_NAME) \
	    -keyalg RSA \
	    -keysize 2048 \
	    -validity 10000 \
	    -storepass $(LOCAL_ANDROID_RELEASE_KEYSTORE_STORE_PASS) \
	    -keypass $(LOCAL_ANDROID_RELEASE_KEYSTORE_KEY_PASS) \
	    -dname "CN=Vegito, OU=Dev, O=Vegito, L=Paris, S=IDF, C=FR"

LOCAL_ANDROID_APK_RELEASE_PATH ?= $(LOCAL_ANDROID_DIR)/app-release-unsigned.apk

local-android-sign-apk:
	@echo "📦 Signing APK with keystore: $(LOCAL_ANDROID_RELEASE_KEYSTORE_PATH)..."
	@$(LOCAL_ANDROID_STUDIO) \
	  jarsigner -verbose -sigalg SHA256withRSA -digestalg SHA-256 \
	    -keystore $(LOCAL_ANDROID_RELEASE_KEYSTORE_PATH) \
	    -storepass $(LOCAL_ANDROID_RELEASE_KEYSTORE_STORE_PASS) \
	    -keypass $(LOCAL_ANDROID_RELEASE_KEYSTORE_KEY_PASS) \
	    $(LOCAL_ANDROID_APK_RELEASE_PATH) $(LOCAL_ANDROID_RELEASE_KEYSTORE_ALIAS_NAME)
.PHONY: local-android-sign-apk

local-android-verify-apk:
	@echo "🔍 Verifying APK signature for: $(LOCAL_ANDROID_APK_RELEASE_PATH)..."
	@$(LOCAL_ANDROID_STUDIO) \
	  jarsigner -verify -verbose -certs $(LOCAL_ANDROID_APK_RELEASE_PATH)
.PHONY: local-android-verify-apk

local-android-align-apk:
	@echo "🧰 Aligning APK: $(LOCAL_ANDROID_APK_RELEASE_PATH)..."
	@$(LOCAL_ANDROID_STUDIO) \
	  zipalign -v 4 $(LOCAL_ANDROID_APK_RELEASE_PATH) app-release-signed-aligned.apk
.PHONY: local-android-align-apk
################################################################################

LOCAL_ANDROID_AAB_PATH ?= $(LOCAL_ANDROID_DIR)/app-release.aab

local-android-sign-aab:
	@echo "📦 Signing AAB with keystore: $(LOCAL_ANDROID_RELEASE_KEYSTORE_PATH)..."
	@$(LOCAL_ANDROID_STUDIO) \
	  jarsigner -verbose -sigalg SHA256withRSA -digestalg SHA-256 \
	    -keystore $(LOCAL_ANDROID_RELEASE_KEYSTORE_PATH) \
	    -storepass $(LOCAL_ANDROID_RELEASE_KEYSTORE_STORE_PASS) \
	    -keypass $(LOCAL_ANDROID_RELEASE_KEYSTORE_KEY_PASS) \
	    $(LOCAL_ANDROID_AAB_PATH) $(LOCAL_ANDROID_RELEASE_KEYSTORE_ALIAS_NAME)
.PHONY: local-android-sign-aab

local-android-build-release: 
	@echo "🏗️ Building unsigned APK and AAB for '$(INFRA_ENV)'..."
	@$(LOCAL_ANDROID_STUDIO) bash -c 'cd mobile && flutter build apk --flavor $(INFRA_ENV) --release'
	@$(LOCAL_ANDROID_STUDIO) bash -c 'cd mobile && flutter build appbundle --flavor $(INFRA_ENV) --release'
	@echo "📦 Signing APK..."
# 	@$(MAKE) local-android-sign-apk LOCAL_ANDROID_APK_PATH=mobile/build/app/outputs/apk/$(INFRA_ENV)/release/app-$(INFRA_ENV)-release.apk
# 	@$(MAKE) local-android-verify-apk LOCAL_ANDROID_APK_PATH=mobile/build/app/outputs/apk/$(INFRA_ENV)/release/app-$(INFRA_ENV)-release.apk
# 	@$(MAKE) local-android-align-apk LOCAL_ANDROID_APK_PATH=mobile/build/app/outputs/apk/$(INFRA_ENV)/release/app-$(INFRA_ENV)-release.apk
	@echo "📦 Signing AAB..."
	@$(MAKE) local-android-sign-aab LOCAL_ANDROID_AAB_PATH=mobile/build/app/outputs/bundle/$(INFRA_ENV)Release/app-$(INFRA_ENV)-release.aab
.PHONY: local-android-build-release