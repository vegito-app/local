
LOCAL_FIREBASE_EMULATORS_IMAGE =  $(LATEST_BUILDER_IMAGE)
LOCAL_FIREBASE_DIR = $(CURDIR)/local/firebase
LOCAL_FIREBASE = cd $(LOCAL_FIREBASE_DIR) && firebase
# This is a comma separated list of emulator names.# Valid options are:
# ["auth","functions","firestore","database","hosting","pubsub","storage","eventarc","dataconnect"]
LOCAL_FIREBASE_EMULATORS_SERVICES = auth,functions,firestore

local-firebase-emulators-prepare: local-firebase-emulators-install local-firebase-emulators-init
.PHONY: local-firebase-emulators

local-firebase-emulators-install: gcloud-infra-auth-npm-install
	@cd local/firebase/functions && npm install
.PHONY: local-firebase-emulators-install

local-firebase-emulators-init:
	@$(LOCAL_FIREBASE) init emulators 
.PHONY: local-firebase-emulators-init

local-firebase-emulators-functions-serve:
	@cd $(LOCAL_FIREBASE_DIR)/functions && \
	unset GOOGLE_APPLICATION_CREDENTIALS && \
	npm run serve
.PHONY: local-firebase-emulators-functions-serve

LOCAL_FIREBASE_EMULATORS_DATA := $(CURDIR)/local/firebase/data

local-firebase-emulators-start: local-firebase-emulators-install
	@unset GOOGLE_APPLICATION_CREDENTIALS || true ; \
	  $(LOCAL_FIREBASE) emulators:start \
	    --import=$(LOCAL_FIREBASE_EMULATORS_DATA) \
	    --export-on-exit $(LOCAL_FIREBASE_EMULATORS_DATA) \
	    --log-verbosity DEBUG \
	    --only $(LOCAL_FIREBASE_EMULATORS_SERVICES)
.PHONY: local-firebase-emulators-start

local-firebase-emulators: local-firebase-emulators-prepare local-firebase-emulators-start
.PHONY: local-firebase-emulators

local-firebase-emulators-docker-compose: local-firebase-emulators-prepare local-firebase-emulators-docker-compose-up local-firebase-emulators-docker-compose-logs
.PHONY: local-firebase-emulators-docker-compose

local-firebase-emulators-docker-compose-up: local-firebase-emulators-docker-compose-rm
	@$(CURDIR)/local/firebase/emulators-docker-start.sh &
	@until nc -z firebase-emulators 4000 ; do \
		sleep 1 ; \
	done
	$(LOCAL_DOCKER_COMPOSE) logs firebase-emulators
	@echo
	@echo Started Firebase Emulator: 
	@echo View Emulator UI at http://127.0.0.1:4000/
	@echo Run "'make $(@:%-up=%-logs)'" to retrieve more logs
.PHONY: local-firebase-emulators-docker-compose-up

local-firebase-emulators-docker-compose-stop:
	@-$(LOCAL_DOCKER_COMPOSE) stop firebase-emulators 2>/dev/null
.PHONY: local-firebase-emulators-docker-compose-stop

local-firebase-emulators-docker-compose-rm: local-firebase-emulators-docker-compose-stop
	@$(LOCAL_DOCKER_COMPOSE) rm -f firebase-emulators
.PHONY: local-firebase-emulators-docker-compose-rm

local-firebase-emulators-docker-compose-logs:
	@$(LOCAL_DOCKER_COMPOSE) logs --follow firebase-emulators
.PHONY: local-firebase-emulators-docker-compose-logs

local-firebase-emulators-docker-compose-bash:
	@$(LOCAL_DOCKER_COMPOSE) exec -it firebase-emulators bash
.PHONY: local-firebase-emulators-docker-compose-bash

