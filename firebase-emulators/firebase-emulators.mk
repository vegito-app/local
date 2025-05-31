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
FIREBASE_EMULATORS_SERVICES = auth,functions,firestore,storage,pubsub

local-firebase-emulators-prepare: local-firebase-emulators-install local-firebase-emulators-init
.PHONY: local-firebase-emulators-prepare

local-firebase-emulators-install: gcloud-infra-auth-npm-install
	# @cd $(CURDIR)/application/firebase/functions && npm install
.PHONY: local-firebase-emulators-install

gcloud-infra-auth-npm-install:
	@cd $(CURDIR)/application/firebase/functions/auth && npm install
.PHONY: gcloud-infra-auth-npm-install

local-firebase-emulators-init:
	@$(FIREBASE_EMULATORS) init emulators 
.PHONY: local-firebase-emulators-init

local-firebase-emulators-functions-serve:
	@cd $(FIREBASE_EMULATORS_DIR)/functions && \
	unset GOOGLE_APPLICATION_CREDENTIALS && \
	npm run serve
.PHONY: local-firebase-emulators-functions-serve

FIREBASE_EMULATORS_DATA := $(CURDIR)/local/firebase-emulators/data

local-firebase-emulators-start: local-firebase-emulators-install
	@unset GOOGLE_APPLICATION_CREDENTIALS || true ; \
	  $(FIREBASE_EMULATORS) emulators:start \
	    --import=$(FIREBASE_EMULATORS_DATA) \
	    --export-on-exit $(FIREBASE_EMULATORS_DATA) \
	    --log-verbosity DEBUG \
	    --only $(FIREBASE_EMULATORS_SERVICES)
.PHONY: local-firebase-emulators-start

local-firebase-emulators-docker-compose: local-firebase-emulators-prepare local-firebase-emulators-docker-compose-up local-firebase-emulators-docker-compose-logs
.PHONY: local-firebase-emulators-docker-compose

local-firebase-emulators-docker-compose-up: local-firebase-emulators-docker-compose-rm
	@$(CURDIR)/local/firebase-emulators/docker-compose-up.sh &
	@until nc -z firebase-emulators 4000 ; do \
		sleep 1 ; \
	done
	$(LOCAL_DOCKER_COMPOSE) logs firebase-emulators
	@echo
	@echo Started Firebase Emulator: 
	@echo View Emulator UI at http://127.0.0.1:4000/
	@echo Run "'make $(@:%-up=%-logs)'" to retrieve more logs
.PHONY: local-firebase-emulators-docker-compose-up
