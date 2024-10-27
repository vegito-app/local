-include application/frontend/frontend.mk
-include application/backend/backend.mk
-include application/mobile/flutter.mk

APPLICATION_MOBILE_FIREBASE_IOS_CONFIG_PLIST = $(CURDIR)/application/mobile/ios/GoogleService-Info.plist

$(APPLICATION_MOBILE_FIREBASE_IOS_CONFIG_PLIST): 
	@$(MAKE) application-ios-config-plist

application-ios-config-plist: $(FIREBASE_IOS_CONFIG_PLIST)
	@echo Creating local link "'$(APPLICATION_MOBILE_FIREBASE_IOS_CONFIG_PLIST) -> $<'"
	@ln -sf $< $(APPLICATION_MOBILE_FIREBASE_IOS_CONFIG_PLIST)
.PHONY:application-ios-config-plist

APPLICATION_MOBILE_FIREBASE_ANDROID_CONFIG_JSON = $(CURDIR)/application/mobile/android/app/google-services.json

$(APPLICATION_MOBILE_FIREBASE_ANDROID_CONFIG_JSON): 
	@@$(MAKE) application-android-config-json

application-android-config-json: $(FIREBASE_ANDROID_CONFIG_JSON)
	@echo Creating local link "'$(APPLICATION_MOBILE_FIREBASE_IOS_CONFIG_PLIST) -> $<'"
	@ln -sf $< $(APPLICATION_MOBILE_FIREBASE_ANDROID_CONFIG_JSON)
.PHONY: application-android-config-json