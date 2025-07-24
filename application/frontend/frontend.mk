LOCAL_REACT_APP_VERSION = $(LOCAL_VERSION)

LOCAL_APPLICATION_FRONTEND_BUILD_DIR = $(CURDIR)/application/frontend/build

local-application-example-frontend-build: application/frontend/node_modules
	@cd $(CURDIR)/application/frontend && npm --loglevel=verbose run build
.PHONY: local-application-example-frontend-build

$(LOCAL_APPLICATION_FRONTEND_BUILD_DIR): local-application-example-frontend-build

LOCAL_APPLICATION_FRONTEND_BUILD_BUNDLE_JS = $(CURDIR)/application/frontend/build/bundle.js

local-application-example-frontend-bundle: $(LOCAL_APPLICATION_FRONTEND_BUILD_DIR)
	@cd $(CURDIR)/application/frontend && npm run dev:server
.PHONY: local-application-example-frontend-bundle

$(LOCAL_APPLICATION_FRONTEND_BUILD_BUNDLE_JS): local-application-example-frontend-bundle

local-application-frontend-start:
	@cd $(CURDIR)/application/frontend && npm start
.PHONY: local-application-frontend-start

local-application-frontend-npm-ci:
	@cd $(CURDIR)/application/frontend && npm ci
.PHONY: local-application-frontend-npm-ci