-include application/go.mk
-include application/nodejs.mk
-include application/frontend/frontend.mk
-include application/backend/backend.mk
-include application/images/images.mk
-include application/tests/tests.mk

LOCAL_EXAMPLE_APPLICATION_CI_IMAGES_BUILD := \
	local-example-application-backend-image-ci \
	local-application-tests-image-ci

local-example-application-images-ci: $(LOCAL_EXAMPLE_APPLICATION_CI_IMAGES_BUILD)
.PHONY: local-example-application-images-ci

local-example-application-install: \
local-example-application-frontend-build \
local-example-application-frontend-bundle \
local-example-application-backend-install
.PHONY: local-example-application-install
