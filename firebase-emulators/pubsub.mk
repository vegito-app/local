
local-firebase-emulators-pubsub-init: \
local-firebase-emulators-pubsub-wait \
local-firebase-emulators-pubsub-topics-create \
local-firebase-emulators-pubsub-subscriptions
	@echo "✅ Pub/Sub emulator is ready!"
	@echo "📋 Listing local Pub/Sub topics:"
	@echo "${LOCAL_FIREBASE_EMULATORS_PUBSUB_TOPICS}"
	@echo "📋 Listing local Pub/Sub subscriptions:"
	@echo "${LOCAL_FIREBASE_EMULATORS_PUBSUB_SUBSCRIPTIONS}"
.PHONY: local-firebase-emulators-pubsub-init

local-firebase-emulators-pubsub-topics-create: $(LOCAL_FIREBASE_EMULATORS_PUBSUB_TOPICS:%=local-firebase-emulators-pubsub-topics-create-%)
.PHONY: local-firebase-emulators-pubsub-topics-create

$(LOCAL_FIREBASE_EMULATORS_PUBSUB_TOPICS:%=local-firebase-emulators-pubsub-topics-create-%):
	@echo "📣 Creating local Pub/Sub topic: $@"
	@curl -X PUT http://localhost:8085/v1/projects/$(GOOGLE_CLOUD_PROJECT_ID)/topics/$(@:local-firebase-emulators-pubsub-topics-create-%=%)|echo
.PHONY: $(LOCAL_FIREBASE_EMULATORS_PUBSUB_TOPICS:%=local-firebase-emulators-pubsub-topics-create-%)

local-firebase-emulators-pubsub-subscriptions: $(LOCAL_FIREBASE_EMULATORS_PUBSUB_SUBSCRIPTIONS:%=local-firebase-emulators-pubsub-subscriptions-create-%)
.PHONY: local-firebase-emulators-pubsub-subscriptions

$(LOCAL_FIREBASE_EMULATORS_PUBSUB_SUBSCRIPTIONS:%=local-firebase-emulators-pubsub-subscriptions-create-%):
	@echo "📣 Creating local Pub/Sub subscription: $@"
	@echo "📣 LOCAL_FIREBASE_EMULATORS_PUBSUB_SUBSCRIPTIONS: $(LOCAL_FIREBASE_EMULATORS_PUBSUB_SUBSCRIPTIONS)"
	@curl -X PUT http://localhost:8085/v1/projects/$(GOOGLE_CLOUD_PROJECT_ID)/subscriptions/$(@:local-firebase-emulators-pubsub-subscriptions-create-%=%) \
	  -H "Content-Type: application/json" \
	  -d '{ "topic": "projects/$(GOOGLE_CLOUD_PROJECT_ID)/topics/$(LOCAL_FIREBASE_EMULATORS_PUBSUB_VEGETABLE_IMAGES_CREATED_TOPIC)" }'|echo
.PHONY: $(LOCAL_FIREBASE_EMULATORS_PUBSUB_SUBSCRIPTIONS:%=local-firebase-emulators-pubsub-subscriptions-create-%)
