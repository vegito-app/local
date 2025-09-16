LOCAL_APPLICATION_MOBILE_DIR ?= $(LOCAL_APPLICATION_DIR)/mobile

LOCAL_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_PATH ?= $(LOCAL_APPLICATION_MOBILE_DIR)/android/release-$(INFRA_ENV).keystore
LOCAL_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_BASE64_PATH ?= $(LOCAL_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_PATH).base64

LOCAL_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_STORE_PASS_BASE64_PATH ?= $(LOCAL_APPLICATION_MOBILE_DIR)/android/release-$(INFRA_ENV).storepass.base64

local-application-mobile-container-up: local-application-mobile-container-rm
	@$(LOCAL_APPLICATION_MOBILE_DIR)/docker-compose-up.sh &
	@for i in 5037 5900; do \
		until nc -z application-mobile $$i ; do \
			echo "Waiting for application-mobile on port $$i..." ; \
			sleep 1 ; \
		done ; \
	done
	@$(LOCAL_DOCKER_COMPOSE) logs mobile
	@echo
	@echo Started Application Mobile: 
	@echo Use VNC to view UI at http://127.0.0.1:5900
	@echo Run "'make $(@:%-up=%-logs)'" to retrieve more logs
.PHONY: local-application-mobile-container-up

FLUTTER ?= $(LOCAL_DOCKER_COMPOSE) exec android-studio flutter

local-application-mobile-flutter-create:
	@$(FLUTTER) create . --org $(LOCAL_ANDROID_PACKAGE_NAME) --description "Vegito Android Application" --platforms android,ios --no-pub
	@echo "Flutter application created successfully"
	@echo "Please run 'make local-application-mobile-flutter-pub-get' to install dependencies"
	@echo "You can also run 'make local-application-mobile-flutter-analyze' to analyze the code"
	@echo "To run the application, use 'make local-application-mobile-flutter-run' or 'make local-application-mobile-flutter-debug'"
	@echo "For building the application, use 'make local-application-mobile-flutter-build' followed by the desired build type (e.g., apk, ios)"
	@echo "For cleaning the project, use 'make local-application-mobile-flutter-clean'"
	@echo "For running tests, use 'make local-application-mobile-flutter-tests' or 'make local-application-mobile-flutter-tests-buildrunner' for build_runner tests"
	@echo "For uninstalling the app from the emulator, use 'make flutter-app-uninstall'"
	@echo "For preparing the app for running on the emulator, use 'make local-application-mobile-flutter-run-prepare'"
.PHONY: local-application-mobile-flutter-create

local-application-mobile-flutter-clean:
	@$(FLUTTER) clean
.PHONY: local-application-mobile-flutter-clean

local-application-mobile-flutter-pub-get: local-application-mobile-flutter-clean
	@$(FLUTTER) pub get
.PHONY: local-application-mobile-flutter-pub-get

local-application-mobile-flutter-tests:
	@$(FLUTTER) test
.PHONY: local-application-mobile-flutter-tests

local-application-mobile-flutter-tests-ci: local-application-mobile-flutter-pub-get
	@$(FLUTTER) test
.PHONY: local-application-mobile-flutter-tests-ci

DART ?= $(LOCAL_DOCKER_COMPOSE) exec android-studio dart

local-application-mobile-flutter-tests-buildrunner:
	@$(DART) run build_runner test --delete-conflicting-outputs
.PHONY: local-application-mobile-flutter-tests-buildrunner

local-application-mobile-flutter-analyze:
	@$(FLUTTER) analyze
.PHONY: local-application-mobile-flutter-analyze

ADB ?= $(LOCAL_DOCKER_COMPOSE) exec android-studio adb

flutter-app-uninstall:
	@echo "Uninstalling the app from the emulator"
	@$(ADB) uninstall dev.vegito.app.android || true
.PHONY: flutter-app-uninstall

