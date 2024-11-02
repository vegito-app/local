INFRA_ENV ?= dev

-include infra/gcloud/gcloud.mk
-include infra/github/github.mk

INFRA_GOOGLE_IDP_OAUTH_KEY=$(INFRA_ENV)-google-idp-oauth-key
INFRA_GOOGLE_IDP_OAUTH_CLIENT_ID=$(INFRA_ENV)-google-idp-oauth-client-id

-include infra/secrets/secrets.mk
-include infra/environments/terraform.mk

FIREBASE_IOS_CONFIG_PLIST = $(CURDIR)/GoogleService-Info.plist
FIREBASE_ANDROID_CONFIG_JSON = $(CURDIR)/google-services.json

$(FIREBASE_IOS_CONFIG_PLIST): firebase-ios-config-plist
.PHONY: firebase-ios-config-plist
firebase-ios-config-plist:
	@echo Creating Android configuration for "'$(INFRA_ENV)'": "'$(FIREBASE_IOS_CONFIG_PLIST)'"
	@$(MAKE) terraform-output-firebase-ios-config-plist > $(FIREBASE_IOS_CONFIG_PLIST)

$(FIREBASE_ANDROID_CONFIG_JSON): firebase-android-config-json
.PHONY: firebase-android-config-json
firebase-android-config-json:
	@echo Creating iOS configuration for "'$(INFRA_ENV)'": "'$(FIREBASE_ANDROID_CONFIG_JSON)'"
	@$(MAKE) terraform-output-firebase-android-config-json | base64 --decode > $(FIREBASE_ANDROID_CONFIG_JSON)






































































































































