VEGITO_EXAMPLE_APPLICATION_MOBILE_DIR ?= $(VEGITO_EXAMPLE_APPLICATION_DIR)/mobile

VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_PATH ?= $(VEGITO_EXAMPLE_APPLICATION_MOBILE_DIR)/android/release-key.keystore
VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_BASE64_PATH = $(VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_PATH).base64
VEGITO_EXAMPLE_APPLICATION_MOBILE_APK_BUILDER_IMAGE ?= ${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-flutter-$(VERSION)
VEGITO_EXAMPLE_APPLICATION_MOBILE_APK_RUNNER_APPIUM_IMAGE ?= ${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-appium-$(VERSION)

example-application-mobile-container-up: example-application-mobile-container-rm
	@echo "Starting mobile application container..."
	@$(VEGITO_EXAMPLE_APPLICATION_MOBILE_DIR)/container-up.sh
.PHONY: example-application-mobile-container-up

FLUTTER ?= $(LOCAL_DOCKER_COMPOSE) exec android-studio flutter

example-application-mobile-flutter-create:
	@$(FLUTTER) create . --org $(LOCAL_ANDROID_PACKAGE_NAME) --description "Vegito Android Application" --platforms android,ios --no-pub
	@echo "Flutter application created successfully"
	@echo "Please run 'make example-application-mobile-flutter-pub-get' to install dependencies"
	@echo "You can also run 'make example-application-mobile-flutter-analyze' to analyze the code"
	@echo "To run the application, use 'make example-application-mobile-flutter-run' or 'make example-application-mobile-flutter-debug'"
	@echo "For building the application, use 'make example-application-mobile-flutter-build' followed by the desired build type (e.g., apk, ios)"
	@echo "For cleaning the project, use 'make example-application-mobile-flutter-clean'"
	@echo "For running tests, use 'make example-application-mobile-flutter-tests' or 'make example-application-mobile-flutter-tests-buildrunner' for build_runner tests"
	@echo "For uninstalling the app from the emulator, use 'make flutter-app-uninstall'"
	@echo "For preparing the app for running on the emulator, use 'make example-application-mobile-flutter-run-prepare'"
.PHONY: example-application-mobile-flutter-create

example-application-mobile-flutter-clean:
	@$(FLUTTER) clean
.PHONY: example-application-mobile-flutter-clean

example-application-mobile-flutter-pub-get: example-application-mobile-flutter-clean
	@$(FLUTTER) pub get
.PHONY: example-application-mobile-flutter-pub-get

example-application-mobile-flutter-tests:
	@$(FLUTTER) test
.PHONY: example-application-mobile-flutter-tests

example-application-mobile-flutter-tests-ci: example-application-mobile-flutter-pub-get
	@$(FLUTTER) test
.PHONY: example-application-mobile-flutter-tests-ci

DART ?= $(LOCAL_DOCKER_COMPOSE) exec android-studio dart

example-application-mobile-flutter-tests-buildrunner:
	@$(DART) run build_runner test --delete-conflicting-outputs
.PHONY: example-application-mobile-flutter-tests-buildrunner

example-application-mobile-flutter-analyze:
	@$(FLUTTER) analyze
.PHONY: example-application-mobile-flutter-analyze

ADB ?= $(LOCAL_DOCKER_COMPOSE) exec android-studio adb

flutter-app-uninstall:
	@echo "Uninstalling the app from the emulator"
	@$(ADB) uninstall dev.vegito.app.android || true
.PHONY: flutter-app-uninstall

VEGITO_EXAMPLE_APPLICATION_MOBILE_BUILDS = apk ios appbundle

example-application-mobile-flutter-build: $(VEGITO_EXAMPLE_APPLICATION_MOBILE_BUILDS:%=example-application-mobile-flutter-build-%)
.PHONY: example-application-mobile-flutter-build

$(VEGITO_EXAMPLE_APPLICATION_MOBILE_BUILDS:%=example-application-mobile-flutter-build-%-release):
	@echo "Building $(@:example-application-mobile-flutter-build-%-release=%)..."
	@$(FLUTTER) build $(@:example-application-mobile-flutter-build-%-release=%) --release
	@echo "Build for $(@:example-application-mobile-flutter-build-%-release=%) completed successfully"
.PHONY: $(VEGITO_EXAMPLE_APPLICATION_MOBILE_BUILDS:%=example-application-mobile-flutter-build-%release)

example-application-mobile-flutter-android-release: example-application-mobile-flutter-build-apk-release example-application-mobile-flutter-build-appbundle-release
.PHONY: example-application-mobile-flutter-android-release

example-application-mobile-flutter-build-release: example-application-mobile-flutter-android-release example-application-mobile-flutter-build-ios-release
.PHONY: example-application-mobile-flutter-build-release

$(VEGITO_EXAMPLE_APPLICATION_MOBILE_BUILDS:%=example-application-mobile-flutter-build-%-debug):
	@$(FLUTTER) build $(@:example-application-mobile-flutter-build-%-debug=%) --debug
	@echo "Build for $(@:example-application-mobile-flutter-build-%-debug=%) completed successfully"
.PHONY: $(VEGITO_EXAMPLE_APPLICATION_MOBILE_BUILDS:%=example-application-mobile-flutter-build-%-debug)

example-application-mobile-flutter-run-prepare: flutter-app-uninstall example-application-mobile-flutter-pub-get
.PHONY: example-application-mobile-flutter-run-prepare	

VEGITO_EXAMPLE_APPLICATION_MOBILE_FLAVORS ?= dev staging prod

example-application-mobile-flutter-native-splash:
	@echo "Creating native splash screen for flavors: $(VEGITO_EXAMPLE_APPLICATION_MOBILE_FLAVORS)"
	@$(FLUTTER) pub run flutter_native_splash:create --flavors $(VEGITO_EXAMPLE_APPLICATION_MOBILE_FLAVORS)
.PHONY: example-application-mobile-flutter-native-splash

example-application-mobile-flutter-launcher-icons:
	@echo "Creating launcher icons for flavors: $(VEGITO_EXAMPLE_APPLICATION_MOBILE_FLAVORS)"
	@$(FLUTTER) pub run flutter_launcher_icons:main
.PHONY: example-application-mobile-flutter-launcher-icons

example-application-mobile-flutter-run-flavor: example-application-mobile-flutter-run-prepare
	@echo "Running the app on the emulator with flavor $(INFRA_ENV)"
	@$(FLUTTER) run --flavor $(INFRA_ENV) --release lib/main.dart
	@echo "App is running on the emulator with flavor $(INFRA_ENV)"
.PHONY: example-application-mobile-flutter-run-flavor	

example-application-mobile-flutter-run-debug-flavor: example-application-mobile-flutter-run-prepare
	@echo "Running the app in debug mode on the emulator with flavor $(INFRA_ENV)"
	@$(FLUTTER) run --flavor $(INFRA_ENV) --debug lib/main.dart
	@echo "App is running in debug mode on the emulator with flavor $(INFRA_ENV)"
.PHONY: example-application-mobile-flutter-run-debug-flavor

VEGITO_EXAMPLE_APPLICATION_MOBILE_FIREBASE_IOS_CONFIG_PLIST = $(VEGITO_EXAMPLE_APPLICATION_MOBILE_DIR)/ios/GoogleService-Info.plist

example-application-mobile-ios-config-plist: $(VEGITO_EXAMPLE_APPLICATION_MOBILE_FIREBASE_IOS_CONFIG_PLIST)
.PHONY:example-application-mobile-ios-config-plist

$(VEGITO_EXAMPLE_APPLICATION_MOBILE_FIREBASE_IOS_CONFIG_PLIST): $(INFRA_FIREBASE_IOS_CONFIG_PLIST)
	@echo Creating local ios config copy "'$@'"
	@cp -f $< $@ 

VEGITO_EXAMPLE_APPLICATION_MOBILE_FIREBASE_ANDROID_CONFIG_JSON = $(VEGITO_EXAMPLE_APPLICATION_MOBILE_DIR)/android/app/google-services.json

example-application-mobile-default-android-config-json: $(VEGITO_EXAMPLE_APPLICATION_MOBILE_FIREBASE_ANDROID_CONFIG_JSON)
.PHONY: example-application-mobile-default-android-config-json

$(VEGITO_EXAMPLE_APPLICATION_MOBILE_FIREBASE_ANDROID_CONFIG_JSON): $(INFRA_FIREBASE_ANDROID_CONFIG_JSON)
	@echo Creating local android config copy "'$@'"
	@cp -f $< $@ 

VEGITO_EXAMPLE_APPLICATION_MOBILE_FIREBASE_FLAVOR_ANDROID_CONFIG_JSON = $(VEGITO_EXAMPLE_APPLICATION_MOBILE_DIR)/android/app/src/$(INFRA_ENV)/google-services.json

example-application-mobile-flavor-android-config-json: $(VEGITO_EXAMPLE_APPLICATION_MOBILE_FIREBASE_FLAVOR_ANDROID_CONFIG_JSON)
.PHONY: example-application-mobile-flavor-android-config-json

$(VEGITO_EXAMPLE_APPLICATION_MOBILE_FIREBASE_FLAVOR_ANDROID_CONFIG_JSON): $(INFRA_FIREBASE_ANDROID_CONFIG_JSON)
	@echo Creating local android config copy "'$@'"
	@cp -f $(INFRA_FIREBASE_ANDROID_CONFIG_JSON) $@

example-application-mobile-flutter-flavor-release:
	@echo "🏗️ Building flavor unsigned APK and AAB for '$(INFRA_ENV)'..."
	@$(MAKE) \
	  example-application-mobile-flutter-build-apk-flavor-release \
	  example-application-mobile-flutter-build-appbundle-flavor-release
.PHONY: example-application-mobile-flutter-flavor-release

LOCAL_ANDROID_RELEASE_APK_PATH ?= ${VEGITO_EXAMPLE_APPLICATION_MOBILE_DIR}/build/app/outputs/flutter-apk/app-release-$(VERSION).apk
LOCAL_ANDROID_RELEASE_AAB_PATH ?= ${VEGITO_EXAMPLE_APPLICATION_MOBILE_DIR}/build/app/outputs/bundle/release/app-release-$(VERSION).aab

LOCAL_ANDROID_APK_FLAVOR_RELEASE_PATH ?= mobile/build/app/outputs/apk/$(INFRA_ENV)/release/app-$(INFRA_ENV)-release-$(VERSION).apk
LOCAL_ANDROID_AAB_FLAVOR_RELEASE_PATH ?= mobile/build/app/outputs/bundle/$(INFRA_ENV)Release/app-$(INFRA_ENV)-release-$(VERSION).aab

example-application-mobile-flavor-release:
	@echo "📦 Signing flavor APK..."
	@$(MAKE) example-application-mobile-flutter-flavor-release \
	  LOCAL_ANDROID_RELEASE_APK_PATH=$(LOCAL_ANDROID_APK_FLAVOR_RELEASE_PATH) \
	  LOCAL_ANDROID_RELEASE_AAB_PATH=$(LOCAL_ANDROID_AAB_FLAVOR_RELEASE_PATH) \
.PHONY: example-application-mobile-flavor-release

example-application-mobile-vacuum:
	@rm -rf $(VEGITO_EXAMPLE_APPLICATION_MOBILE_DIR)/build
	@rm -rf $(VEGITO_EXAMPLE_APPLICATION_MOBILE_DIR)/.dart_tool
	@rm -rf $(VEGITO_EXAMPLE_APPLICATION_MOBILE_DIR)/.packages
	@rm -rf $(VEGITO_EXAMPLE_APPLICATION_MOBILE_DIR)/ios/Pods
	@rm -rf $(VEGITO_EXAMPLE_APPLICATION_MOBILE_DIR)/ios/Podfile.lock
	@rm -rf $(VEGITO_EXAMPLE_APPLICATION_MOBILE_DIR)/android/.gradle
	@rm -rf $(VEGITO_EXAMPLE_APPLICATION_MOBILE_DIR)/android/app/build
	@rm -rf $(VEGITO_EXAMPLE_APPLICATION_MOBILE_DIR)/android/build
	@rm -rf $(VEGITO_EXAMPLE_APPLICATION_MOBILE_DIR)/app-release-*.apk
	@rm -rf $(VEGITO_EXAMPLE_APPLICATION_MOBILE_DIR)/app-release-*.aab
	@echo "✅ Cleaned Flutter project and build artifacts"
.PHONY: example-application-mobile-vacuum

example-application-mobile-android-release-build: \
example-application-mobile-flutter-android-release \
local-android-verify-apk \
local-android-sign-aab
.PHONY: example-application-mobile-android-release-build

example-application-mobile-flutter-android-release:
	@echo "🏗️ Building unsigned APK and AAB for '$(INFRA_ENV)'..."
	@$(MAKE) \
	  example-application-mobile-vacuum \
	  example-application-mobile-flutter-pub-get \
	  example-application-mobile-flutter-build-apk-release \
	  example-application-mobile-flutter-build-appbundle-release
.PHONY: example-application-mobile-flutter-android-release

################################################################################
## 📦 ANDROID RELEASE FULL PIPELINE
################################################################################
VEGITO_EXAMPLE_APPLICATION_MOBILE_RELEASE_AAB_PATH ?= $(VEGITO_EXAMPLE_APPLICATION_MOBILE_DIR)/build/app/outputs/bundle/release/app-release.aab
VEGITO_EXAMPLE_APPLICATION_MOBILE_RELEASE_APK_PATH ?= $(VEGITO_EXAMPLE_APPLICATION_MOBILE_DIR)/build/app/outputs/flutter-apk/app-release.apk
VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_PACKAGE_NAME ?= $(INFRA_ENV).vegito.app.android
VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_KEYSTORE_ALIAS_NAME ?= vegito-local-release
VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_DNAME ?= "CN=Vegito, OU=Dev, O=Vegito, L=Paris, S=IDF, C=FR"
VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_PATH ?= $(LOCAL_ANDROID_RELEASE_KEYSTORE_PATH)

example-application-mobile-android-release:
	@LOCAL_ANDROID_RELEASE_AAB_UNSIGNED_PATH=$(VEGITO_EXAMPLE_APPLICATION_MOBILE_RELEASE_AAB_PATH) \
	LOCAL_ANDROID_RELEASE_APK_UNSIGNED_PATH=$(VEGITO_EXAMPLE_APPLICATION_MOBILE_RELEASE_APK_PATH) \
	LOCAL_ANDROID_RELEASE_KEYSTORE_PATH=$(VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_PATH) \
	$(MAKE) example-application-mobile-android-release-build
	@echo "✅ Android Release APK built, aligned, signed and verified at: $(LOCAL_ANDROID_RELEASE_APK_SIGNED_PATH)"
	@echo "✅ Android Release AAB built, signed and verified at: $(LOCAL_ANDROID_RELEASE_AAB_SIGNED_PATH)"
.PHONY: example-application-mobile-android-release

VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_ALIAS_NAME ?= vegito-local-release
VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_DNAME ?= "CN=Vegito, OU=Dev, O=Vegito, L=Paris, S=IDF, C=FR"

example-application-mobile-android-release-keystore: 
	@LOCAL_ANDROID_RELEASE_KEYSTORE_ALIAS_NAME=$(VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_KEYSTORE_ALIAS_NAME) \
	LOCAL_ANDROID_RELEASE_KEYSTORE_DNAME=$(VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_DNAME) \
	LOCAL_ANDROID_RELEASE_KEYSTORE_PATH=$(VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_PATH) \
	$(MAKE) local-android-release-keystore 
.PHONY: example-application-mobile-android-release-keystore
