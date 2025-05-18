# Compute instance variables for dev environment.
DEV_COMPUTE_INSTANCE_ZONE ?= $(GOOGLE_CLOUD_REGION)-b

DEV_PROJECT_USER_MACHINE_HOST ?= $(PROJECT_USER).$(GOOGLE_CLOUD_REGION).$(DEV_GOOGLE_CLOUD_PROJECT_ID)
DEV_PROJECT_USER_MACHINE_TYPE ?= c3-standard-8
DEV_PROJECT_USER_MACHINE_NAME ?= $(PROJECT_USER)-developer-vm$(DEV_PROJECT_USER_MACHINE_TYPE)

infra-dev-vm-suspend:
ifeq ($(shell test -f /.dockerenv && echo yes),yes)
	@echo "⚠️  Cette commande 'make $@' doit être exécutée depuis le host, pas dans le conteneur."
else
	@echo "Suspending $(DEV_PROJECT_USER_MACHINE_NAME) instance..."
	@$(GCLOUD) compute instances suspend $(DEV_PROJECT_USER_MACHINE_NAME) --zone=$(DEV_COMPUTE_INSTANCE_ZONE)
endif
.PHONY: infra-dev-vm-suspend

infra-dev-vm-start:
ifeq ($(shell test -f /.dockerenv && echo yes),yes)
	@echo "⚠️  Cette commande 'make $@' doit être exécutée depuis le host, pas dans le conteneur."
else
	@echo "Starting $(DEV_PROJECT_USER_MACHINE_NAME) instance...(machine will be shutdown daily at 00:00 if no ssh activity)"
	@$(GCLOUD) compute instances start $(DEV_PROJECT_USER_MACHINE_NAME) --zone=$(DEV_COMPUTE_INSTANCE_ZONE)
endif
.PHONY: infra-dev-vm-start

infra-dev-vm-status:
ifeq ($(shell test -f /.dockerenv && echo yes),yes)
	@echo "⚠️  Cette commande 'make $@' doit être exécutée depuis le host, pas dans le conteneur."
else
	@echo "Checking status of $(DEV_PROJECT_USER_MACHINE_NAME) instance..."
	@$(GCLOUD) compute instances describe $(DEV_PROJECT_USER_MACHINE_NAME) --zone=$(DEV_COMPUTE_INSTANCE_ZONE) --format='get(status)'
endif
.PHONY: infra-dev-vm-status

infra-dev-vm-ssh:
ifeq ($(shell test -f /.dockerenv && echo yes),yes)
	@echo "⚠️  Cette commande 'make $@' doit être exécutée depuis le host, pas dans le conteneur."
else
	@echo "Connecting to $(DEV_PROJECT_USER_MACHINE_NAME) instance..."
	@$(GCLOUD) compute ssh $(DEV_PROJECT_USER_MACHINE_NAME) --zone=$(DEV_COMPUTE_INSTANCE_ZONE)
endif
.PHONY: infra-dev-vm-ssh

infra-dev-vm-ssh-config-host:
ifeq ($(shell test -f /.dockerenv && echo yes),yes)
	@echo "⚠️  Cette commande 'make $@' doit être exécutée depuis le host, pas dans le conteneur."
else
	@echo "Updating SSH config on host..."
	@mkdir -p ~/.ssh ~/.config/gcloud
	@docker run --rm -i -t \
 		-v $(CURDIR):$(CURDIR) \
 		-w $(CURDIR) \
		-e HOME=$$HOME \
		-v $$HOME/.ssh:$$HOME/.ssh \
		-v $$HOME/.config/gcloud:$$HOME/.config/gcloud \
		--entrypoint /bin/bash \
		$(LATEST_BUILDER_IMAGE) \
		 -c 'make infra-dev-vm-ssh-config'	 
endif
.PHONY: infra-dev-vm-ssh-config-host

infra-dev-vm-ssh-config:
	@echo "Generating SSH config entry for $(DEV_PROJECT_USER_MACHINE_NAME)..."
	@$(GCLOUD) compute config-ssh --project=$(DEV_GOOGLE_CLOUD_PROJECT_ID) 
.PHONY: infra-dev-vm-ssh-config

infra-dev-vm-ssh-config-dry-run:
ifeq ($(shell test -f /.dockerenv && echo yes),yes)
	@echo "⚠️  Cette commande 'make $@' doit être exécutée depuis le host, pas dans le conteneur."
else
	@echo "Dry run SSH config entry for $(DEV_PROJECT_USER_MACHINE_NAME).
	@$(GCLOUD) compute config-ssh --project=$(DEV_GOOGLE_CLOUD_PROJECT_ID)  --dry-run \
	  | grep -A4 "$(DEV_PROJECT_USER_MACHINE_NAME)" | tee ./ssh-config_dev-vm.conf
endif
.PHONY: infra-dev-vm-ssh-config-dry-run