LOCAL_FIREBASE_PUBSUB_EMULATOR_HOST ?= firebase-emulators:8085

local-firebase-emulators-pubsub-init: \
local-firebase-emulators-pubsub-wait \
local-firebase-emulators-pubsub-topics-create \
local-firebase-emulators-pubsub-subscriptions \
local-firebase-emulators-pubsub-check
	@echo "✅ Pub/Sub emulator is ready!"
.PHONY: local-firebase-emulators-pubsub-init

local-firebase-emulators-pubsub-topics-create: $(LOCAL_FIREBASE_EMULATORS_PUBSUB_TOPICS:%=local-firebase-emulators-pubsub-topics-create-%)
.PHONY: local-firebase-emulators-pubsub-topics-create

$(LOCAL_FIREBASE_EMULATORS_PUBSUB_TOPICS:%=local-firebase-emulators-pubsub-topics-create-%):
	@echo "📣 Creating local Pub/Sub topic: $@"
	@curl -X PUT http://$(LOCAL_FIREBASE_PUBSUB_EMULATOR_HOST)/v1/projects/$(GOOGLE_CLOUD_PROJECT_ID)/topics/$(@:local-firebase-emulators-pubsub-topics-create-%=%)|echo
.PHONY: $(LOCAL_FIREBASE_EMULATORS_PUBSUB_TOPICS:%=local-firebase-emulators-pubsub-topics-create-%)

local-firebase-emulators-pubsub-subscriptions: $(LOCAL_FIREBASE_EMULATORS_PUBSUB_TOPICS:%=local-firebase-emulators-%-pubsub-subscriptions)
.PHONY: local-firebase-emulators-pubsub-subscriptions

local-firebase-emulators-vegetable-images-created-pubsub-subscriptions: $(VEGITO_APP_FIREBASE_PUBSUB_VEGETABLE_IMAGES_VALIDATED_SUBSCRIPTIONS:%=local-firebase-emulators-vegetable-images-created-pubsub-subscriptions-create-%)
.PHONY: local-firebase-emulators-vegetable-images-created-pubsub-subscriptions

$(VEGITO_APP_FIREBASE_PUBSUB_VEGETABLE_IMAGES_VALIDATED_SUBSCRIPTIONS:%=local-firebase-emulators-vegetable-images-created-pubsub-subscriptions-create-%):
	@echo "📣 Creating local Pub/Sub subscription: $@"
	@echo "📣 VEGITO_APP_FIREBASE_PUBSUB_VEGETABLE_IMAGES_VALIDATED_SUBSCRIPTIONS: $(VEGITO_APP_FIREBASE_PUBSUB_VEGETABLE_IMAGES_VALIDATED_SUBSCRIPTIONS)"
	curl -X PUT http://$(LOCAL_FIREBASE_PUBSUB_EMULATOR_HOST)/v1/projects/$(GOOGLE_CLOUD_PROJECT_ID)/subscriptions/$(@:local-firebase-emulators-vegetable-images-created-pubsub-subscriptions-create-%=%) \
	  -H "Content-Type: application/json" \
	  -d '{ "topic": "projects/$(GOOGLE_CLOUD_PROJECT_ID)/topics/vegetable-images-created" }'|echo
.PHONY: $(VEGITO_APP_FIREBASE_PUBSUB_VEGETABLE_IMAGES_VALIDATED_SUBSCRIPTIONS:%=local-firebase-emulators-vegetable-images-created-pubsub-subscriptions-create-%)

local-firebase-emulators-order-payment-pubsub-subscriptions: $(VEGITO_APP_FIREBASE_PUBSUB_ORDER_PAYMENT_SUBSCRIPTIONS:%=local-firebase-emulators-order-payment-pubsub-subscriptions-create-%)
.PHONY: local-firebase-emulators-order-payment-pubsub-subscriptions

$(VEGITO_APP_FIREBASE_PUBSUB_ORDER_PAYMENT_SUBSCRIPTIONS:%=local-firebase-emulators-order-payment-pubsub-subscriptions-create-%):
	@echo "📣 Creating local Pub/Sub subscription: $@"
	@echo "📣 VEGITO_APP_FIREBASE_PUBSUB_ORDER_PAYMENT_SUBSCRIPTIONS: $(VEGITO_APP_FIREBASE_PUBSUB_ORDER_PAYMENT_SUBSCRIPTIONS)"
	curl -X PUT http://$(LOCAL_FIREBASE_PUBSUB_EMULATOR_HOST)/v1/projects/$(GOOGLE_CLOUD_PROJECT_ID)/subscriptions/$(@:local-firebase-emulators-order-payment-pubsub-subscriptions-create-%=%) \
	  -H "Content-Type: application/json" \
	  -d '{ "topic": "projects/$(GOOGLE_CLOUD_PROJECT_ID)/topics/order-payment" }'|echo
.PHONY: $(VEGITO_APP_FIREBASE_PUBSUB_ORDER_PAYMENT_SUBSCRIPTIONS:%=local-firebase-emulators-order-payment-pubsub-subscriptions-create-%)

local-firebase-emulators-pubsub-wait:
	@echo "⏳ Waiting for Pub/Sub emulator..."
	@until nc -z firebase-emulators 8085; do \
		echo "🕒 Waiting for port 8085..."; \
		sleep 1; \
	done
	@echo "✅ Pub/Sub emulator is up!"
.PHONY: local-firebase-emulators-pubsub-wait

local-firebase-emulators-pubsub-check:
	@echo "📋 Listing local Pub/Sub topics:"
	curl -s http://$(LOCAL_FIREBASE_PUBSUB_EMULATOR_HOST)/v1/projects/$(GOOGLE_CLOUD_PROJECT_ID)/topics | jq .
	@echo
	@echo "📋 Listing local Pub/Sub subscriptions:"
	curl -s http://$(LOCAL_FIREBASE_PUBSUB_EMULATOR_HOST)/v1/projects/$(GOOGLE_CLOUD_PROJECT_ID)/subscriptions | jq .
.PHONY: local-firebase-emulators-pubsub-check
