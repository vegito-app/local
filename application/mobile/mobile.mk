application-mobile-flutter-pub-get:
	@cd $(CURDIR)/application/mobile && flutter pub get
.PHONY: application-mobile-flutter-pub-get

APPLICATION_MOBILE_BUILDS = apk ios

$(APPLICATION_MOBILE_BUILDS:%=application-mobile-flutter-build-%):
	@cd $(CURDIR)/application/mobile && flutter build $(@:application-mobile-flutter-build-%=%) \
	  --dart-define=BACKEND_URL=$(BACKEND_URL) 
.PHONY: $(APPLICATION_MOBILE_BUILDS:%=application-mobile-flutter-build-%)

application-mobile-build: $(APPLICATION_MOBILE_BUILDS:%=application-mobile-flutter-build-%)
.PHONY: application-mobile-build

APPLICATION_MOBILE_FIREBASE_IOS_CONFIG_PLIST = $(CURDIR)/application/mobile/ios/GoogleService-Info.plist

$(APPLICATION_MOBILE_FIREBASE_IOS_CONFIG_PLIST): 
	@$(MAKE) application-ios-config-plist

application-ios-config-plist: $(INFRA_FIREBASE_IOS_CONFIG_PLIST)
	@echo Creating local link "'$(APPLICATION_MOBILE_FIREBASE_IOS_CONFIG_PLIST) -> $<'"
	@ln -sf $< $(APPLICATION_MOBILE_FIREBASE_IOS_CONFIG_PLIST)
.PHONY:application-ios-config-plist

APPLICATION_MOBILE_FIREBASE_ANDROID_CONFIG_JSON = $(CURDIR)/application/mobile/android/app/google-services.json

$(APPLICATION_MOBILE_FIREBASE_ANDROID_CONFIG_JSON): 
	@$(MAKE) application-android-config-json

application-android-config-json: $(INFRA_FIREBASE_ANDROID_CONFIG_JSON)
	@echo Creating local link "'$< -> $(APPLICATION_MOBILE_FIREBASE_ANDROID_CONFIG_JSON)'"
	@ln -sf $< $(APPLICATION_MOBILE_FIREBASE_ANDROID_CONFIG_JSON)
.PHONY: application-android-config-json