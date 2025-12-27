# example-application/firebase/firebase-emulators.mk
# VEGITO_FIREBASE_EMULATORS_DIR := $(CURDIR)/firebase
# VEGITO_FIREBASE_EMULATORS_AUTH_FUNCTIONS_DIR := $(VEGITO_FIREBASE_EMULATORS_DIR)/auth_functions
# VEGITO_FIREBASE_EMULATORS_PUBSUB_VEGETABLE_IMAGES_CREATED_TOPIC := vegetable-images-created
# VEGITO_FIREBASE_EMULATORS_PUBSUB_VEGETABLE_IMAGES_VALIDATED_BACKEND_SUBSCRIPTION := vegetable-images-validated-backend
# VEGITO_FIREBASE_EMULATORS_PUBSUB_VEGETABLE_IMAGES_VALIDATED_BACKEND_SUBSCRIPTION_DEBUG := vegetable-images-validated-backend-debug

# VEGITO_FIREBASE_EMULATORS_PUBSUB_VEGETABLE_IMAGES_VALIDATED_SUBSCRIPTIONS := \
#   $(VEGITO_FIREBASE_EMULATORS_PUBSUB_VEGETABLE_IMAGES_VALIDATED_BACKEND_SUBSCRIPTION) \
#   $(VEGITO_FIREBASE_EMULATORS_PUBSUB_VEGETABLE_IMAGES_VALIDATED_BACKEND_SUBSCRIPTION_DEBUG)

# VEGITO_FIREBASE_EMULATORS_PUBSUB_ORDER_PAYMENT_TOPIC := order-payment
# VEGITO_FIREBASE_EMULATORS_PUBSUB_ORDER_PAYMENT_BACKEND_SUBSCRIPTION := order-payment-backend
# VEGITO_FIREBASE_EMULATORS_PUBSUB_ORDER_PAYMENT_BACKEND_SUBSCRIPTION_DEBUG := order-payment-backend-debug

# VEGITO_FIREBASE_EMULATORS_PUBSUB_ORDER_PAYMENT_SUBSCRIPTIONS := \
#   $(VEGITO_FIREBASE_EMULATORS_PUBSUB_ORDER_PAYMENT_BACKEND_SUBSCRIPTION) \
#   $(VEGITO_FIREBASE_EMULATORS_PUBSUB_ORDER_PAYMENT_BACKEND_SUBSCRIPTION_DEBUG)

# local-firebase-emulators-pubsub-init: local-firebase-emulators-pubsub-wait local-firebase-emulators-pubsub-topics-create local-firebase-emulators-pubsub-subscriptions
# .PHONY: local-firebase-emulators-pubsub-init

# # Use same PubSub topic to bypass current validation in local setup
# LOCAL_FIREBASE_EMULATORS_PUBSUB_VALIDATED_IMAGES_TOPIC = $(LOCAL_FIREBASE_EMULATORS_PUBSUB_VEGETABLE_IMAGES_CREATED_TOPIC)

# LOCAL_FIREBASE_EMULATORS_PUB_SUB_TOPICS = \
#   $(LOCAL_FIREBASE_EMULATORS_PUBSUB_VEGETABLE_IMAGES_CREATED_TOPIC)

# local-firebase-emulators-pubsub-topics-create: $(LOCAL_FIREBASE_EMULATORS_PUB_SUB_TOPICS:%=local-firebase-emulators-pubsub-topics-create-%)
# .PHONY: local-firebase-emulators-pubsub-topics-create

# $(LOCAL_FIREBASE_EMULATORS_PUB_SUB_TOPICS:%=local-firebase-emulators-pubsub-topics-create-%):
# 	@echo "📣 Creating local Pub/Sub topic: $@"
# 	@curl -X PUT http://localhost:8085/v1/projects/$(GOOGLE_CLOUD_PROJECT_ID)/topics/$(@:local-firebase-emulators-pubsub-topics-create-%=%)|echo
# .PHONY: $(LOCAL_FIREBASE_EMULATORS_PUB_SUB_TOPICS:%=local-firebase-emulators-pubsub-topics-create-%)

# local-firebase-emulators-pubsub-subscriptions: $(LOCAL_FIREBASE_EMULATORS_PUBSUB_SUBSCRIPTIONS:%=local-firebase-emulators-pubsub-subscriptions-create-%)
# .PHONY: local-firebase-emulators-pubsub-subscriptions

# $(LOCAL_FIREBASE_EMULATORS_PUBSUB_SUBSCRIPTIONS:%=local-firebase-emulators-pubsub-subscriptions-create-%):
# 	@echo "📣 Creating local Pub/Sub subscription: $@"
# 	@echo "📣 LOCAL_FIREBASE_EMULATORS_PUBSUB_SUBSCRIPTIONS: $(LOCAL_FIREBASE_EMULATORS_PUBSUB_SUBSCRIPTIONS)"
# 	@curl -X PUT http://localhost:8085/v1/projects/$(GOOGLE_CLOUD_PROJECT_ID)/subscriptions/$(@:local-firebase-emulators-pubsub-subscriptions-create-%=%) \
# 	  -H "Content-Type: application/json" \
# 	  -d '{ "topic": "projects/$(GOOGLE_CLOUD_PROJECT_ID)/topics/$(LOCAL_FIREBASE_EMULATORS_PUBSUB_VEGETABLE_IMAGES_CREATED_TOPIC)" }'|echo
# .PHONY: $(LOCAL_FIREBASE_EMULATORS_PUBSUB_SUBSCRIPTIONS:%=local-firebase-emulators-pubsub-subscriptions-create-%)

# local-firebase-emulators-pubsub-check:
# 	@echo "📋 Listing local Pub/Sub topics:"
# 	@curl -s http://localhost:8085/v1/projects/$(GOOGLE_CLOUD_PROJECT_ID)/topics | jq .
# 	@echo
# 	@echo "📋 Listing local Pub/Sub subscriptions:"
# 	@curl -s http://localhost:8085/v1/projects/$(GOOGLE_CLOUD_PROJECT_ID)/subscriptions | jq .
# .PHONY: local-firebase-emulators-pubsub-check