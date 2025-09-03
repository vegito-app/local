REACT_APP_VERSION = $(VERSION)

FRONTEND_BUILD_DIR = $(CURDIR)/application/frontend/build

local-application-frontend-build: application/frontend/node_modules
	@cd $(CURDIR)/application/frontend && npm --loglevel=verbose run build
.PHONY: local-application-frontend-build

$(FRONTEND_BUILD_DIR): local-application-frontend-build

UI_JAVASCRIPT_SOURCE_FILE = $(CURDIR)/application/frontend/build/bundle.js

local-application-frontend-bundle: 
	@cd $(CURDIR)/application/frontend && npm run dev:server
.PHONY: local-application-frontend-bundle

$(UI_JAVASCRIPT_SOURCE_FILE): local-application-frontend-bundle

local-application-frontend-start:
	@cd $(CURDIR)/application/frontend && npm start
.PHONY: local-application-frontend-start

local-application-frontend-npm-ci:
	@cd $(CURDIR)/application/frontend && npm ci
.PHONY: local-application-frontend-npm-ci