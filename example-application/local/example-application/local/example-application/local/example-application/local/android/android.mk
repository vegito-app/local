LOCAL_ANDROID_DIR ?= $(LOCAL_DIR)/android
LOCAL_ANDROID_APK_RUNNER_EMULATOR_IMAGE ?= ${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-emulator-$(VERSION)

-include $(LOCAL_ANDROID_DIR)/appium/appium.mk
-include $(LOCAL_ANDROID_DIR)/emulator/emulator.mk
-include $(LOCAL_ANDROID_DIR)/flutter/flutter.mk
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
	@$(LOCAL_DOCKER_BUILDX_BAKE) --print $(@:%-image=%)
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
  studio

$(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=android-%): 
	@echo "Starting container for android service $(@:android-%=local-%-container-up)"
	@$(MAKE) $(@:%=local-%-container-up)
.PHONY: $(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=android-%)

$(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=local-android-%-container-rm): 
	@echo "Removing container for $(@:local-%-container-rm=%)"
	@$(MAKE) $(@:%-rm=%-stop)
	@echo 🔄 Waiting for container removal...
	@timeout=10; \
	while docker ps -a --format '{{.Names}}' | grep -q "^$(COMPOSE_PROJECT_NAME)-$(@:local-android-%-container-rm=%)-1$$" && [ $$timeout -gt 0 ]; do \
	  echo "⏳ Waiting for container removal..."; \
	  sleep 1; timeout=$$((timeout-1)); \
	done; \
	if [ $$timeout -eq 0 ]; then \
	  echo "⚠️  Timeout reached while waiting for container removal."; \
	  echo "🗑️ Forcing removal of container for $(@:local-android-%-container-rm=%)." \
	  docker container rm -f $(COMPOSE_PROJECT_NAME)-$(@:local-android-%-container-rm=%)-1 || true \
	else \
	  echo "✅ Container removed successfully."; \
	fi
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

local-android-containers-up: $(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=android-%)
.PHONY: local-android-containers-up

local-android-containers-rm: $(LOCAL_ANDROID_DOCKER_COMPOSE_SERVICES:%=local-android-%-container-rm)
.PHONY: local-android-containers-rm

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

LOCAL_ANDROID_CONTAINER_NAME ?= android-studio
LOCAL_ANDROID_CONTAINER_EXEC ?= $(LOCAL_DOCKER_COMPOSE) exec $(LOCAL_ANDROID_CONTAINER_NAME)

LOCAL_ANDROID_AVD_NAME ?= Pixel_8_Intel

local-android-app-sha1-fingerprint:
	@echo "Android Emulator SHA1 fingerprint:" 
	@$(LOCAL_ANDROID_CONTAINER_EXEC) \
	  keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
.PHONY: local-android-emulator-app-sha1-fingerprint

################################################################################
## 🔐 ANDROID RELEASE KEYSTORE
################################################################################
INFRA_ENV ?= dev

LOCAL_ANDROID_PACKAGE_NAME ?= $(INFRA_ENV).vegito.app.android
LOCAL_ANDROID_RELEASE_KEYSTORE_ALIAS_NAME ?= vegito-local-release
LOCAL_ANDROID_RELEASE_KEYSTORE_DNAME ?= CN=Vegito, OU=Dev, O=Vegito, L=Paris, S=IDF, C=FR

LOCAL_ANDROID_RELEASE_KEYSTORE_PATH ?= $(LOCAL_ANDROID_DIR)/$(LOCAL_ANDROID_PACKAGE_NAME)-release-key.keystore
LOCAL_ANDROID_RELEASE_KEYSTORE_BASE64_PATH = $(LOCAL_ANDROID_RELEASE_KEYSTORE_PATH).base64
LOCAL_ANDROID_RELEASE_KEYSTORE_STORE_PASS_BASE64_PATH = $(LOCAL_ANDROID_RELEASE_KEYSTORE_PATH).storepass.base64

local-android-release-keystore: 
	@$(MAKE) $(LOCAL_ANDROID_RELEASE_KEYSTORE_PATH)
.PHONY: local-android-release-keystore

$(LOCAL_ANDROID_RELEASE_KEYSTORE_PATH):
	@echo "🔐 Generating release keystore at: $(LOCAL_ANDROID_RELEASE_KEYSTORE_PATH)";
	@$(LOCAL_ANDROID_CONTAINER_EXEC) bash -c ' \
	  set -euo pipefail; \
	  storepass=$$(openssl rand -base64 32); \
	  echo "  - Store Password: $$storepass"; \
	  echo "  - Alias Name: $(LOCAL_ANDROID_RELEASE_KEYSTORE_ALIAS_NAME)"; \
	  echo "  - DName: $(LOCAL_ANDROID_RELEASE_KEYSTORE_DNAME)"; \
	  keytool -genkey -v \
	    -keystore $(LOCAL_ANDROID_RELEASE_KEYSTORE_PATH) \
	    -alias $(LOCAL_ANDROID_RELEASE_KEYSTORE_ALIAS_NAME) \
	    -keyalg RSA \
	    -keysize 2048 \
	    -validity 10000 \
	    -storepass $$storepass \
	    -dname "$(LOCAL_ANDROID_RELEASE_KEYSTORE_DNAME)" ; \
	  base64 $(LOCAL_ANDROID_RELEASE_KEYSTORE_PATH) > $(LOCAL_ANDROID_RELEASE_KEYSTORE_BASE64_PATH); \
	  printf "%s" "$$storepass" | base64 > $(LOCAL_ANDROID_RELEASE_KEYSTORE_STORE_PASS_BASE64_PATH) \
	'
################################################################################
## 📦 ANDROID RELEASE APK / AAB BUILD, ALIGN, SIGN, VERIFY
################################################################################
LOCAL_ANDROID_RELEASE_APK_UNSIGNED_PATH ?= $(LOCAL_ANDROID_DIR)/app-release-$(VERSION).apk
LOCAL_ANDROID_RELEASE_APK_UNSIGNED_ALIGNED_PATH ?= $(LOCAL_ANDROID_DIR)/app-release-$(VERSION)-aligned.apk
LOCAL_ANDROID_RELEASE_APK_SIGNED_ALIGNED_PATH ?= $(LOCAL_ANDROID_DIR)/app-release-$(VERSION)-signed-aligned.apk

local-android-align-apk: $(LOCAL_ANDROID_RELEASE_APK_UNSIGNED_ALIGNED_PATH)
.PHONY: local-android-verify-apk

 $(LOCAL_ANDROID_RELEASE_APK_UNSIGNED_ALIGNED_PATH): $(LOCAL_ANDROID_RELEASE_APK_UNSIGNED_PATH)
	@echo "🧰 Aligning APK: $(LOCAL_ANDROID_RELEASE_APK_UNSIGNED_PATH)..."
	@if [ -f $(LOCAL_ANDROID_RELEASE_APK_UNSIGNED_ALIGNED_PATH) ]; then rm -f $(LOCAL_ANDROID_RELEASE_APK_UNSIGNED_ALIGNED_PATH); fi
	@$(LOCAL_ANDROID_CONTAINER_EXEC) \
	  zipalign -v -p 4 $(LOCAL_ANDROID_RELEASE_APK_UNSIGNED_PATH) $(LOCAL_ANDROID_RELEASE_APK_UNSIGNED_ALIGNED_PATH)

local-android-sign-apk: $(LOCAL_ANDROID_RELEASE_APK_SIGNED_ALIGNED_PATH) 
.PHONY: local-android-sign-apksign

$(LOCAL_ANDROID_RELEASE_APK_SIGNED_ALIGNED_PATH): $(LOCAL_ANDROID_RELEASE_APK_UNSIGNED_ALIGNED_PATH)
	@echo "🔐 Signing APK with apksigner using keystore: $(LOCAL_ANDROID_RELEASE_KEYSTORE_PATH): $(LOCAL_ANDROID_RELEASE_APK_SIGNED_ALIGNED_PATH)..."
	@$(LOCAL_ANDROID_CONTAINER_EXEC) \
	  apksigner sign \
	    --ks $(LOCAL_ANDROID_RELEASE_KEYSTORE_PATH) \
	    --ks-pass pass:$(shell cat $(LOCAL_ANDROID_RELEASE_KEYSTORE_STORE_PASS_BASE64_PATH) | base64 --decode) \
	    --out $(LOCAL_ANDROID_RELEASE_APK_SIGNED_ALIGNED_PATH) \
		$(LOCAL_ANDROID_RELEASE_APK_UNSIGNED_ALIGNED_PATH)

local-android-verify-apk: $(LOCAL_ANDROID_RELEASE_APK_SIGNED_ALIGNED_PATH)
	@echo "🔍 Verifying APK signature for: $(LOCAL_ANDROID_RELEASE_APK_SIGNED_ALIGNED_PATH)..."
	@$(LOCAL_ANDROID_CONTAINER_EXEC) \
	  apksigner verify --verbose $(LOCAL_ANDROID_RELEASE_APK_SIGNED_ALIGNED_PATH)
.PHONY: local-android-verify-apk

################################################################################
## 📦 ANDROID RELEASE AAB BUILD, SIGN, VERIFY
################################################################################
LOCAL_ANDROID_RELEASE_AAB_UNSIGNED_ALIGNED_PATH ?= $(LOCAL_ANDROID_DIR)/app-release-$(VERSION)-unsigned.aab
LOCAL_ANDROID_RELEASE_AAB_SIGNED_PATH ?= $(LOCAL_ANDROID_DIR)/app-release-$(VERSION)-signed.aab

$(LOCAL_ANDROID_RELEASE_AAB_UNSIGNED_ALIGNED_PATH):
	@echo "🧰 Copying AAB: $(LOCAL_ANDROID_RELEASE_AAB_UNSIGNED_PATH)..."
	@cp  $(LOCAL_ANDROID_RELEASE_AAB_UNSIGNED_PATH) $@

local-android-sign-aab: $(LOCAL_ANDROID_RELEASE_AAB_SIGNED_PATH)
.PHONY: local-android-sign-aab

$(LOCAL_ANDROID_RELEASE_AAB_SIGNED_PATH): $(LOCAL_ANDROID_RELEASE_AAB_UNSIGNED_ALIGNED_PATH)
	@echo "📦 Signing AAB with keystore: $(LOCAL_ANDROID_RELEASE_KEYSTORE_PATH)..."
	@$(LOCAL_ANDROID_CONTAINER_EXEC) \
	  jarsigner -sigalg SHA256withRSA -digestalg SHA-256 \
	    -keystore $(LOCAL_ANDROID_RELEASE_KEYSTORE_PATH) \
	    -storepass $(shell cat $(LOCAL_ANDROID_RELEASE_KEYSTORE_STORE_PASS_BASE64_PATH) | base64 --decode) \
	    $(LOCAL_ANDROID_RELEASE_AAB_UNSIGNED_ALIGNED_PATH) $(LOCAL_ANDROID_RELEASE_KEYSTORE_ALIAS_NAME)
	@mv $(LOCAL_ANDROID_RELEASE_AAB_UNSIGNED_ALIGNED_PATH) $(LOCAL_ANDROID_RELEASE_AAB_SIGNED_PATH)

local-android-verify-aab: $(LOCAL_ANDROID_RELEASE_AAB_SIGNED_PATH)
	@echo "🔍 Verifying AAB signature for: $(LOCAL_ANDROID_RELEASE_AAB_SIGNED_PATH)..."
	@$(LOCAL_ANDROID_CONTAINER_EXEC) \
	  jarsigner -verify -verbose -certs $(LOCAL_ANDROID_RELEASE_AAB_SIGNED_PATH)
.PHONY: local-android-verify-aab

################################################################################
# ANDROID MOBILE IMAGE EXTRACTION
################################################################################
LOCAL_ANDROID_MOBILE_DIR ?= $(LOCAL_ANDROID_DIR)
LOCAL_ANDROID_MOBILE_IMAGE_APK_RELEASE_EXTRACT_PATH ?= ${LOCAL_ANDROID_MOBILE_DIR}/app-release-$(VERSION)-extract.apk
LOCAL_ANDROID_MOBILE_IMAGE ?= ${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:application-mobile-${VERSION}

local-android-mobile-image-tag-apk-extract:
	@echo "Creating temp container from image $(LOCAL_ANDROID_MOBILE_IMAGE)"
	@container_id=$$(docker create $(LOCAL_ANDROID_MOBILE_IMAGE)) && \
	  echo "Copying APK from container $$container_id..." && \
	  docker cp $$container_id:/build/output/app-release-$(VERSION).apk $(LOCAL_ANDROID_MOBILE_IMAGE_APK_RELEASE_EXTRACT_PATH) && \
	  docker rm $$container_id > /dev/null && \
	  echo "✅ APK extracted to $(LOCAL_ANDROID_MOBILE_IMAGE_APK_RELEASE_EXTRACT_PATH)"
.PHONY: local-android-mobile-image-tag-apk-extract

LOCAL_ANDROID_MOBILE_IMAGE_AAB_RELEASE_EXTRACT_PATH ?= ${LOCAL_ANDROID_MOBILE_DIR}/app-release-$(VERSION)-extract.aab

local-android-mobile-image-tag-aab-extract:
	@echo "Creating temp container from image $(LOCAL_ANDROID_MOBILE_IMAGE)"
	@container_id=$$(docker create $(LOCAL_ANDROID_MOBILE_IMAGE)) && \
	  echo "Copying AAB from container $$container_id..." && \
	  docker cp $$container_id:/build/output/app-release-$(VERSION).aab $(LOCAL_ANDROID_MOBILE_IMAGE_AAB_RELEASE_EXTRACT_PATH) && \
	  docker rm $$container_id > /dev/null && \
	  echo "✅ AAB extracted to $(LOCAL_ANDROID_MOBILE_IMAGE_AAB_RELEASE_EXTRACT_PATH)"
.PHONY: local-android-mobile-image-tag-aab-extract

LOCAL_ANDROID_MOBILE_KEYSTORE_SHA1_EXTRACT_PATH ?= ${LOCAL_ANDROID_MOBILE_DIR}/release-${VERSION}-key.keystore.sha1

local-android-mobile-image-tag-keystore-sha1-extract:
	@echo "Creating temp container from image $(LOCAL_ANDROID_MOBILE_IMAGE)"
	@container_id=$$(docker create $(LOCAL_ANDROID_MOBILE_IMAGE)) && \
	  echo "Copying keystore SHA1 from container $$container_id..." && \
	  docker cp $$container_id:/build/output/app-release-${VERSION}-key.keystore.sha1 $(LOCAL_ANDROID_MOBILE_KEYSTORE_SHA1_EXTRACT_PATH) && \
	  docker rm $$container_id > /dev/null && \
	  echo "✅ Keystore SHA1 extracted to $(LOCAL_ANDROID_MOBILE_KEYSTORE_SHA1_EXTRACT_PATH)"
.PHONY: local-android-mobile-image-tag-keystore-sha1-extract

local-android-mobile-image-tag-release-extract: \
local-android-mobile-image-tag-aab-extract \
local-android-mobile-image-tag-apk-extract \
local-android-mobile-image-tag-keystore-sha1-extract
.PHONY: local-android-mobile-image-tag-release-extract
