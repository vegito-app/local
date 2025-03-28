
FIREBASE_EMULATORS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE=$(CURDIR)/firebase/emulators/.docker-buildx-cache
$(FIREBASE_EMULATORS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE):;	@mkdir -p "$@"
ifneq ($(wildcard $(FIREBASE_EMULATORS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)/index.json),)
FIREBASE_EMULATORS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ = type=local,src=$(FIREBASE_EMULATORS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)
endif
FIREBASE_EMULATORS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE= type=local,dest=$(FIREBASE_EMULATORS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)

firebase-emulators-image: docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print firebase-emulators
	@$(DOCKER_BUILDX_BAKE) --load firebase-emulators
.PHONY: firebase-emulators-image

firebase-emulators-image-push: docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print firebase-emulators
	@$(DOCKER_BUILDX_BAKE) --push firebase-emulators
.PHONY: firebase-emulators-image-push

firebase-emulators-image-ci: docker-buildx-setup
	@$(DOCKER_BUILDX_BAKE) --print firebase-emulators
	@$(DOCKER_BUILDX_BAKE) --push firebase-emulators-ci
.PHONY: firebase-emulators-image-ci

FIREBASE_DIR = $(CURDIR)/firebase/emulators
FIREBASE = cd $(FIREBASE_DIR) && firebase
# This is a comma separated list of emulator names.# Valid options are:
# ["auth","functions","firestore","database","hosting","pubsub","storage","eventarc","dataconnect"]
FIREBASE_EMULATORS_SERVICES = auth,functions,firestore

firebase-emulators-prepare: firebase-emulators-install firebase-emulators-init
.PHONY: firebase-emulators-prepare

firebase-emulators-install: gcloud-infra-auth-npm-install
	@cd firebase/functions && npm install
.PHONY: firebase-emulators-install

firebase-emulators-init:
	@$(FIREBASE) init emulators 
.PHONY: firebase-emulators-init

firebase-emulators-functions-serve:
	@cd $(FIREBASE_DIR)/functions && \
	unset GOOGLE_APPLICATION_CREDENTIALS && \
	npm run serve
.PHONY: firebase-emulators-functions-serve

FIREBASE_EMULATORS_DATA := $(CURDIR)/firebase/emulators/data

firebase-emulators-start: firebase-emulators-install
	@unset GOOGLE_APPLICATION_CREDENTIALS || true ; \
	  $(FIREBASE) emulators:start \
	    --import=$(FIREBASE_EMULATORS_DATA) \
	    --export-on-exit $(FIREBASE_EMULATORS_DATA) \
	    --log-verbosity DEBUG \
	    --only $(FIREBASE_EMULATORS_SERVICES)
.PHONY: firebase-emulators-start

firebase-emulators-docker-compose: firebase-emulators-prepare firebase-emulators-docker-compose-up firebase-emulators-docker-compose-logs
.PHONY: firebase-emulators-docker-compose

firebase-emulators-docker-compose-up: firebase-emulators-docker-compose-rm
	@$(CURDIR)/firebase/emulators/docker-start.sh &
	@until nc -z firebase-emulators 4000 ; do \
		sleep 1 ; \
	done
	$(DOCKER_COMPOSE) logs firebase-emulators
	@echo
	@echo Started Firebase Emulator: 
	@echo View Emulator UI at http://127.0.0.1:4000/
	@echo Run "'make $(@:%-up=%-logs)'" to retrieve more logs
.PHONY: firebase-emulators-docker-compose-up

firebase-emulators-docker-compose-stop:
	@-$(DOCKER_COMPOSE) stop firebase-emulators 2>/dev/null
.PHONY: firebase-emulators-docker-compose-stop

firebase-emulators-docker-compose-rm: firebase-emulators-docker-compose-stop
	@$(DOCKER_COMPOSE) rm -f firebase-emulators
.PHONY: firebase-emulators-docker-compose-rm

firebase-emulators-docker-compose-logs:
	@$(DOCKER_COMPOSE) logs --follow firebase-emulators
.PHONY: firebase-emulators-docker-compose-logs

firebase-emulators-docker-compose-sh:
	@$(DOCKER_COMPOSE) exec -it firebase-emulators bash
.PHONY: firebase-emulators-docker-compose-sh