LOCAL_APPLICATION_MOBILE_IMAGE_VERSION ?= ${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:application-mobile-${VERSION}

LOCAL_APPLICATION_MOBILE_BUILDS = apk ios appbundle

local-application-mobile-flutter-build: $(LOCAL_APPLICATION_MOBILE_BUILDS:%=local-application-mobile-flutter-build-%)
.PHONY: local-application-mobile-flutter-build

$(LOCAL_APPLICATION_MOBILE_BUILDS:%=local-application-mobile-flutter-build-%-release):
	$(FLUTTER) build $(@:local-application-mobile-flutter-build-%-release=%) --release
	@echo "Build for $(@:local-application-mobile-flutter-build-%-release=%) completed successfully"
.PHONY: $(LOCAL_APPLICATION_MOBILE_BUILDS:%=local-application-mobile-flutter-build-%release)

local-application-mobile-flutter-android-release: local-application-mobile-flutter-build-apk-release local-application-mobile-flutter-build-appbundle-release
.PHONY: local-application-mobile-flutter-android-release

local-application-mobile-flutter-build-release: local-application-mobile-flutter-android-release local-application-mobile-flutter-build-ios-release
.PHONY: local-application-mobile-flutter-build-release

$(LOCAL_APPLICATION_MOBILE_BUILDS:%=local-application-mobile-flutter-%):
	@$(FLUTTER) build $(@:local-application-mobile-flutter-%=%) --debug
	@echo "Build for $(@:local-application-mobile-flutter-%=%) completed successfully"
.PHONY: $(LOCAL_APPLICATION_MOBILE_BUILDS:%=local-application-mobile-flutter-%)

local-application-mobile-flutter-run-prepare: flutter-app-uninstall local-application-mobile-flutter-pub-get
.PHONY: local-application-mobile-flutter-run-prepare	

LOCAL_APPLICATION_MOBILE_FLAVORS ?= dev staging prod

local-application-mobile-flutter-native-splash:
	@echo "Creating native splash screen for flavors: $(LOCAL_APPLICATION_MOBILE_FLAVORS)"
	@$(FLUTTER) pub run flutter_native_splash:create --flavors $(LOCAL_APPLICATION_MOBILE_FLAVORS)
.PHONY: local-application-mobile-flutter-native-splash

local-application-mobile-flutter-launcher-icons:
	@echo "Creating launcher icons for flavors: $(LOCAL_APPLICATION_MOBILE_FLAVORS)"
	@$(FLUTTER) pub run flutter_launcher_icons:main
.PHONY: local-application-mobile-flutter-launcher-icons

local-application-mobile-flutter-run-flavor: local-application-mobile-flutter-run-prepare
	@echo "Running the app on the emulator with flavor $(INFRA_ENV)"
	@$(FLUTTER) run --flavor $(INFRA_ENV) --release lib/main.dart
	@echo "App is running on the emulator with flavor $(INFRA_ENV)"
.PHONY: local-application-mobile-flutter-run-flavor	

local-application-mobile-flutter-run-debug-flavor: local-application-mobile-flutter-run-prepare
	@echo "Running the app in debug mode on the emulator with flavor $(INFRA_ENV)"
	@$(FLUTTER) run --flavor $(INFRA_ENV) --debug lib/main.dart
	@echo "App is running in debug mode on the emulator with flavor $(INFRA_ENV)"
.PHONY: local-application-mobile-flutter-run-debug-flavor

LOCAL_APPLICATION_MOBILE_FIREBASE_IOS_CONFIG_PLIST = $(LOCAL_APPLICATION_MOBILE_DIR)/ios/GoogleService-Info.plist

local-application-mobile-ios-config-plist: $(LOCAL_APPLICATION_MOBILE_FIREBASE_IOS_CONFIG_PLIST)
.PHONY:local-application-mobile-ios-config-plist

$(LOCAL_APPLICATION_MOBILE_FIREBASE_IOS_CONFIG_PLIST): $(INFRA_FIREBASE_IOS_CONFIG_PLIST)
	@echo Creating local ios config copy "'$@'"
	@cp -f $< $@ 

LOCAL_APPLICATION_MOBILE_FIREBASE_ANDROID_CONFIG_JSON = $(LOCAL_APPLICATION_MOBILE_DIR)/android/app/google-services.json

local-application-mobile-default-android-config-json: $(LOCAL_APPLICATION_MOBILE_FIREBASE_ANDROID_CONFIG_JSON)
.PHONY: local-application-mobile-default-android-config-json

$(LOCAL_APPLICATION_MOBILE_FIREBASE_ANDROID_CONFIG_JSON): $(INFRA_FIREBASE_ANDROID_CONFIG_JSON)
	@echo Creating local android config copy "'$@'"
	@cp -f $< $@ 

LOCAL_APPLICATION_MOBILE_FIREBASE_FLAVOR_ANDROID_CONFIG_JSON = $(LOCAL_APPLICATION_MOBILE_DIR)/android/app/src/$(INFRA_ENV)/google-services.json

local-application-mobile-flavor-android-config-json: $(LOCAL_APPLICATION_MOBILE_FIREBASE_FLAVOR_ANDROID_CONFIG_JSON)
.PHONY: local-application-mobile-flavor-android-config-json

$(LOCAL_APPLICATION_MOBILE_FIREBASE_FLAVOR_ANDROID_CONFIG_JSON): $(INFRA_FIREBASE_ANDROID_CONFIG_JSON)
	@echo Creating local android config copy "'$@'"
	@cp -f $(INFRA_FIREBASE_ANDROID_CONFIG_JSON) $@

local-application-mobile-flutter-flavor-release:
	@echo "🏗️ Building flavor unsigned APK and AAB for '$(INFRA_ENV)'..."
	@$(MAKE) \
	  local-application-mobile-flutter-build-apk-flavor-release \
	  local-application-mobile-flutter-build-appbundle-flavor-release
.PHONY: local-application-mobile-flutter-flavor-release

LOCAL_ANDROID_RELEASE_APK_PATH ?= ${LOCAL_APPLICATION_MOBILE_DIR}/build/app/outputs/flutter-apk/app-release-$(VERSION).apk
LOCAL_ANDROID_RELEASE_AAB_PATH ?= ${LOCAL_APPLICATION_MOBILE_DIR}/build/app/outputs/bundle/release/app-release-$(VERSION).aab

LOCAL_ANDROID_APK_FLAVOR_RELEASE_PATH ?= mobile/build/app/outputs/apk/$(INFRA_ENV)/release/app-$(INFRA_ENV)-release-$(VERSION).apk
LOCAL_ANDROID_AAB_FLAVOR_RELEASE_PATH ?= mobile/build/app/outputs/bundle/$(INFRA_ENV)Release/app-$(INFRA_ENV)-release-$(VERSION).aab

local-application-mobile-flavor-release:
	@echo "📦 Signing flavor APK..."
	@$(MAKE) local-application-mobile-flutter-flavor-release \
	  LOCAL_ANDROID_RELEASE_APK_PATH=$(LOCAL_ANDROID_APK_FLAVOR_RELEASE_PATH) \
	  LOCAL_ANDROID_RELEASE_AAB_PATH=$(LOCAL_ANDROID_AAB_FLAVOR_RELEASE_PATH) \
.PHONY: local-application-mobile-flavor-release

local-application-mobile-vacuum:
	@rm -rf $(LOCAL_APPLICATION_MOBILE_DIR)/build
	@rm -rf $(LOCAL_APPLICATION_MOBILE_DIR)/.dart_tool
	@rm -rf $(LOCAL_APPLICATION_MOBILE_DIR)/.packages
	@rm -rf $(LOCAL_APPLICATION_MOBILE_DIR)/ios/Pods
	@rm -rf $(LOCAL_APPLICATION_MOBILE_DIR)/ios/Podfile.lock
	@rm -rf $(LOCAL_APPLICATION_MOBILE_DIR)/android/.gradle
	@rm -rf $(LOCAL_APPLICATION_MOBILE_DIR)/android/app/build
	@rm -rf $(LOCAL_APPLICATION_MOBILE_DIR)/android/build
	@rm -rf $(LOCAL_APPLICATION_MOBILE_DIR)/app-release-*.apk
	@rm -rf $(LOCAL_APPLICATION_MOBILE_DIR)/app-release-*.aab
	@echo "✅ Cleaned Flutter project and build artifacts"
.PHONY: local-application-mobile-vacuum

local-application-mobile-android-release: \
local-application-mobile-flutter-android-release \
local-android-sign-apk \
local-android-verify-apk \
local-android-align-apk \
local-android-sign-aab
.PHONY: local-application-mobile-android-release

LOCAL_APPLICATION_MOBILE_IMAGE_APK_RELEASE_EXTRACT_PATH ?= ${LOCAL_APPLICATION_MOBILE_DIR}/app-release-$(VERSION)-extract.apk

local-application-mobile-image-tag-apk-extract:
	@echo "Creating temp container from image $(LOCAL_APPLICATION_MOBILE_IMAGE_VERSION)"
	@container_id=$$(docker create $(LOCAL_APPLICATION_MOBILE_IMAGE_VERSION)) && \
	  echo "Copying APK from container $$container_id..." && \
	  docker cp $$container_id:/build/output/app-release.apk $(LOCAL_APPLICATION_MOBILE_IMAGE_APK_RELEASE_EXTRACT_PATH) && \
	  docker rm $$container_id > /dev/null && \
	  echo "✅ APK extracted to $(LOCAL_APPLICATION_MOBILE_IMAGE_APK_RELEASE_EXTRACT_PATH)"
.PHONY: local-application-mobile-image-tag-apk-extract

LOCAL_APPLICATION_MOBILE_IMAGE_AAB_RELEASE_PATH ?= ${LOCAL_APPLICATION_MOBILE_DIR}/app-release-$(VERSION).aab

local-application-mobile-image-tag-aab-extract:
	@echo "Creating temp container from image $(LOCAL_APPLICATION_MOBILE_IMAGE_VERSION)"
	@container_id=$$(docker create $(LOCAL_APPLICATION_MOBILE_IMAGE_VERSION)) && \
	  echo "Copying AAB from container $$container_id..." && \
	  docker cp $$container_id:/build/output/app-release.aab $(LOCAL_APPLICATION_MOBILE_IMAGE_AAB_RELEASE_PATH) && \
	  docker rm $$container_id > /dev/null && \
	  echo "✅ AAB extracted to $(LOCAL_APPLICATION_MOBILE_IMAGE_AAB_RELEASE_PATH)"
.PHONY: local-application-mobile-image-tag-aab-extract

local-application-mobile-flutter-android-release:
	@echo "🏗️ Building unsigned APK and AAB for '$(INFRA_ENV)'..."
	@$(MAKE) \
	  local-application-mobile-vacuum \
	  local-application-mobile-flutter-pub-get \
	  local-application-mobile-flutter-build-apk-release \
	  local-application-mobile-flutter-build-appbundle-release
.PHONY: local-application-mobile-flutter-android-release

local-application-mobile-image-tag-release: 
	@echo "📦 Signing APK and AAB from image $(LOCAL_APPLICATION_MOBILE_IMAGE_VERSION)..."
	@$(MAKE) \
	  local-application-mobile-image-tag-aab-extract \
	  local-application-mobile-image-tag-apk-extract \
	  local-android-sign-apk \
	  local-android-verify-apk \
	  local-android-align-apk \
	  local-android-sign-aab
.PHONY: local-application-mobile-image-tag-release