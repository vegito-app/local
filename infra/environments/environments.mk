
-include infra/environments/secrets.mk
-include infra/environments/prod/vault/vault.mk
-include infra/environments/prod/kubernetes/kubernetes.mk
-include infra/environments/dev/dev.mk

INFRA_ENVIRONMENTS := \
	prod \
	vault \
	staging \
	dev

$(INFRA_ENVIRONMENTS:%=infra-deploy-%):
	@INFRA_ENV=$(@:infra-deploy-%=%) $(MAKE) terraform-init terraform-plan terraform-apply-auto-approve firebase-mobiles-configs
.PHONY: $(INFRA_ENVIRONMENTS:%=infra-deploy-%)

INFRA_FIREBASE_IOS_CONFIG_PLIST = $(CURDIR)/infra/environments/$(INFRA_ENV)/GoogleService-Info.plist
INFRA_FIREBASE_ANDROID_CONFIG_JSON = $(CURDIR)/infra/environments/$(INFRA_ENV)/google-services.json

firebase-ios-config-plist: terraform-output-firebase-ios-config-plist
.PHONY: firebase-ios-config-plist

firebase-android-config-json: terraform-output-firebase-android-config-json
.PHONY: firebase-android-config-json

firebase-mobiles-configs: firebase-android-config-json firebase-ios-config-plist
.PHONY: firebase-mobiles-configs