REACT_APP_VERSION = $(VERSION)

FRONTEND_BUILD_DIR = $(CURDIR)/example-application/frontend/build

local-example-application-frontend-build: example-application/frontend/node_modules
	@cd $(CURDIR)/example-application/frontend && npm --loglevel=verbose run build
.PHONY: local-example-application-frontend-build

$(FRONTEND_BUILD_DIR): local-example-application-frontend-build

UI_JAVASCRIPT_SOURCE_FILE = $(CURDIR)/example-application/frontend/build/bundle.js

local-example-application-frontend-bundle: 
	@cd $(CURDIR)/example-application/frontend && npm run dev:server
.PHONY: local-example-application-frontend-bundle

$(UI_JAVASCRIPT_SOURCE_FILE): local-example-application-frontend-bundle

local-example-application-frontend-start:
	@cd $(CURDIR)/example-application/frontend && npm start
.PHONY: local-example-application-frontend-start

local-example-application-frontend-npm-ci:
	@cd $(CURDIR)/example-application/frontend && npm ci
.PHONY: local-example-application-frontend-npm-ci