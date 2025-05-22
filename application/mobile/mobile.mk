application-mobile-flutter-pub-get:
	@cd $(CURDIR)/application/mobile && flutter pub get
.PHONY: application-mobile-flutter-pub-get

APPLICATION_MOBILE_BUILDS = apk ios

$(APPLICATION_MOBILE_BUILDS:%=application-mobile-flutter-build-%):
	@cd $(CURDIR)/application/mobile && flutter build $(@:application-mobile-flutter-build-%=%) \
	  --dart-define=APPLICATION_BACKEND_URL=$(APPLICATION_BACKEND_URL) 
.PHONY: $(APPLICATION_MOBILE_BUILDS:%=application-mobile-flutter-build-%)

application-mobile-build: $(APPLICATION_MOBILE_BUILDS:%=application-mobile-flutter-build-%)
.PHONY: application-mobile-build

APPLICATION_MOBILE_FIREBASE_IOS_CONFIG_PLIST = $(CURDIR)/application/mobile/ios/GoogleService-Info.plist

application-ios-config-plist: $(APPLICATION_MOBILE_FIREBASE_IOS_CONFIG_PLIST)
.PHONY:application-ios-config-plist

$(APPLICATION_MOBILE_FIREBASE_IOS_CONFIG_PLIST): $(INFRA_FIREBASE_IOS_CONFIG_PLIST)
	@echo Creating local ios config copy "'$@'"
	@cp -f $< $@ 

APPLICATION_MOBILE_FIREBASE_ANDROID_CONFIG_JSON = $(CURDIR)/application/mobile/android/app/google-services.json

application-android-config-json: $(APPLICATION_MOBILE_FIREBASE_ANDROID_CONFIG_JSON)
.PHONY: application-android-config-json

$(APPLICATION_MOBILE_FIREBASE_ANDROID_CONFIG_JSON): $(INFRA_FIREBASE_ANDROID_CONFIG_JSON)
	@echo Creating local android config copy "'$@'"
	@cp -f $< $@ 

