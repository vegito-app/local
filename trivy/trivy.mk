LOCAL_TRIVY_DIR ?= $(LOCAL_DIR)/trivy

LOCAL_TRIVY_IMAGE_VERSION ?= $(VEGITO_LOCAL_PUBLIC_IMAGES_BASE):trivy-$(VERSION)
LOCAL_TRIVY_IMAGE_LATEST ?= $(VEGITO_LOCAL_PUBLIC_IMAGES_BASE):trivy-latest

local-trivy-container-up: local-trivy-container-rm
	@$(LOCAL_TRIVY_DIR)/container-up.sh
	@$(LOCAL_DOCKER_COMPOSE) logs trivy
	@echo
	@echo Started Androïd studio display: 
	@echo Run "'make $(@:%-up=%-logs)'" to retrieve more logs
.PHONY: local-trivy-container-up

LOCAL_TRIVY ?= $(LOCAL_DOCKER_COMPOSE) run trivy --rm \
  $(LOCAL_TRIVY_IMAGE_LATEST) trivy 

LOCAL_TRIVY_IMAGE_SCAN_INPUT ?= $(LOCAL_TRIVY_IMAGE_LATEST)
LOCAL_TRIVY_OUTPUT ?= trivy-report.html

local-trivy-image-scan:
	@echo "🔎 Scanning image: $(LOCAL_TRIVY_IMAGE_SCAN_INPUT)"
	@$(LOCAL_TRIVY) image \
    --format template \
    --template "@.github/templates/trivy-html.tpl.html" \
    --output trivy-report.html \
    --exit-code $${INPUT_EXIT_CODE:-1} \
    --ignore-unfixed \
    --vuln-type os,library \
    --severity "$${INPUT_SEVERITY:-CRITICAL,HIGH}" \
    $(LOCAL_TRIVY_IMAGE_SCAN_INPUT)
.PHONY: local-trivy-image-scan

local-trivy-image-scan-ci:	@echo "Running operation 'local-containers-$(@:local-containers-%-ci=%)' for all local containers in CI..."
	@echo "🔎 Scanning image: $(LOCAL_TRIVY_IMAGE_SCAN_INPUT)"
	@echo "Using container: $(LOCAL_BUILDER_IMAGE)"
	@$(LOCAL_DEV_CONTAINER_RUN) \
	  make local-trivy-image-scan \
	    LOCAL_TRIVY_IMAGE_SCAN_INPUT=$(LOCAL_TRIVY_IMAGE_SCAN_INPUT) \
      LOCAL_TRIVY_CACHES_REFRESH=$(LOCAL_TRIVY_CACHES_REFRESH)
.PHONY: local-trivy-image-scan-ci

