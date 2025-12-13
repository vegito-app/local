LOCAL_FIREBASE_EMULATORS_IMAGE_VERSION ?= $(VEGITO_LOCAL_PUBLIC_IMAGES_BASE):firebase-emulators-$(VERSION)
LOCAL_FIREBASE_EMULATORS_DIR ?= $(LOCAL_DIR)/firebase-emulators
FIREBASE_EMULATORS = cd $(LOCAL_FIREBASE_EMULATORS_DIR) && firebase
# This is a comma separated list of emulator names.
# Valid options are: ["auth","functions","firestore","database","hosting","pubsub","storage","eventarc","dataconnect"]
FIREBASE_EMULATORS_SERVICES ?= auth,functions,firestore,storage,pubsub,database
LOCAL_FIREBASE_EMULATORS_AUTH_FUNCTIONS_DIR ?= $(LOCAL_DIR)/firebase-emulators/auth_functions
LOCAL_FIREBASE_EMULATORS_DATA ?= $(LOCAL_DIR)/firebase-emulators/data
LOCAL_FIREBASE_EMULATORS_CONFIG_JSON ?= $(LOCAL_DIR)/firebase-emulators/firebase.json

local-firebase-emulators-install: local-firebase-emulators-auth-functions-npm-install
	@cd $(LOCAL_FIREBASE_EMULATORS_AUTH_FUNCTIONS_DIR) && npm install
.PHONY: local-firebase-emulators-install

local-firebase-emulators-auth-functions-npm-install:
	cd $(LOCAL_FIREBASE_EMULATORS_AUTH_FUNCTIONS_DIR) && npm install
.PHONY: local-firebase-emulators-auth-functions-npm-install

local-firebase-emulators-init:
	@$(FIREBASE_EMULATORS) init emulators 
.PHONY: local-firebase-emulators-init

local-firebase-emulators-functions-serve:
	@cd $(LOCAL_FIREBASE_EMULATORS_DIR)/auth_functions && \
	unset GOOGLE_APPLICATION_CREDENTIALS && \
	npm run serve
.PHONY: local-firebase-emulators-functions-serve

local-firebase-emulators-config-json: $(LOCAL_FIREBASE_EMULATORS_CONFIG_JSON)
.PHONY: local-firebase-emulators-config-json	

$(LOCAL_FIREBASE_EMULATORS_CONFIG_JSON):
	@echo "Creating Firebase emulators config JSON at $@"
	@$(LOCAL_FIREBASE_EMULATORS_DIR)/firebase-emulators-config-create-json.sh

local-firebase-emulators-start: local-firebase-emulators-install local-firebase-emulators-config-json
	unset GOOGLE_APPLICATION_CREDENTIALS || true ; \
	  $(FIREBASE_EMULATORS) emulators:start \
	    --project=$(GOOGLE_CLOUD_PROJECT_ID) \
	    --import=$(LOCAL_FIREBASE_EMULATORS_DATA) \
	    --export-on-exit $(LOCAL_FIREBASE_EMULATORS_DATA) \
	    --log-verbosity DEBUG \
	    --only $(FIREBASE_EMULATORS_SERVICES)
.PHONY: local-firebase-emulators-start

local-firebase-emulators-docker-compose: local-firebase-emulators-prepare local-firebase-emulators-container-up local-firebase-emulators-container-logs
.PHONY: local-firebase-emulators-docker-compose

local-firebase-emulators-container-up: local-firebase-emulators-container-rm
	@echo "Starting mobile firebase-emulators container..."
	@$(LOCAL_FIREBASE_EMULATORS_DIR)/container-up.sh
.PHONY: local-firebase-emulators-container-up

local-firebase-emulators-pubsub-wait:
	@echo "⏳ Waiting for Pub/Sub emulator..."
	@until nc -z localhost 8085; do \
		echo "🕒 Waiting for port 8085..."; \
		sleep 1; \
	done
	@echo "✅ Pub/Sub emulator is up!"
.PHONY: local-firebase-emulators-pubsub-wait

local-firebase-emulators-pubsub-check:
	@echo "📋 Listing local Pub/Sub topics:"
	@curl -s http://localhost:8085/v1/projects/$(GOOGLE_CLOUD_PROJECT_ID)/topics | jq .
	@echo
	@echo "📋 Listing local Pub/Sub subscriptions:"
	@curl -s http://localhost:8085/v1/projects/$(GOOGLE_CLOUD_PROJECT_ID)/subscriptions | jq .
.PHONY: local-firebase-emulators-pubsub-check
