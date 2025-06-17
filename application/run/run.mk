APPLICATION_RUN_APPLICATION_DIR := $(CURDIR)/application/run
APPLICATION_RUN_APPLICATION_HOSTING_DIR := $(APPLICATION_RUN_APPLICATION_DIR)/hosting
APPLICATION_RUN_APPLICATION_HOSTING_PUBLIC_DIR := $(APPLICATION_RUN_APPLICATION_HOSTING_DIR)/public
APPLICATION_RUN_APPLICATION_LANGUAGES := en fr # de es it pt br ru zh

APPLICATION_RUN_FIREBASE_HOSTING_LEGAL_SITE_TARGET := vegito-app-legal-site

APPLICATION_RUN_FIREBASE_VEGITO_APP_HOSTING_SITE_ID := $(APPLICATION_RUN_FIREBASE_HOSTING_LEGAL_SITE_TARGET)-$(DEV_GOOGLE_CLOUD_PROJECT_NAME)-hosting

# Use firebase CLI from firebase-emulators container
APPLICATION_RUN_FIREBASE = $(LOCAL_DOCKER_COMPOSE) exec firebase-emulators firebase --project=$(GOOGLE_CLOUD_PROJECT_ID) -c $(APPLICATION_RUN_APPLICATION_HOSTING_DIR)/firebase.json

application-run-firebase-login:	
	@$(APPLICATION_RUN_FIREBASE) login
	@echo "Firebase login successful. You can now run Firebase commands."
.PHONY: application-run-firebase-login

application-run-vegito-app-legal-sites-firebase-hosting-deploy:
	$(APPLICATION_RUN_FIREBASE) target:apply hosting $(APPLICATION_RUN_FIREBASE_HOSTING_LEGAL_SITE_TARGET) $(APPLICATION_RUN_FIREBASE_VEGITO_APP_HOSTING_SITE_ID)
	$(APPLICATION_RUN_FIREBASE) deploy --only hosting:$(APPLICATION_RUN_FIREBASE_HOSTING_LEGAL_SITE_TARGET)
.PHONY: application-run-vegito-app-legal-sites-firebase-hosting-deploy	
