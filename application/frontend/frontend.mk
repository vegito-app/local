LOCAL_REACT_APP_VERSION = $(LOCAL_VERSION)

LOCAL_APPLICATION_FRONTEND_BUILD_DIR = $(CURDIR)/application/frontend/build

local-example-application-frontend-build: application/frontend/node_modules
	@cd $(CURDIR)/application/frontend && npm --loglevel=verbose run build
.PHONY: local-example-application-frontend-build

$(LOCAL_APPLICATION_FRONTEND_BUILD_DIR): local-example-application-frontend-build

LOCAL_APPLICATION_FRONTEND_BUILD_BUNDLE_JS = $(CURDIR)/application/frontend/build/bundle.js

local-example-application-frontend-bundle: $(LOCAL_APPLICATION_FRONTEND_BUILD_DIR)
	@cd $(CURDIR)/application/frontend && npm run dev:server
.PHONY: local-example-application-frontend-bundle

$(LOCAL_APPLICATION_FRONTEND_BUILD_BUNDLE_JS): local-example-application-frontend-bundle

local-application-frontend-start:
	@cd $(CURDIR)/application/frontend && npm start
.PHONY: local-application-frontend-start

local-application-frontend-npm-ci:
	@cd $(CURDIR)/application/frontend && npm ci
.PHONY: local-application-frontend-npm-ci