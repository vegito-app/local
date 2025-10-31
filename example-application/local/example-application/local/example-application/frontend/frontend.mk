VEGITO_EXAMPLE_APPLICATION_FRONTEND_DIR ?= $(VEGITO_EXAMPLE_APPLICATION_DIR)/frontend
REACT_APP_VERSION = $(VERSION)

FRONTEND_BUILD_DIR = $(VEGITO_EXAMPLE_APPLICATION_FRONTEND_DIR)/build

example-application-frontend-build: $(VEGITO_EXAMPLE_APPLICATION_FRONTEND_DIR)/node_modules
	@cd $(VEGITO_EXAMPLE_APPLICATION_FRONTEND_DIR) && npm --loglevel=verbose run build
.PHONY: example-application-frontend-build

$(FRONTEND_BUILD_DIR): example-application-frontend-build

UI_JAVASCRIPT_SOURCE_FILE = $(VEGITO_EXAMPLE_APPLICATION_FRONTEND_DIR)/build/bundle.js

example-application-frontend-bundle: 
	@cd $(VEGITO_EXAMPLE_APPLICATION_FRONTEND_DIR) && npm run dev:server
.PHONY: example-application-frontend-bundle

$(UI_JAVASCRIPT_SOURCE_FILE): example-application-frontend-bundle

example-application-frontend-start:
	@cd $(VEGITO_EXAMPLE_APPLICATION_FRONTEND_DIR) && npm start
.PHONY: example-application-frontend-start

example-application-frontend-npm-ci:
	@cd $(VEGITO_EXAMPLE_APPLICATION_FRONTEND_DIR) && npm ci
.PHONY: example-application-frontend-npm-ci