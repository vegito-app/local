# Handle buildx cache in local folder
APPLICATION_IMAGES_CLEANER_IMAGE = $(IMAGES_BASE):application-images-cleaner-$(VERSION)
APPLICATION_IMAGES_CLEANER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE=$(CURDIR)/local/.containers/docker-buildx-cache/application-images-cleaner
$(APPLICATION_IMAGES_CLEANER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE):;	@mkdir -p "$@"
ifneq ($(wildcard $(APPLICATION_IMAGES_CLEANER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)/index.json),)
APPLICATION_IMAGES_CLEANER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ = type=local,src=$(APPLICATION_IMAGES_CLEANER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)
endif
APPLICATION_IMAGES_CLEANER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE= type=local,dest=$(APPLICATION_IMAGES_CLEANER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)

application-images-cleaner-run: $(APPLICATION_IMAGES_CLEANER_INSTALL_BIN)
	@$(APPLICATION_IMAGES_CLEANER_INSTALL_BIN)
.PHONY: application-images-cleaner-run

$(APPLICATION_IMAGES_CLEANER_INSTALL_BIN): application-images-cleaner-install

application-images-cleaner-install:
	@echo Installing images-cleaner...
	@cd application/images/cleaner \
	  && go install -a -ldflags "-linkmode external -extldflags -static"
	#   && go install -a -ldflags "-linkmode external"
	@echo Installed images-cleaner.
.PHONY: application-images-cleaner-install