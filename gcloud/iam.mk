gcloud-roles-list:
	@$(GCLOUD) iam roles list
.PHONY: gcloud-roles-list

gcloud-serviceaccounts-list:
	@$(GCLOUD) iam service-accounts list
.PHONY: gcloud-serviceaccounts-list

gcloud-serviceaccount-roles: $(GCLOUD_SERVICE_ACCOUNTS:%=gcloud-%-serviceaccount-bindings-roles)
.PHONY: gcloud-serviceaccount-roles

$(GCLOUD_SERVICE_ACCOUNTS:%=gcloud-%-serviceaccount-bindings-roles):
	@echo Print bindings members roles for $(@:gcloud-%-serviceaccount-bindings-roles=%):
	@$(GCLOUD) projects get-iam-policy $(GOOGLE_CLOUD_PROJECT_ID) \
	  --flatten="bindings[].members" --format='table(bindings.role)' \
	  --filter="bindings.members:serviceaccount:$(@:gcloud-%-serviceaccount-bindings-roles=%)"
.PHONY: $(GCLOUD_SERVICE_ACCOUNTS:%=gcloud-%-serviceaccount-bindings-roles)

gcloud-serviceaccount-iam-policy: $(GCLOUD_SERVICE_ACCOUNTS:%=gcloud-%-serviceaccount-iam-policy)
.PHONY: gcloud-serviceaccount-iam-policy

$(GCLOUD_SERVICE_ACCOUNTS:%=gcloud-%-serviceaccount-iam-policy):
	@echo 📋 listing service-account iam policies of $(@:%=gcloud-%-serviceaccount-iam-policy)
	@-$(GCLOUD) iam service-accounts get-iam-policy $(@:gcloud-%-serviceaccount-iam-policy=%)
.PHONY: $(GCLOUD_SERVICE_ACCOUNTS:%=gcloud-%-serviceaccount-iam-policy)

gcloud-serviceaccount-keys-list: $(GCLOUD_SERVICE_ACCOUNTS:%=gcloud-%-serviceaccount-keys-list)
.PHONY: gcloud-serviceaccount-keys-list

$(GCLOUD_SERVICE_ACCOUNTS:%=gcloud-%-serviceaccount-keys-list):
	@echo 📋 listing keys of service account $(@:gcloud-%-serviceaccount-keys-list=%)
	@-$(GCLOUD) iam service-accounts keys list --iam-account $(@:gcloud-%-serviceaccount-keys-list=%)
.PHONY: $(GCLOUD_SERVICE_ACCOUNTS:%=gcloud-%-serviceaccount-keys-list)

$(GCLOUD_SERVICE_ACCOUNTS:%=gcloud-%-serviceaccount-keys-rm):
	@echo 📋 removing keys of service account $(@:gcloud-%-serviceaccount-keys-rm=%)
	@-$(GCLOUD) iam service-accounts keys delete $$KEY \
	  --iam-account=$(@:gcloud-%-serviceaccount-keys-rm=%) \
	  --quiet;
.PHONY: $(GCLOUD_SERVICE_ACCOUNTS:%=gcloud-%-serviceaccount-keys-rm)

gcloud-user-iam-sa-keys-list: gcloud-$(VEGITO_GCLOUD_DEVELOPER_SERVICE_ACCOUNT)-serviceaccount-keys-list
.PHONY: gcloud-user-iam-sa-keys-list

gcloud-user-iam-sa-keys-clean-oldest-3:
	@echo "🔐 Récupération des clés pour $(VEGITO_GCLOUD_DEVELOPER_SERVICE_ACCOUNT)..."
	@KEYS=$$($(GCLOUD) iam service-accounts keys list \
	  --iam-account=$(VEGITO_GCLOUD_DEVELOPER_SERVICE_ACCOUNT) \
	  --format="value(name)" --sort-by=validAfterTime | head -n 3) \
	&& for KEY in $$KEYS; do \
	  echo "🗑️ Suppression de la clé $$KEY..."; \
	  $(GCLOUD) iam service-accounts keys delete $$KEY \
	  --project=$(GOOGLE_CLOUD_PROJECT_ID) \
	  --iam-account=$(VEGITO_GCLOUD_DEVELOPER_SERVICE_ACCOUNT) \
	  --quiet; \
	done
.PHONY: gcloud-user-iam-sa-keys-clean-oldest-3

gcloud-user-iam-sa-keys-clean-all:
	@echo "🔐 Récupération des clés pour $(VEGITO_GCLOUD_DEVELOPER_SERVICE_ACCOUNT)..."
	@KEYS=$$($(GCLOUD) iam service-accounts keys list \
	  --iam-account=$(VEGITO_GCLOUD_DEVELOPER_SERVICE_ACCOUNT) \
	  --format="value(name)"); \
	for KEY in $$KEYS; do \
	  echo "🗑️ Suppression de la clé $$KEY..."; \
	  $(GCLOUD) iam service-accounts keys delete $$KEY \
	  --iam-account=$(VEGITO_GCLOUD_DEVELOPER_SERVICE_ACCOUNT) \
	  --quiet; \
	done
.PHONY: gcloud-user-iam-sa-keys-clean-all

GCLOUD_USERS_EMAILS := \
  davidberich@gmail.com

gcloud-users-roles: $(GCLOUD_USERS_EMAILS:%=gcloud-user-%-roles)
.PHONY: gcloud-users-roles

$(GCLOUD_USERS_EMAILS:%=gcloud-user-%-roles):
	@echo iam member '$(@:gcloud-user-%-roles=%)' roles:
	@$(GCLOUD) projects get-iam-policy $(GOOGLE_CLOUD_PROJECT_ID) \
	  --flatten="bindings[].members" \
	  --format='table(bindings.role)' \
	  --filter="bindings.members:$(@:gcloud-user-%-roles=%)"
.PHONY: $(GCLOUD_USERS_EMAILS:%=gcloud-user-%-roles)

