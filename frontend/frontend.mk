REACT_APP_VERSION = $(VERSION)

FRONTEND_BUILD_DIR = $(APPLICATION_DIR)/frontend/build

application-frontend-build: $(APPLICATION_DIR)/frontend/node_modules
	@cd $(APPLICATION_DIR)/frontend && npm --loglevel=verbose run build
.PHONY: application-frontend-build

$(FRONTEND_BUILD_DIR): application-frontend-build

UI_JAVASCRIPT_SOURCE_FILE = $(APPLICATION_DIR)/frontend/build/bundle.js

application-frontend-bundle: 
	@cd $(APPLICATION_DIR)/frontend && npm run dev:server
.PHONY: application-frontend-bundle

$(UI_JAVASCRIPT_SOURCE_FILE): application-frontend-bundle

application-frontend-start:
	@cd $(APPLICATION_DIR)/frontend && npm start
.PHONY: application-frontend-start

application-frontend-npm-ci:
	@cd $(APPLICATION_DIR)/frontend && npm ci
.PHONY: application-frontend-npm-ci