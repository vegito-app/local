-include $(CURDIR)/application/mobile/android/android.mk

FLUTTER ?= $(LOCAL_DOCKER_COMPOSE) exec android-studio flutter

application-mobile-flutter-clean:
	@$(FLUTTER) clean
.PHONY: application-mobile-flutter-clean

application-mobile-flutter-pub-get:
	@$(FLUTTER) pub get
.PHONY: application-mobile-flutter-pub-get

application-mobile-flutter-tests:
	@$(FLUTTER) test
.PHONY: application-mobile-flutter-tests

DART = $(LOCAL_DOCKER_COMPOSE) exec android-studio dart

application-mobile-flutter-tests-buildrunner:
	@$(DART) run build_runner test --delete-conflicting-outputs
.PHONY: application-mobile-flutter-tests-buildrunner

application-mobile-flutter-analyze:
	@$(FLUTTER) analyze
.PHONY: application-mobile-flutter-analyze

APPLICATION_MOBILE_BUILDS = apk ios

$(APPLICATION_MOBILE_BUILDS:%=application-mobile-flutter-build-%):
	@$(FLUTTER) clean
	@$(FLUTTER) pub get
	@$(FLUTTER) build $(@:application-mobile-flutter-build-%=%) --verbose
	@echo "Build for $(@:application-mobile-flutter-build-%=%) completed successfully"
.PHONY: $(APPLICATION_MOBILE_BUILDS:%=application-mobile-flutter-build-%)

application-mobile-flutter-build: $(APPLICATION_MOBILE_BUILDS:%=application-mobile-flutter-build-%)
.PHONY: application-mobile-flutter-build

application-mobile-flutter-run-apk:
	@firebase-emulator-check.sh
	@$(FLUTTER) run --release -d emulator-5554

.PHONY: application-mobile-flutter-run-apk

APPLICATION_MOBILE_FIREBASE_IOS_CONFIG_PLIST = $(CURDIR)/application/mobile/ios/GoogleService-Info.plist

application-mobile-ios-config-plist: $(APPLICATION_MOBILE_FIREBASE_IOS_CONFIG_PLIST)
.PHONY:application-mobile-ios-config-plist

$(APPLICATION_MOBILE_FIREBASE_IOS_CONFIG_PLIST): $(INFRA_FIREBASE_IOS_CONFIG_PLIST)
	@echo Creating local ios config copy "'$@'"
	@cp -f $< $@ 

APPLICATION_MOBILE_FIREBASE_ANDROID_CONFIG_JSON = $(CURDIR)/application/mobile/android/app/google-services.json

application-mobile-android-config-json: $(APPLICATION_MOBILE_FIREBASE_ANDROID_CONFIG_JSON)
.PHONY: application-mobile-android-config-json

$(APPLICATION_MOBILE_FIREBASE_ANDROID_CONFIG_JSON): $(INFRA_FIREBASE_ANDROID_CONFIG_JSON)
	@echo Creating local android config copy "'$@'"
	@cp -f $< $@ 

application-mobile-flutter-native-splash:
	@$(FLUTTER) pub run flutter_native_splash:create
.PHONY: application-mobile-flutter-native-splash
