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

local-firebase-emulators-pubsub-init: local-firebase-emulators-pubsub-wait local-firebase-emulators-pubsub-topics-create local-firebase-emulators-pubsub-subscriptions
.PHONY: local-firebase-emulators-pubsub-init

# Use same PubSub topic to bypass current validation in local setup
LOCAL_FIREBASE_EMULATORS_PUBSUB_VALIDATED_IMAGES_TOPIC = $(LOCAL_FIREBASE_EMULATORS_PUBSUB_VEGETABLE_IMAGES_CREATED_TOPIC)

LOCAL_FIREBASE_EMULATORS_PUB_SUB_TOPICS = \
  $(LOCAL_FIREBASE_EMULATORS_PUBSUB_VEGETABLE_IMAGES_CREATED_TOPIC)

local-firebase-emulators-pubsub-topics-create: $(LOCAL_FIREBASE_EMULATORS_PUB_SUB_TOPICS:%=local-firebase-emulators-pubsub-topics-create-%)
.PHONY: local-firebase-emulators-pubsub-topics-create

$(LOCAL_FIREBASE_EMULATORS_PUB_SUB_TOPICS:%=local-firebase-emulators-pubsub-topics-create-%):
	@echo "📣 Creating local Pub/Sub topic: $@"
	@curl -X PUT http://localhost:8085/v1/projects/$(GOOGLE_CLOUD_PROJECT_ID)/topics/$(@:local-firebase-emulators-pubsub-topics-create-%=%)|echo
.PHONY: $(LOCAL_FIREBASE_EMULATORS_PUB_SUB_TOPICS:%=local-firebase-emulators-pubsub-topics-create-%)

local-firebase-emulators-pubsub-subscriptions: $(LOCAL_FIREBASE_EMULATORS_PUBSUB_SUBSCRIPTIONS:%=local-firebase-emulators-pubsub-subscriptions-create-%)
.PHONY: local-firebase-emulators-pubsub-subscriptions

$(LOCAL_FIREBASE_EMULATORS_PUBSUB_SUBSCRIPTIONS:%=local-firebase-emulators-pubsub-subscriptions-create-%):
	@echo "📣 Creating local Pub/Sub subscription: $@"
	@curl -X PUT http://localhost:8085/v1/projects/$(GOOGLE_CLOUD_PROJECT_ID)/subscriptions/$(@:local-firebase-emulators-pubsub-subscriptions-create-%=%) \
	  -H "Content-Type: application/json" \
	  -d '{ "topic": "projects/$(GOOGLE_CLOUD_PROJECT_ID)/topics/$(LOCAL_FIREBASE_EMULATORS_PUBSUB_VEGETABLE_IMAGES_CREATED_TOPIC)" }'|echo
.PHONY: $(LOCAL_FIREBASE_EMULATORS_PUBSUB_SUBSCRIPTIONS:%=local-firebase-emulators-pubsub-subscriptions-create-%)

local-firebase-emulators-pubsub-check:
	@echo "📋 Listing local Pub/Sub topics:"
	@curl -s http://localhost:8085/v1/projects/$(GOOGLE_CLOUD_PROJECT_ID)/topics | jq .
	@echo
	@echo "📋 Listing local Pub/Sub subscriptions:"
	@curl -s http://localhost:8085/v1/projects/$(GOOGLE_CLOUD_PROJECT_ID)/subscriptions | jq .
.PHONY: local-firebase-emulators-pubsub-check
