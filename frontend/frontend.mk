REACT_APP_VERSION ?= $(VERSION)

FRONTEND_BUILD_DIR = $(CURDIR)/frontend/build

frontend-build: frontend/node_modules
	@cd frontend && npm run build
.PHONY: frontend-build

$(FRONTEND_BUILD_DIR): frontend-build

UI_JAVASCRIPT_SOURCE_FILE ?= $(CURDIR)/frontend/build/bundle.js

frontend-bundle: 
	@cd $(CURDIR)/frontend && npm run dev:server
.PHONY: frontend-bundle

$(UI_JAVASCRIPT_SOURCE_FILE): frontend-bundle

frontend-start:
	@cd $(CURDIR)/frontend && npm start
.PHONY: frontend-start

frontend-npm-ci:
	@cd $(CURDIR)/frontend && npm ci --silent
.PHONY: frontend-npm-ci