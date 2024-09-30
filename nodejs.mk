NODE_MODULES := \
	infra/gcloud/auth \
	application/frontend \
	local/firebase/functions

node-modules-npm-check-updates: 
	@$(MAKE) -j $(NODE_MODULES:%=%-npm-check-updates)
.PHONY: node-modules-npm-check-updates 

$(NODE_MODULES:%=%-npm-check-updates):
	@cd $(@:%-npm-check-updates=%) && ncu -u
.PHONY: $(NODE_MODULES:%=%-npm-check-updates)

node-modules-ci: 
	@$(MAKE) -j $(NODE_MODULES:%=%-ci)
.PHONY: node-modules-ci

$(NODE_MODULES:%=%-ci): 
	@$(MAKE) $(@:%-ci=%-clean) $(@:%-ci=%-node-modules)
.PHONY: $(NODE_MODULES:%=%-ci)

node-modules-clean: $(NODE_MODULES:%=%-clean)
.PHONY: node-modules-clean

$(NODE_MODULES:%=%-clean):
	@-rm -rf $(@:%-clean=%/node_modules) $(@:%-clean=%/package-lock.json) 2>/dev/null
.PHONY: $(NODE_MODULES:%=%-clean)

node-modules: $(NODE_MODULES:%=%/node-modules)
.PHONY: node-modules

$(NODE_MODULES:%=%-node-modules):
	@cd $(@:%-node-modules=%) && npm install
.PHONY: $(NODE_MODULES:%=%-node-modules)

$(NODE_MODULES:%=%/node_modules):
	@$(MAKE) $(@:%/node_modules=%-node-modules)