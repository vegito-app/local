REACT_APP_UTRADE_VERSION = $(VERSION)

FRONTEND_BUILD_DIR = $(CURDIR)/frontend/build

frontend-build: 
	@cd $(CURDIR)/frontend && npm run build
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

frontend-node-modules:
	@cd $(CURDIR)/frontend && npm install
.PHONY: frontend-node-modules