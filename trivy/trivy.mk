
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

LOCAL_TRIVY ?= $(LOCAL_DOCKER_COMPOSE) run --rm trivy

LOCAL_TRIVY_IMAGE_SCAN_INPUT ?= $(LOCAL_BUILDER_IMAGE)
LOCAL_TRIVY_IMAGE_SCAN_OUTPUT_REPORT_HTML ?= trivy-report.html
LOCAL_TRIVY_IMAGE_SCAN_INPUT_SEVERITY ?= CRITICAL,HIGH
LOCAL_TRIVY_IMAGE_SCAN_INPUT_EXIT_CODE ?= 1

local-trivy-version:
	@echo "🔎 Checking Trivy version..."
	@-$(LOCAL_TRIVY) version 2>/dev/null
.PHONY:  local-trivy-version

local-trivy-image-scan: local-trivy-version local-trivy-pull-scan-input-image
	@echo "🔎 Scanning image: $(LOCAL_TRIVY_IMAGE_SCAN_INPUT) using Trivy:"
	@echo "	🗒️ Report: $(LOCAL_TRIVY_IMAGE_SCAN_OUTPUT_REPORT_HTML)"
	@echo "	🗒️ Severity: $(LOCAL_TRIVY_IMAGE_SCAN_INPUT_SEVERITY)"
	@echo "	🗒️ Exit code: $(LOCAL_TRIVY_IMAGE_SCAN_INPUT_EXIT_CODE)"
	@$(LOCAL_TRIVY) image \
	  --format template \
	  --template "@.github/templates/trivy-html.tpl.html" \
	  --output $(LOCAL_TRIVY_IMAGE_SCAN_OUTPUT_REPORT_HTML) \
	  --exit-code $(LOCAL_TRIVY_IMAGE_SCAN_INPUT_EXIT_CODE) \
	  --ignore-unfixed \
	  --scanners vuln \
	  --severity "$(LOCAL_TRIVY_IMAGE_SCAN_INPUT_SEVERITY)" \
	  $(LOCAL_TRIVY_IMAGE_SCAN_INPUT)
.PHONY: local-trivy-image-scan

local-trivy-pull-scan-input-image:
	@echo "🔎 Pulling image: $(LOCAL_TRIVY_IMAGE_SCAN_INPUT)"
	@docker pull $(LOCAL_TRIVY_IMAGE_SCAN_INPUT)
.PHONY: local-trivy-pull-scan-input-image

local-trivy-image-scan-ci:	@echo "Running operation 'local-containers-$(@:local-containers-%-ci=%)' for all local containers in CI..."
	@echo "🔎 Scanning image: $(LOCAL_TRIVY_IMAGE_SCAN_INPUT)"
	@echo "Using container: $(LOCAL_BUILDER_IMAGE)"
	@$(LOCAL_DEV_CONTAINER_RUN) \
	  make local-trivy-image-scan \
	  LOCAL_TRIVY_IMAGE_SCAN_INPUT=$(LOCAL_TRIVY_IMAGE_SCAN_INPUT) \
	  LOCAL_TRIVY_CACHES_REFRESH=$(LOCAL_TRIVY_CACHES_REFRESH)
.PHONY: local-trivy-image-scan-ci

