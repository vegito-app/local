REACT_APP_VERSION = $(VERSION)

FRONTEND_BUILD_DIR = $(CURDIR)/example-application/frontend/build

example-application-frontend-build: example-application/frontend/node_modules
	@cd $(CURDIR)/example-application/frontend && npm --loglevel=verbose run build
.PHONY: example-application-frontend-build

$(FRONTEND_BUILD_DIR): example-application-frontend-build

UI_JAVASCRIPT_SOURCE_FILE = $(CURDIR)/example-application/frontend/build/bundle.js

example-application-frontend-bundle: 
	@cd $(CURDIR)/example-application/frontend && npm run dev:server
.PHONY: example-application-frontend-bundle

$(UI_JAVASCRIPT_SOURCE_FILE): example-application-frontend-bundle

example-application-frontend-start:
	@cd $(CURDIR)/example-application/frontend && npm start
.PHONY: example-application-frontend-start

example-application-frontend-npm-ci:
	@cd $(CURDIR)/example-application/frontend && npm ci
.PHONY: example-application-frontend-npm-ci