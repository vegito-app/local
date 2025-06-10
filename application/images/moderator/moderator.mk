# Handle buildx cache in local folder
APPLICATION_IMAGES_MODERATOR_IMAGE = $(IMAGES_BASE):application-images-moderator-$(VERSION)
APPLICATION_IMAGES_MODERATOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE=$(CURDIR)/local/.containers/docker-buildx-cache/application-images-moderator
$(APPLICATION_IMAGES_MODERATOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE):;	@mkdir -p "$@"
ifneq ($(wildcard $(APPLICATION_IMAGES_MODERATOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)/index.json),)
APPLICATION_IMAGES_MODERATOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ = type=local,src=$(APPLICATION_IMAGES_MODERATOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)
endif
APPLICATION_IMAGES_MODERATOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE= type=local,dest=$(APPLICATION_IMAGES_MODERATOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)

application-images-moderator-run: $(APPLICATION_IMAGES_MODERATOR_INSTALL_BIN)
	@$(APPLICATION_IMAGES_MODERATOR_INSTALL_BIN)
.PHONY: application-images-moderator-run

$(APPLICATION_IMAGES_MODERATOR_INSTALL_BIN): application-images-moderator-install

application-images-moderator-install:
	@echo Installing images-moderator...
	@cd application/images/moderator \
	  && go install -a -ldflags "-linkmode external -extldflags -static"
	#   && go install -a -ldflags "-linkmode external"
	@echo Installed images-moderator.
.PHONY: application-images-moderator-install