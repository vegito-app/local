LOCAL_APPLICATION_MOBILE_DIR ?= $(LOCAL_APPLICATION_DIR)/mobile

LOCAL_APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_CACHE ?= $(LOCAL_APPLICATION_MOBILE_DIR)/.containers/docker-buildx-cache/local-application-mobile
$(LOCAL_APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_CACHE):;	@mkdir -p "$@"
ifneq ($(wildcard $(LOCAL_APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_CACHE)/index.json),)
LOCAL_APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ = type=local,src=$(LOCAL_APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_CACHE)
endif
LOCAL_APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_CACHE_WRITE= type=local,mode=max,dest=$(LOCAL_APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_CACHE)
LOCAL_APPLICATION_MOBILE_IMAGE_LATEST ?= $(VEGITO_LOCAL_PUBLIC_IMAGES_BASE):local-application-mobile-latest

-include $(LOCAL_APPLICATION_MOBILE_DIR)/android/android.mk

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

LOCAL_APPLICATION_MOBILE_ANDROID_PACKAGE_NAME ?= $(INFRA_ENV).vegito.app.android

local-application-mobile-flutter-create:
	@$(FLUTTER) create . --org $(LOCAL_APPLICATION_MOBILE_ANDROID_PACKAGE_NAME) --description "Vegito Android Application" --platforms android,ios --no-pub
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

LOCAL_APPLICATION_MOBILE_BUILDS = apk ios

local-application-mobile-flutter-build: $(LOCAL_APPLICATION_MOBILE_BUILDS:%=local-application-mobile-flutter-build-%)
.PHONY: local-application-mobile-flutter-build

$(LOCAL_APPLICATION_MOBILE_BUILDS:%=local-application-mobile-flutter-build-%release): local-application-mobile-flutter-pub-get
	@$(FLUTTER) build $(@:local-application-mobile-flutter-build-%=%) --release
	@echo "Build for $(@:local-application-mobile-flutter-build-%=%) completed successfully"
.PHONY: $(LOCAL_APPLICATION_MOBILE_BUILDS:%=local-application-mobile-flutter-build-%release)

local-application-mobile-flutter-build-release: $(LOCAL_APPLICATION_MOBILE_BUILDS:%=local-application-mobile-flutter-build-%-release)
.PHONY: local-application-mobile-flutter-build-release

$(LOCAL_APPLICATION_MOBILE_BUILDS:%=local-application-mobile-flutter-build-%): local-application-mobile-flutter-pub-get
	@$(FLUTTER) build $(@:local-application-mobile-flutter-build-%=%) --debug
	@echo "Build for $(@:local-application-mobile-flutter-build-%=%) completed successfully"
.PHONY: $(LOCAL_APPLICATION_MOBILE_BUILDS:%=local-application-mobile-flutter-build-%)

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

LOCAL_APPLICATION_MOBILE_DEFAULT_FIREBASE_IOS_CONFIG_PLIST = $(LOCAL_APPLICATION_DIR)/mobile/ios/GoogleService-Info.plist

local-application-mobile-ios-config-plist: $(LOCAL_APPLICATION_MOBILE_DEFAULT_FIREBASE_IOS_CONFIG_PLIST)
.PHONY:local-application-mobile-ios-config-plist

$(LOCAL_APPLICATION_MOBILE_DEFAULT_FIREBASE_IOS_CONFIG_PLIST): $(INFRA_FIREBASE_IOS_CONFIG_PLIST)
	@echo Creating local ios config copy "'$@'"
	@cp -f $< $@ 

LOCAL_APPLICATION_MOBILE_DEFAULT_FIREBASE_ANDROID_CONFIG_JSON = $(LOCAL_APPLICATION_DIR)/mobile/android/app/google-services.json

local-application-mobile-default-android-config-json: $(LOCAL_APPLICATION_MOBILE_DEFAULT_FIREBASE_ANDROID_CONFIG_JSON)
.PHONY: local-application-mobile-default-android-config-json

$(LOCAL_APPLICATION_MOBILE_DEFAULT_FIREBASE_ANDROID_CONFIG_JSON): $(INFRA_FIREBASE_ANDROID_CONFIG_JSON)
	@echo Creating local android config copy "'$@'"
	@cp -f $< $@ 

LOCAL_APPLICATION_MOBILE_FIREBASE_ANDROID_CONFIG_JSON = $(LOCAL_APPLICATION_DIR)/mobile/android/app/src/$(INFRA_ENV)/google-services.json

local-application-mobile-android-config-json: $(LOCAL_APPLICATION_MOBILE_FIREBASE_ANDROID_CONFIG_JSON)
.PHONY: local-application-mobile-android-config-json

$(LOCAL_APPLICATION_MOBILE_FIREBASE_ANDROID_CONFIG_JSON): $(INFRA_FIREBASE_ANDROID_CONFIG_JSON)
	@echo Creating local android config copy "'$@'"
	@cp -f $(INFRA_FIREBASE_ANDROID_CONFIG_JSON) $@
