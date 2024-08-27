
LOCAL_FIREBASE_DIR = $(CURDIR)/local/firebase
LOCAL_FIREBASE = cd $(LOCAL_FIREBASE_DIR) && firebase
# only specific emulators. This is a comma separated list of
# emulator names. Valid options are:
# ["auth","functions","firestore","database","hosting","pubsub","storage","eventarc","dataconnect"]
LOCAL_FIREBASE_EMULATORS_SERVICES = auth,functions,firestore,database

local-firebase-emulators-prepare: local-firebase-emulators-install local-firebase-emulators-init
.PHONY: local-firebase-emulators

local-firebase-emulators-install: cloud-infra-auth-npm-install
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
	@unset GOOGLE_APPLICATION_CREDENTIALS && \
	  $(LOCAL_FIREBASE) emulators:start \
	    --import=$(LOCAL_FIREBASE_EMULATORS_DATA) \
	    --export-on-exit $(LOCAL_FIREBASE_EMULATORS_DATA) \
	    --log-verbosity DEBUG \
	    --only $(LOCAL_FIREBASE_EMULATORS_SERVICES)
.PHONY: local-firebase-emulators-start

local-firebase-emulators: local-firebase-emulators-prepare local-firebase-emulators-start
.PHONY: local-firebase-emulators

local-docker-compose-firebase-emulators: local-firebase-emulators-prepare local-docker-compose-firebase-emulators-up local-docker-compose-firebase-emulators-logs
.PHONY: local-docker-compose-firebase-emulators

local-docker-compose-firebase-emulators-up: local-docker-compose-firebase-emulators-build-no-pull local-docker-compose-firebase-emulators-rm
	@$(CURDIR)/local/firebase/docker-compose-up.sh &
	@until nc -z firebase-emulators 4000 ; do \
		sleep 1 ; \
	done
	@docker compose logs firebase-emulators
	@echo
	@echo Started Firebase Emulator: 
	@echo View Emulator UI at http://127.0.0.1:4000/
	@echo Run "'make $(@:%-up=%-logs)'" to retrieve more logs
.PHONY: local-docker-compose-firebase-emulators

local-docker-compose-firebase-emulators-stop:
	@-docker compose stop firebase-emulators 2>/dev/null
.PHONY: local-docker-compose-firebase-emulators-stop

local-docker-compose-firebase-emulators-rm: local-docker-compose-firebase-emulators-stop
	@docker compose rm -f firebase-emulators
.PHONY: local-docker-compose-firebase-emulators-rm

local-docker-compose-firebase-emulators-logs:
	@docker compose logs --follow firebase-emulators
.PHONY: local-docker-compose-firebase-emulators-logs

local-docker-compose-firebase-emulators-bash:
	@docker compose exec -it firebase-emulators bash
.PHONY: local-docker-compose-firebase-emulators-bash

FIREBASE_EMULATORS_IMAGE =  $(IMAGES_BASE):$(VERSION)-firebase-emulators

local-docker-compose-firebase-emulators-build-no-pull:
	@docker build --pull=false \
	  -f $(CURDIR)/firebase-emulators.Dockerfile \
	  --build-arg builder_image=$(BUILDER_IMAGE) \
	  -t $(FIREBASE_EMULATORS_IMAGE) \
	  .
.PHONY: local-docker-compose-firebase-emulators-build-no-pull