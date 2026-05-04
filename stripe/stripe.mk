
LOCAL_STRIPE_DIR ?= $(LOCAL_DIR)/stripe

LOCAL_STRIPE_IMAGE_VERSION ?= $(VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME):stripe-$(VERSION)
LOCAL_STRIPE_IMAGE_LATEST ?= $(VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME):stripe-latest

local-stripe-container-up: local-stripe-container-rm
	@${LOCAL_STRIPE_DIR}/container-up.sh
	@$(LOCAL_DOCKER_COMPOSE) logs stripe
	@echo
	@echo Started Androïd studio display: 
	@echo Run "'make $(@:%-up=%-logs)'" to retrieve more logs
.PHONY: local-stripe-container-up

LOCAL_STRIPE ?= $(LOCAL_DOCKER_COMPOSE) run --rm --entrypoint stripe

local-stripe-version:
	@echo "🔎 Checking Trivy version..."
	@-$(LOCAL_STRIPE) version 2>/dev/null
.PHONY:  local-stripe-version

LOCAL_STRIPE_FORWARD_TO ?= http://host.docker.internal:8080/webhooks/stripe

local-stripe-listen: local-stripe-version
	@echo "🚀 Starting Stripe CLI listen with forward to: ${LOCAL_STRIPE_FORWARD_TO}
	@$(LOCAL_STRIPE) listen \
      --forward-to ${LOCAL_STRIPE_FORWARD_TO} \
      --api-key ${LOCAL_STRIPE_DEBUG_KEY}
.PHONY: local-stripe-forward-to

LOCAL_STRIPE_WEBHOOK_SECRET_CMD = $(LOCAL_DOCKER_COMPOSE) exec stripe bash -c '. ~/.stripe_env && echo $$STRIPE_WEBHOOK_SECRET'

local-stripe-webhook-secret:
	$(eval STRIPE_WEBHOOK_SECRET := $(shell $(LOCAL_STRIPE_WEBHOOK_SECRET_CMD)))
	@echo "Stripe webhook secret: ${STRIPE_WEBHOOK_SECRET}"
.PHONY: local-stripe-webhook-secret