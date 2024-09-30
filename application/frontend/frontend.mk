REACT_APP_VERSION ?= $(VERSION)

FRONTEND_BUILD_DIR = $(CURDIR)/application/frontend/build

frontend-build: application/frontend/node_modules
	@cd $(CURDIR)/application/frontend && npm run build
.PHONY: frontend-build

$(FRONTEND_BUILD_DIR): frontend-build

UI_JAVASCRIPT_SOURCE_FILE ?= $(CURDIR)/application/frontend/build/bundle.js

frontend-bundle: 
	@cd $(CURDIR)/application/frontend && npm run dev:server
.PHONY: frontend-bundle

$(UI_JAVASCRIPT_SOURCE_FILE): frontend-bundle

frontend-start:
	@cd $(CURDIR)/application/frontend && npm start
.PHONY: frontend-start

frontend-npm-ci:
	@cd $(CURDIR)/application/frontend && npm ci --silent
.PHONY: frontend-npm-ci