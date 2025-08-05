NODE_MODULES := \
	$(APPLICATION_DIR)/frontend \
	$(FIREBASE_EMULATORS_DIR)/functions \
	$(FIREBASE_EMULATORS_DIR)/functions/auth

local-node-modules-npm-check-updates: 
	@$(MAKE) -j $(NODE_MODULES:%=%-npm-check-updates)
.PHONY: local-node-modules-npm-check-updates 

$(NODE_MODULES:%=local-%-npm-check-updates):
	@cd $(@:%-npm-check-updates=%) && ncu -u
.PHONY: $(NODE_MODULES:%=%-npm-check-updates)

local-node-modules-ci: 
	@$(MAKE) $(NODE_MODULES:%=local-%-ci)
.PHONY: local-node-modules-ci

$(NODE_MODULES:%=local-%-ci): 
	$(MAKE) $(@:%-ci=%-clean) $(@:%-ci=%-node-modules)
.PHONY: $(NODE_MODULES:%=%-ci)

local-node-modules-clean: $(NODE_MODULES:%=local-%-clean)
.PHONY: local-node-modules-clean

$(NODE_MODULES:%=local-%-clean):
	-rm -rf $(@:local-%-clean=%/node_modules) $(@:local-%-clean=%/package-lock.json) 2>/dev/null
.PHONY: $(NODE_MODULES:%=local-%-clean)

local-node-modules: $(NODE_MODULES:%=%/node_modules)
.PHONY: local-node-modules

$(NODE_MODULES:%=local-%-node-modules):
	cd $(@:local-%-node-modules=%) && npm install
.PHONY: $(NODE_MODULES:%=local-%-node-modules)

$(NODE_MODULES:%=%/node_modules):
	@$(MAKE) $(@:%/node_modules=local-%-node-modules)

local-node-available-from-nvm-ls-remote:
	@bash -c ' \
	  source $(NVM_DIR)/nvm.sh ; \
	  nvm ls-remote \
	'
.PHONY: local-node-available-from-nvm-ls-remote

local-node-list-npm-versions:
	@bash -c " \
	  source $(NVM_DIR)/nvm.sh ; \
      npm view npm versions --json | jq -r '.[] | select(startswith(\"10.\"))' \
	"
.PHONY: local-node-list-npm-versions