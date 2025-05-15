# Compute instance variables for dev environment.
DEV_COMPUTE_INSTANCE_ZONE = $(GOOGLE_CLOUD_REGION)-b
DEV_PROJECT_USER_MACHINE_HOST = $(PROJECT_USER).$(GOOGLE_CLOUD_REGION).$(DEV_GOOGLE_CLOUD_PROJECT_ID)

dev-infra-vm-suspend:
ifeq ($(shell test -f /.dockerenv && echo yes),yes)
	@echo "⚠️  Cette commande 'make $@' doit être exécutée depuis le host, pas dans le conteneur."
else
	@echo "Suspending $(DEV_PROJECT_USER_MACHINE_NAME) instance..."
	@$(GCLOUD) compute instances suspend $(DEV_PROJECT_USER_MACHINE_NAME) --zone=$(DEV_COMPUTE_INSTANCE_ZONE)
endif
.PHONY: dev-infra-vm-suspend

dev-infra-vm-start:
ifeq ($(shell test -f /.dockerenv && echo yes),yes)
	@echo "⚠️  Cette commande 'make $@' doit être exécutée depuis le host, pas dans le conteneur."
else
	@echo "Starting $(DEV_PROJECT_USER_MACHINE_NAME) instance...(machine will be shutdown daily at 00:00 if no ssh activity)"
	@$(GCLOUD) compute instances start $(DEV_PROJECT_USER_MACHINE_NAME) --zone=$(DEV_COMPUTE_INSTANCE_ZONE)
endif
.PHONY: dev-infra-vm-start

dev-infra-vm-status:
ifeq ($(shell test -f /.dockerenv && echo yes),yes)
	@echo "⚠️  Cette commande 'make $@' doit être exécutée depuis le host, pas dans le conteneur."
else
	@echo "Checking status of $(DEV_PROJECT_USER_MACHINE_NAME) instance..."
	@$(GCLOUD) compute instances describe $(DEV_PROJECT_USER_MACHINE_NAME) --zone=$(DEV_COMPUTE_INSTANCE_ZONE) --format='get(status)'
endif
.PHONY: dev-infra-vm-status

dev-infra-vm-ssh:
ifeq ($(shell test -f /.dockerenv && echo yes),yes)
	@echo "⚠️  Cette commande 'make $@' doit être exécutée depuis le host, pas dans le conteneur."
else
	@echo "Connecting to $(DEV_PROJECT_USER_MACHINE_NAME) instance..."
	@$(GCLOUD) compute ssh $(DEV_PROJECT_USER_MACHINE_NAME) --zone=$(DEV_COMPUTE_INSTANCE_ZONE)
endif
.PHONY: dev-infra-vm-ssh

dev-infra-vm-ssh-config-host:
ifeq ($(shell test -f /.dockerenv && echo yes),yes)
	@echo "⚠️  Cette commande 'make $@' doit être exécutée depuis le host, pas dans le conteneur."
else
	@echo "Updating SSH config on host..."
	@docker run --rm -i -t \
 		-v $(CURDIR):$(CURDIR) \
 		-w $(CURDIR) \
		-e HOME=$$HOME \
		-v $$HOME/.ssh:$$HOME/.ssh \
		-v $$HOME/.config/gcloud:$$HOME/.config/gcloud \
		--entrypoint /bin/bash \
		$(LATEST_BUILDER_IMAGE) \
		 -c 'make dev-infra-vm-ssh-config'	 
endif
.PHONY: dev-infra-vm-ssh-config-host

dev-infra-vm-ssh-config:
	@echo "Generating SSH config entry for $(DEV_PROJECT_USER_MACHINE_NAME)..."
	@$(GCLOUD) compute config-ssh --project=$(DEV_GOOGLE_CLOUD_PROJECT_ID) 
.PHONY: dev-infra-vm-ssh-config

dev-infra-vm-ssh-config-dry-run:
ifeq ($(shell test -f /.dockerenv && echo yes),yes)
	@echo "⚠️  Cette commande 'make $@' doit être exécutée depuis le host, pas dans le conteneur."
else
	@echo "Dry run SSH config entry for $(DEV_PROJECT_USER_MACHINE_NAME).
	@$(GCLOUD) compute config-ssh --project=$(DEV_GOOGLE_CLOUD_PROJECT_ID)  --dry-run \
	  | grep -A4 "$(DEV_PROJECT_USER_MACHINE_NAME)" | tee ./ssh-config_dev-vm.conf
endif
.PHONY: dev-infra-vm-ssh-config-dry-run