VEGITO_GCLOUD_DIR ?= $(CURDIR)

GCLOUD ?= gcloud --project=$(GOOGLE_CLOUD_PROJECT_ID)

-include $(VEGITO_GCLOUD_DIR)/auth.mk
-include $(VEGITO_GCLOUD_DIR)/compute.mk
-include $(VEGITO_GCLOUD_DIR)/docker.mk
-include $(VEGITO_GCLOUD_DIR)/firebase.mk
-include $(VEGITO_GCLOUD_DIR)/iam.mk
-include $(VEGITO_GCLOUD_DIR)/user.mk

gcloud-project-set:
	@echo "🔧 Configuring current project to $(GOOGLE_CLOUD_PROJECT_ID)."
	@$(GCLOUD) config set project $(GOOGLE_CLOUD_PROJECT_ID)
.PHONY: gcloud-project-set

gcloud-info:
	@echo "ℹ️  Displaying gcloud info..."
	@$(GCLOUD) info
.PHONY: gcloud-info

gcloud-config-set-project:
	@echo "🔧 Setting gcloud config project to $(GOOGLE_CLOUD_PROJECT_ID)..."
	@$(GCLOUD) config set project $(GOOGLE_CLOUD_PROJECT_ID)
.PHONY:gcloud-config-set-project

GOOGLE_SERVICES_API = serviceusage cloudbilling

gcloud-services-apis-enable: $(GOOGLE_SERVICES_API:%=gcloud-services-enable-%-api)
	@echo "✅ Enabled required Google Cloud APIs."
.PHONY: gcloud-services-apis-enable

gcloud-services-apis-disable: $(GOOGLE_SERVICES_API:%=gcloud-services-disable-%-api)
	@echo "🚫 Disabled specified Google Cloud APIs."
.PHONY: gcloud-services-apis-disable

$(GOOGLE_SERVICES_API:%=gcloud-services-enable-%-api):
	@$(GCLOUD) services enable $(@:gcloud-services-enable-%-api=%).googleapis.com --project=$(GOOGLE_CLOUD_PROJECT_ID)
.PHONY: $(GOOGLE_SERVICES_API:%=gcloud-services-enable-%-api)

$(GOOGLE_SERVICES_API:%=gcloud-services-disable-%-api):
	@$(GCLOUD) services disable $(@:gcloud-services-disable-%-api=%).googleapis.com --project=$(GOOGLE_CLOUD_PROJECT_ID)
.PHONY: $(GOOGLE_SERVICES_API:%=gcloud-services-disable-%-api)

gcloud-apikeys-list:
	@$(GCLOUD) alpha services api-keys list
.PHONY: gcloud-apikeys-list

gcloud-services-list-enabled:
	@$(GCLOUD) services list --enabled
.PHONY: gcloud-services-list-enabled

# Upadte this list with '$(GCLOUD) secrets list' values
GCLOUD_SECRETS := \
  firebase-adminsdk-service-account-key \
  firebase-config-web \
  google-idp-oauth-client-id \
  google-idp-oauth-key \
  google-maps-api-key \
  stripe-key

$(GCLOUD_SECRETS:%=gcloud-secret-%-show):
	@a=$$($(GCLOUD) secrets versions access latest \
	  --secret=$(@:gcloud-secret-%-show=%)) \
	&& echo $$a | jq 2>/dev/null \
	|| echo $$a
.PHONY: $(GCLOUD_SECRETS:%=gcloud-secret-%-show)