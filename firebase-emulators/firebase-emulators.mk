FIREBASE_EMULATORS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE=$(CURDIR)/local/.containers/docker-buildx-cache/firebase-emulators
$(FIREBASE_EMULATORS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE):;	@mkdir -p "$@"
ifneq ($(wildcard $(FIREBASE_EMULATORS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)/index.json),)
FIREBASE_EMULATORS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ = type=local,src=$(FIREBASE_EMULATORS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)
endif
FIREBASE_EMULATORS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE= type=local,dest=$(FIREBASE_EMULATORS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE)

FIREBASE_EMULATORS_DIR = $(CURDIR)/local/firebase-emulators
FIREBASE_EMULATORS = cd $(FIREBASE_EMULATORS_DIR) && firebase
# This is a comma separated list of emulator names.# Valid options are:
# ["auth","functions","firestore","database","hosting","pubsub","storage","eventarc","dataconnect"]
FIREBASE_EMULATORS_SERVICES = auth,functions,firestore

firebase-emulators-prepare: firebase-emulators-install firebase-emulators-init
.PHONY: firebase-emulators-prepare

firebase-emulators-install: gcloud-infra-auth-npm-install
	# @cd $(CURDIR)/application/firebase/functions && npm install
.PHONY: firebase-emulators-install

gcloud-infra-auth-npm-install:
	@cd $(CURDIR)/application/firebase/functions/auth && npm install
.PHONY: gcloud-infra-auth-npm-install

firebase-emulators-init:
	@$(FIREBASE_EMULATORS) init emulators 
.PHONY: firebase-emulators-init

firebase-emulators-functions-serve:
	@cd $(FIREBASE_EMULATORS_DIR)/functions && \
	unset GOOGLE_APPLICATION_CREDENTIALS && \
	npm run serve
.PHONY: firebase-emulators-functions-serve

FIREBASE_EMULATORS_DATA := $(CURDIR)/local/firebase-emulators/data

firebase-emulators-start: firebase-emulators-install
	@unset GOOGLE_APPLICATION_CREDENTIALS || true ; \
	  $(FIREBASE_EMULATORS) emulators:start \
	    --import=$(FIREBASE_EMULATORS_DATA) \
	    --export-on-exit $(FIREBASE_EMULATORS_DATA) \
	    --log-verbosity DEBUG \
	    --only $(FIREBASE_EMULATORS_SERVICES)
.PHONY: firebase-emulators-start

firebase-emulators-docker-compose: firebase-emulators-prepare firebase-emulators-docker-compose-up firebase-emulators-docker-compose-logs
.PHONY: firebase-emulators-docker-compose

firebase-emulators-docker-compose-up: firebase-emulators-docker-compose-rm
	@$(CURDIR)/local/firebase-emulators/docker-compose-up.sh &
	@until nc -z firebase-emulators 4000 ; do \
		sleep 1 ; \
	done
	$(DOCKER_COMPOSE) logs firebase-emulators
	@echo
	@echo Started Firebase Emulator: 
	@echo View Emulator UI at http://127.0.0.1:4000/
	@echo Run "'make $(@:%-up=%-logs)'" to retrieve more logs
.PHONY: firebase-emulators-docker-compose-up
