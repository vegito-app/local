APPLICATION_MOBILE_DIR ?= $(LOCAL_APPLICATION_DIR)/mobile
APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_CACHE ?= $(LOCAL_APPLICATION_DIR)/.containers/docker-buildx-cache/application-mobile
$(APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_CACHE):;	@mkdir -p "$@"
ifneq ($(wildcard $(APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_CACHE)/index.json),)
APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ = type=local,src=$(APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_CACHE)
endif

APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_CACHE_WRITE= type=local,mode=max,dest=$(APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_CACHE)

-include $(APPLICATION_MOBILE_DIR)/android/android.mk

FLUTTER ?= $(LOCAL_DOCKER_COMPOSE) exec android-studio flutter

APPLICATION_MOBILE_ANDROID_PACKAGE_NAME ?= $(INFRA_ENV).vegito.app.android

application-mobile-flutter-create:
	@$(FLUTTER) create . --org $(APPLICATION_MOBILE_ANDROID_PACKAGE_NAME) --description "Vegito Android Application" --platforms android,ios --no-pub
	@echo "Flutter application created successfully"
	@echo "Please run 'make application-mobile-flutter-pub-get' to install dependencies"
	@echo "You can also run 'make application-mobile-flutter-analyze' to analyze the code"
	@echo "To run the application, use 'make application-mobile-flutter-run' or 'make application-mobile-flutter-debug'"
	@echo "For building the application, use 'make application-mobile-flutter-build' followed by the desired build type (e.g., apk, ios)"
	@echo "For cleaning the project, use 'make application-mobile-flutter-clean'"
	@echo "For running tests, use 'make application-mobile-flutter-tests' or 'make application-mobile-flutter-tests-buildrunner' for build_runner tests"
	@echo "For uninstalling the app from the emulator, use 'make flutter-app-uninstall'"
	@echo "For preparing the app for running on the emulator, use 'make application-mobile-flutter-run-prepare'"
.PHONY: application-mobile-flutter-create

application-mobile-flutter-clean:
	@$(FLUTTER) clean
.PHONY: application-mobile-flutter-clean

application-mobile-flutter-pub-get:
	@$(FLUTTER) pub get
.PHONY: application-mobile-flutter-pub-get

application-mobile-flutter-tests:
	@$(FLUTTER) test
.PHONY: application-mobile-flutter-tests

DART ?= $(LOCAL_DOCKER_COMPOSE) exec android-studio dart

application-mobile-flutter-tests-buildrunner:
	@$(DART) run build_runner test --delete-conflicting-outputs
.PHONY: application-mobile-flutter-tests-buildrunner

application-mobile-flutter-analyze:
	@$(FLUTTER) analyze
.PHONY: application-mobile-flutter-analyze

ADB ?= $(LOCAL_DOCKER_COMPOSE) exec android-studio adb

flutter-app-uninstall:
	@echo "Uninstalling the app from the emulator"
	@$(ADB) uninstall dev.vegito.app.android || true
.PHONY: flutter-app-uninstall

APPLICATION_MOBILE_BUILDS = apk ios

$(APPLICATION_MOBILE_BUILDS:%=application-mobile-flutter-build-%): application-mobile-ios-config-plist application-mobile-default-android-config-json application-mobile-android-config-json
	@$(FLUTTER) clean
	@$(FLUTTER) pub get
	@$(FLUTTER) build $(@:application-mobile-flutter-build-%=%) --flavor $(INFRA_ENV) --release --verbose
	@echo "Build for $(@:application-mobile-flutter-build-%=%) completed successfully"
.PHONY: $(APPLICATION_MOBILE_BUILDS:%=application-mobile-flutter-build-%)

application-mobile-flutter-build: $(APPLICATION_MOBILE_BUILDS:%=application-mobile-flutter-build-%)
.PHONY: application-mobile-flutter-build

firebase-emulators-check:
	@firebase-emulators-check.sh
.PHONY: firebase-emulators-check

application-mobile-flutter-run-prepare: flutter-app-uninstall
	@echo "Preparing the app for running on the emulator with flavor $(INFRA_ENV)"
	@$(FLUTTER) clean
	@$(FLUTTER) pub get
.PHONY: application-mobile-flutter-run-prepare	

application-mobile-flutter-run: application-mobile-flutter-run-prepare
	@echo "Running the app on the emulator with flavor $(INFRA_ENV)"
	$(FLUTTER) run --verbose --flavor $(INFRA_ENV) --release lib/main.dart
	@echo "App is running on the emulator with flavor $(INFRA_ENV)"
.PHONY: application-mobile-flutter-run	

application-mobile-flutter-debug: application-mobile-flutter-run-prepare
	@echo "Running the app in debug mode on the emulator with flavor $(INFRA_ENV)"
	$(FLUTTER) run --verbose --flavor $(INFRA_ENV) --debug lib/main.dart
.PHONY: application-mobile-flutter-debug

APPLICATION_MOBILE_DEFAULT_FIREBASE_IOS_CONFIG_PLIST = $(LOCAL_APPLICATION_DIR)/mobile/ios/GoogleService-Info.plist

application-mobile-ios-config-plist: $(APPLICATION_MOBILE_DEFAULT_FIREBASE_IOS_CONFIG_PLIST)
.PHONY:application-mobile-ios-config-plist

$(APPLICATION_MOBILE_DEFAULT_FIREBASE_IOS_CONFIG_PLIST): $(INFRA_FIREBASE_IOS_CONFIG_PLIST)
	@echo Creating local ios config copy "'$@'"
	@cp -f $< $@ 

APPLICATION_MOBILE_DEFAULT_FIREBASE_ANDROID_CONFIG_JSON = $(LOCAL_APPLICATION_DIR)/mobile/android/app/google-services.json

$(APPLICATION_MOBILE_DEFAULT_FIREBASE_ANDROID_CONFIG_JSON): $(INFRA_FIREBASE_ANDROID_CONFIG_JSON)
	@echo Creating local android config copy "'$@'"
	@cp -f $< $@ 

application-mobile-default-android-config-json: $(APPLICATION_MOBILE_DEFAULT_FIREBASE_ANDROID_CONFIG_JSON)
.PHONY: application-mobile-default-android-config-json

APPLICATION_MOBILE_FIREBASE_ANDROID_CONFIG_JSON = $(LOCAL_APPLICATION_DIR)/mobile/android/app/src/$(INFRA_ENV)/google-services.json

application-mobile-android-config-json: $(APPLICATION_MOBILE_FIREBASE_ANDROID_CONFIG_JSON)
.PHONY: application-mobile-android-config-json

$(APPLICATION_MOBILE_FIREBASE_ANDROID_CONFIG_JSON): $(INFRA_FIREBASE_ANDROID_CONFIG_JSON)
	@echo Creating local android config copy "'$@'"
	@cp -f $(INFRA_FIREBASE_ANDROID_CONFIG_JSON) $@

APPLICATION_MOBILE_FLAVORS = dev staging prod

application-mobile-flutter-native-splash:
	@$(FLUTTER) pub run flutter_native_splash:create --flavors $(APPLICATION_MOBILE_FLAVORS)
.PHONY: application-mobile-flutter-native-splash

application-mobile-flutter-launcher-icons:
	@$(FLUTTER) pub run flutter_launcher_icons:main
.PHONY: application-mobile-flutter-launcher-icons
