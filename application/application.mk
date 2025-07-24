-include application/go.mk
-include application/nodejs.mk
-include application/frontend/frontend.mk
-include application/backend/backend.mk
-include application/images/images.mk
-include application/tests/tests.mk

local-application-example-images-ci: \
local-application-example-backend-image-ci \
local-application-tests-image-ci
.PHONY: local-application-example-images-ci

local-application-example-install: \
local-application-example-frontend-build \
local-application-example-frontend-bundle \
local-application-example-backend-install
.PHONY: local-application-example-install

LOCAL_APPLICATION_DOCKER_BUILDX_BAKE_IMAGES = \
  application-backend

$(LOCAL_APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:%=local-%-image): docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print $(@:local-%-image=%)
	@$(DOCKER_BUILDX_BAKE) --load $(@:local-%-image=%)
.PHONY: $(LOCAL_APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:%=local-%-image)

$(LOCAL_APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:%=local-%-image-push):
	@$(DOCKER_BUILDX_BAKE) --print $(@:local-%-image-push=%)
	@$(DOCKER_BUILDX_BAKE) --push $(@:local-%-image-push=%)
.PHONY: $(LOCAL_APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:%=local-%-image-push)

# $(LOCAL_APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:%=local-%-image-pull):
# 	@$(DOCKER_BUILDX_BAKE) --print $(@:local-%-image-pull=%)
# 	@$(DOCKER_BUILDX_BAKE) --pull $(@:local-%-image-pull=%)
# .PHONY: $(LOCAL_APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:%=local-%-image-pull)

$(LOCAL_APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:%=local-%-image-ci): docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print $(@:local-%-image-ci=%-ci)
	@$(DOCKER_BUILDX_BAKE) --push $(@:local-%-image-ci=%-ci)
.PHONY: $(LOCAL_APPLICATION_DOCKER_BUILDX_BAKE_IMAGES:%=local-%-image-ci)
