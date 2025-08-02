APPLICATION_DIR ?= $(CURDIR)/application
APPLICATION_MOBILE_DIR = $(APPLICATION_DIR)/mobile

-include $(APPLICATION_DIR)/frontend/frontend.mk
-include $(APPLICATION_DIR)/backend/backend.mk
-include $(APPLICATION_MOBILE_DIR)/mobile.mk


APPLICATION_MOBILE_FIREBASE_IOS_CONFIG_PLIST = $(APPLICATION_MOBILE_DIR)/ios/GoogleService-Info.plist

$(APPLICATION_MOBILE_FIREBASE_IOS_CONFIG_PLIST): 
	@$(MAKE) application-ios-config-plist

application-ios-config-plist: $(FIREBASE_IOS_CONFIG_PLIST)
	@echo Creating local link "'$(APPLICATION_MOBILE_FIREBASE_IOS_CONFIG_PLIST) -> $<'"
	@ln -sf $< $(APPLICATION_MOBILE_FIREBASE_IOS_CONFIG_PLIST)
.PHONY:application-ios-config-plist

APPLICATION_MOBILE_FIREBASE_ANDROID_CONFIG_JSON = $(APPLICATION_MOBILE_DIR)/android/app/google-services.json

$(APPLICATION_MOBILE_FIREBASE_ANDROID_CONFIG_JSON): 
	@$(MAKE) application-android-config-json

application-android-config-json: $(FIREBASE_ANDROID_CONFIG_JSON)
	@echo Creating local link "'$(APPLICATION_MOBILE_FIREBASE_IOS_CONFIG_PLIST) -> $<'"
	@ln -sf $< $(APPLICATION_MOBILE_FIREBASE_ANDROID_CONFIG_JSON)
.PHONY: application-android-config-json
