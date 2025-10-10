LOCAL_EXAMPLE_APPLICATION_MOBILE_DIR ?= $(LOCAL_EXAMPLE_APPLICATION_DIR)/mobile

LOCAL_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_PATH ?= $(LOCAL_EXAMPLE_APPLICATION_MOBILE_DIR)/android/release-$(INFRA_ENV).keystore
LOCAL_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_BASE64_PATH = $(LOCAL_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_PATH).base64
LOCAL_EXAMPLE_APPLICATION_MOBILE_APK_BUILDER_IMAGE ?= ${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-flutter-$(VERSION)
LOCAL_EXAMPLE_APPLICATION_MOBILE_APK_RUNNER_APPIUM_IMAGE ?= ${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-appium-$(VERSION)

local-example-application-mobile-container-up: local-example-application-mobile-container-rm
	@echo "Starting mobile application container..."
	@$(LOCAL_EXAMPLE_APPLICATION_MOBILE_DIR)/container-up.sh
.PHONY: local-example-application-mobile-container-up

FLUTTER ?= $(LOCAL_DOCKER_COMPOSE) exec android-studio flutter

local-example-application-mobile-flutter-create:
	@$(FLUTTER) create . --org $(LOCAL_ANDROID_PACKAGE_NAME) --description "Vegito Android Application" --platforms android,ios --no-pub
	@echo "Flutter application created successfully"
	@echo "Please run 'make local-example-application-mobile-flutter-pub-get' to install dependencies"
	@echo "You can also run 'make local-example-application-mobile-flutter-analyze' to analyze the code"
	@echo "To run the application, use 'make local-example-application-mobile-flutter-run' or 'make local-example-application-mobile-flutter-debug'"
	@echo "For building the application, use 'make local-example-application-mobile-flutter-build' followed by the desired build type (e.g., apk, ios)"
	@echo "For cleaning the project, use 'make local-example-application-mobile-flutter-clean'"
	@echo "For running tests, use 'make local-example-application-mobile-flutter-tests' or 'make local-example-application-mobile-flutter-tests-buildrunner' for build_runner tests"
	@echo "For uninstalling the app from the emulator, use 'make flutter-app-uninstall'"
	@echo "For preparing the app for running on the emulator, use 'make local-example-application-mobile-flutter-run-prepare'"
.PHONY: local-example-application-mobile-flutter-create

local-example-application-mobile-flutter-clean:
	@$(FLUTTER) clean
.PHONY: local-example-application-mobile-flutter-clean

local-example-application-mobile-flutter-pub-get: local-example-application-mobile-flutter-clean
	@$(FLUTTER) pub get
.PHONY: local-example-application-mobile-flutter-pub-get

local-example-application-mobile-flutter-tests:
	@$(FLUTTER) test
.PHONY: local-example-application-mobile-flutter-tests

local-example-application-mobile-flutter-tests-ci: local-example-application-mobile-flutter-pub-get
	@$(FLUTTER) test
.PHONY: local-example-application-mobile-flutter-tests-ci

DART ?= $(LOCAL_DOCKER_COMPOSE) exec android-studio dart

local-example-application-mobile-flutter-tests-buildrunner:
	@$(DART) run build_runner test --delete-conflicting-outputs
.PHONY: local-example-application-mobile-flutter-tests-buildrunner

local-example-application-mobile-flutter-analyze:
	@$(FLUTTER) analyze
.PHONY: local-example-application-mobile-flutter-analyze

ADB ?= $(LOCAL_DOCKER_COMPOSE) exec android-studio adb

flutter-app-uninstall:
	@echo "Uninstalling the app from the emulator"
	@$(ADB) uninstall dev.vegito.app.android || true
.PHONY: flutter-app-uninstall

LOCAL_EXAMPLE_APPLICATION_MOBILE_IMAGE_VERSION ?= ${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:application-mobile-${VERSION}

LOCAL_EXAMPLE_APPLICATION_MOBILE_BUILDS = apk ios appbundle

local-example-application-mobile-flutter-build: $(LOCAL_EXAMPLE_APPLICATION_MOBILE_BUILDS:%=local-example-application-mobile-flutter-build-%)
.PHONY: local-example-application-mobile-flutter-build

$(LOCAL_EXAMPLE_APPLICATION_MOBILE_BUILDS:%=local-example-application-mobile-flutter-build-%-release):
	@echo "Building $(@:local-example-application-mobile-flutter-build-%-release=%)..."
	@$(FLUTTER) build $(@:local-example-application-mobile-flutter-build-%-release=%) --release
	@echo "Build for $(@:local-example-application-mobile-flutter-build-%-release=%) completed successfully"
.PHONY: $(LOCAL_EXAMPLE_APPLICATION_MOBILE_BUILDS:%=local-example-application-mobile-flutter-build-%release)

local-example-application-mobile-flutter-android-release: local-example-application-mobile-flutter-build-apk-release local-example-application-mobile-flutter-build-appbundle-release
.PHONY: local-example-application-mobile-flutter-android-release

local-example-application-mobile-flutter-build-release: local-example-application-mobile-flutter-android-release local-example-application-mobile-flutter-build-ios-release
.PHONY: local-example-application-mobile-flutter-build-release

$(LOCAL_EXAMPLE_APPLICATION_MOBILE_BUILDS:%=local-example-application-mobile-flutter-build-%-debug):
	@$(FLUTTER) build $(@:local-example-application-mobile-flutter-build-%-debug=%) --debug
	@echo "Build for $(@:local-example-application-mobile-flutter-build-%-debug=%) completed successfully"
.PHONY: $(LOCAL_EXAMPLE_APPLICATION_MOBILE_BUILDS:%=local-example-application-mobile-flutter-build-%-debug)

local-example-application-mobile-flutter-run-prepare: flutter-app-uninstall local-example-application-mobile-flutter-pub-get
.PHONY: local-example-application-mobile-flutter-run-prepare	

LOCAL_EXAMPLE_APPLICATION_MOBILE_FLAVORS ?= dev staging prod

local-example-application-mobile-flutter-native-splash:
	@echo "Creating native splash screen for flavors: $(LOCAL_EXAMPLE_APPLICATION_MOBILE_FLAVORS)"
	@$(FLUTTER) pub run flutter_native_splash:create --flavors $(LOCAL_EXAMPLE_APPLICATION_MOBILE_FLAVORS)
.PHONY: local-example-application-mobile-flutter-native-splash

local-example-application-mobile-flutter-launcher-icons:
	@echo "Creating launcher icons for flavors: $(LOCAL_EXAMPLE_APPLICATION_MOBILE_FLAVORS)"
	@$(FLUTTER) pub run flutter_launcher_icons:main
.PHONY: local-example-application-mobile-flutter-launcher-icons

local-example-application-mobile-flutter-run-flavor: local-example-application-mobile-flutter-run-prepare
	@echo "Running the app on the emulator with flavor $(INFRA_ENV)"
	@$(FLUTTER) run --flavor $(INFRA_ENV) --release lib/main.dart
	@echo "App is running on the emulator with flavor $(INFRA_ENV)"
.PHONY: local-example-application-mobile-flutter-run-flavor	

local-example-application-mobile-flutter-run-debug-flavor: local-example-application-mobile-flutter-run-prepare
	@echo "Running the app in debug mode on the emulator with flavor $(INFRA_ENV)"
	@$(FLUTTER) run --flavor $(INFRA_ENV) --debug lib/main.dart
	@echo "App is running in debug mode on the emulator with flavor $(INFRA_ENV)"
.PHONY: local-example-application-mobile-flutter-run-debug-flavor

LOCAL_EXAMPLE_APPLICATION_MOBILE_FIREBASE_IOS_CONFIG_PLIST = $(LOCAL_EXAMPLE_APPLICATION_MOBILE_DIR)/ios/GoogleService-Info.plist

local-example-application-mobile-ios-config-plist: $(LOCAL_EXAMPLE_APPLICATION_MOBILE_FIREBASE_IOS_CONFIG_PLIST)
.PHONY:local-example-application-mobile-ios-config-plist

$(LOCAL_EXAMPLE_APPLICATION_MOBILE_FIREBASE_IOS_CONFIG_PLIST): $(INFRA_FIREBASE_IOS_CONFIG_PLIST)
	@echo Creating local ios config copy "'$@'"
	@cp -f $< $@ 

LOCAL_EXAMPLE_APPLICATION_MOBILE_FIREBASE_ANDROID_CONFIG_JSON = $(LOCAL_EXAMPLE_APPLICATION_MOBILE_DIR)/android/app/google-services.json

local-example-application-mobile-default-android-config-json: $(LOCAL_EXAMPLE_APPLICATION_MOBILE_FIREBASE_ANDROID_CONFIG_JSON)
.PHONY: local-example-application-mobile-default-android-config-json

$(LOCAL_EXAMPLE_APPLICATION_MOBILE_FIREBASE_ANDROID_CONFIG_JSON): $(INFRA_FIREBASE_ANDROID_CONFIG_JSON)
	@echo Creating local android config copy "'$@'"
	@cp -f $< $@ 

LOCAL_EXAMPLE_APPLICATION_MOBILE_FIREBASE_FLAVOR_ANDROID_CONFIG_JSON = $(LOCAL_EXAMPLE_APPLICATION_MOBILE_DIR)/android/app/src/$(INFRA_ENV)/google-services.json

local-example-application-mobile-flavor-android-config-json: $(LOCAL_EXAMPLE_APPLICATION_MOBILE_FIREBASE_FLAVOR_ANDROID_CONFIG_JSON)
.PHONY: local-example-application-mobile-flavor-android-config-json

$(LOCAL_EXAMPLE_APPLICATION_MOBILE_FIREBASE_FLAVOR_ANDROID_CONFIG_JSON): $(INFRA_FIREBASE_ANDROID_CONFIG_JSON)
	@echo Creating local android config copy "'$@'"
	@cp -f $(INFRA_FIREBASE_ANDROID_CONFIG_JSON) $@

local-example-application-mobile-flutter-flavor-release:
	@echo "🏗️ Building flavor unsigned APK and AAB for '$(INFRA_ENV)'..."
	@$(MAKE) \
	  local-example-application-mobile-flutter-build-apk-flavor-release \
	  local-example-application-mobile-flutter-build-appbundle-flavor-release
.PHONY: local-example-application-mobile-flutter-flavor-release

LOCAL_ANDROID_RELEASE_APK_PATH ?= ${LOCAL_EXAMPLE_APPLICATION_MOBILE_DIR}/build/app/outputs/flutter-apk/app-release-$(VERSION).apk
LOCAL_ANDROID_RELEASE_AAB_PATH ?= ${LOCAL_EXAMPLE_APPLICATION_MOBILE_DIR}/build/app/outputs/bundle/release/app-release-$(VERSION).aab

LOCAL_ANDROID_APK_FLAVOR_RELEASE_PATH ?= mobile/build/app/outputs/apk/$(INFRA_ENV)/release/app-$(INFRA_ENV)-release-$(VERSION).apk
LOCAL_ANDROID_AAB_FLAVOR_RELEASE_PATH ?= mobile/build/app/outputs/bundle/$(INFRA_ENV)Release/app-$(INFRA_ENV)-release-$(VERSION).aab

local-example-application-mobile-flavor-release:
	@echo "📦 Signing flavor APK..."
	@$(MAKE) local-example-application-mobile-flutter-flavor-release \
	  LOCAL_ANDROID_RELEASE_APK_PATH=$(LOCAL_ANDROID_APK_FLAVOR_RELEASE_PATH) \
	  LOCAL_ANDROID_RELEASE_AAB_PATH=$(LOCAL_ANDROID_AAB_FLAVOR_RELEASE_PATH) \
.PHONY: local-example-application-mobile-flavor-release

local-example-application-mobile-vacuum:
	@rm -rf $(LOCAL_EXAMPLE_APPLICATION_MOBILE_DIR)/build
	@rm -rf $(LOCAL_EXAMPLE_APPLICATION_MOBILE_DIR)/.dart_tool
	@rm -rf $(LOCAL_EXAMPLE_APPLICATION_MOBILE_DIR)/.packages
	@rm -rf $(LOCAL_EXAMPLE_APPLICATION_MOBILE_DIR)/ios/Pods
	@rm -rf $(LOCAL_EXAMPLE_APPLICATION_MOBILE_DIR)/ios/Podfile.lock
	@rm -rf $(LOCAL_EXAMPLE_APPLICATION_MOBILE_DIR)/android/.gradle
	@rm -rf $(LOCAL_EXAMPLE_APPLICATION_MOBILE_DIR)/android/app/build
	@rm -rf $(LOCAL_EXAMPLE_APPLICATION_MOBILE_DIR)/android/build
	@rm -rf $(LOCAL_EXAMPLE_APPLICATION_MOBILE_DIR)/app-release-*.apk
	@rm -rf $(LOCAL_EXAMPLE_APPLICATION_MOBILE_DIR)/app-release-*.aab
	@echo "✅ Cleaned Flutter project and build artifacts"
.PHONY: local-example-application-mobile-vacuum

local-example-application-mobile-android-release-build: \
local-example-application-mobile-flutter-android-release \
local-android-verify-apk \
local-android-sign-aab
.PHONY: local-example-application-mobile-android-release-build

LOCAL_EXAMPLE_APPLICATION_MOBILE_IMAGE_APK_RELEASE_EXTRACT_PATH ?= ${LOCAL_EXAMPLE_APPLICATION_MOBILE_DIR}/app-release-$(VERSION)-extract.apk

local-example-application-mobile-image-tag-apk-extract:
	@echo "Creating temp container from image $(LOCAL_EXAMPLE_APPLICATION_MOBILE_IMAGE_VERSION)"
	@container_id=$$(docker create $(LOCAL_EXAMPLE_APPLICATION_MOBILE_IMAGE_VERSION)) && \
	  echo "Copying APK from container $$container_id..." && \
	  docker cp $$container_id:/build/output/app-release-$(VERSION).apk $(LOCAL_EXAMPLE_APPLICATION_MOBILE_IMAGE_APK_RELEASE_EXTRACT_PATH) && \
	  docker rm $$container_id > /dev/null && \
	  echo "✅ APK extracted to $(LOCAL_EXAMPLE_APPLICATION_MOBILE_IMAGE_APK_RELEASE_EXTRACT_PATH)"
.PHONY: local-example-application-mobile-image-tag-apk-extract

LOCAL_EXAMPLE_APPLICATION_MOBILE_IMAGE_AAB_RELEASE_EXTRACT_PATH ?= ${LOCAL_EXAMPLE_APPLICATION_MOBILE_DIR}/app-release-$(VERSION)-extract.aab

local-example-application-mobile-image-tag-aab-extract:
	@echo "Creating temp container from image $(LOCAL_EXAMPLE_APPLICATION_MOBILE_IMAGE_VERSION)"
	@container_id=$$(docker create $(LOCAL_EXAMPLE_APPLICATION_MOBILE_IMAGE_VERSION)) && \
	  echo "Copying AAB from container $$container_id..." && \
	  docker cp $$container_id:/build/output/app-release-$(VERSION).aab $(LOCAL_EXAMPLE_APPLICATION_MOBILE_IMAGE_AAB_RELEASE_EXTRACT_PATH) && \
	  docker rm $$container_id > /dev/null && \
	  echo "✅ AAB extracted to $(LOCAL_EXAMPLE_APPLICATION_MOBILE_IMAGE_AAB_RELEASE_EXTRACT_PATH)"
.PHONY: local-example-application-mobile-image-tag-aab-extract

local-example-application-mobile-flutter-android-release:
	@echo "🏗️ Building unsigned APK and AAB for '$(INFRA_ENV)'..."
	@$(MAKE) \
	  local-example-application-mobile-vacuum \
	  local-example-application-mobile-flutter-pub-get \
	  local-example-application-mobile-flutter-build-apk-release \
	  local-example-application-mobile-flutter-build-appbundle-release
.PHONY: local-example-application-mobile-flutter-android-release

local-example-application-mobile-image-tag-release-exrtract: local-example-application-mobile-image-tag-aab-extract local-example-application-mobile-image-tag-apk-extract
.PHONY: local-example-application-mobile-image-tag-release-exrtract

################################################################################
## 📦 ANDROID RELEASE FULL PIPELINE
################################################################################
LOCAL_EXAMPLE_APPLICATION_MOBILE_RELEASE_AAB_PATH ?= $(LOCAL_EXAMPLE_APPLICATION_MOBILE_DIR)/build/app/outputs/bundle/release/app-release.aab
LOCAL_EXAMPLE_APPLICATION_MOBILE_RELEASE_APK_PATH ?= $(LOCAL_EXAMPLE_APPLICATION_MOBILE_DIR)/build/app/outputs/flutter-apk/app-release.apk
LOCAL_EXAMPLE_APPLICATION_MOBILE_ANDROID_PACKAGE_NAME ?= $(INFRA_ENV).vegito.app.android
LOCAL_EXAMPLE_APPLICATION_MOBILE_ANDROID_KEYSTORE_ALIAS_NAME ?= vegito-local-release
LOCAL_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_DNAME ?= "CN=Vegito, OU=Dev, O=Vegito, L=Paris, S=IDF, C=FR"
LOCAL_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_PATH ?= $(LOCAL_EXAMPLE_APPLICATION_MOBILE_DIR)/$(LOCAL_EXAMPLE_APPLICATION_MOBILE_ANDROID_PACKAGE_NAME)-release.android.keystore

local-example-application-mobile-android-release:
	@LOCAL_ANDROID_RELEASE_AAB_UNSIGNED_PATH=$(LOCAL_EXAMPLE_APPLICATION_MOBILE_RELEASE_AAB_PATH) \
	LOCAL_ANDROID_RELEASE_APK_UNSIGNED_PATH=$(LOCAL_EXAMPLE_APPLICATION_MOBILE_RELEASE_APK_PATH) \
	LOCAL_ANDROID_RELEASE_KEYSTORE_PATH=$(LOCAL_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_PATH) \
	$(MAKE) local-example-application-mobile-android-release-build
	@echo "✅ Android Release APK built, aligned, signed and verified at: $(LOCAL_ANDROID_RELEASE_APK_SIGNED_PATH)"
	@echo "✅ Android Release AAB built, signed and verified at: $(LOCAL_ANDROID_RELEASE_AAB_SIGNED_PATH)"
.PHONY: local-example-application-mobile-android-release

LOCAL_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_ALIAS_NAME ?= vegito-local-release
LOCAL_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_DNAME ?= "CN=Vegito, OU=Dev, O=Vegito, L=Paris, S=IDF, C=FR"

local-example-application-mobile-android-release-keystore: 
	@LOCAL_ANDROID_RELEASE_KEYSTORE_ALIAS_NAME=$(LOCAL_EXAMPLE_APPLICATION_MOBILE_ANDROID_KEYSTORE_ALIAS_NAME) \
	LOCAL_ANDROID_RELEASE_KEYSTORE_DNAME=$(LOCAL_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_DNAME) \
	LOCAL_ANDROID_RELEASE_KEYSTORE_PATH=$(LOCAL_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_PATH) \
	$(MAKE) local-android-release-keystore 
.PHONY: local-example-application-mobile-android-release-keystore



