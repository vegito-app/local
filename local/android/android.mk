
ANDROID_STUDIO_IMAGE =  $(IMAGES_BASE):$(VERSION)-vnc-android-studio

local-docker-compose-vnc-android-studio-build-no-pull:
	@docker build --pull=false \
	  -f $(CURDIR)/local/android/vnc-studio.Dockerfile \
	  --build-arg builder_image=$(BUILDER_IMAGE) \
	  -t $(ANDROID_STUDIO_IMAGE) \
	  .
.PHONY: local-docker-compose-vnc-android-studio-build-no-pull

local-docker-compose-vnc-android-studio-up: local-docker-compose-vnc-android-studio-build-no-pull local-docker-compose-vnc-android-studio-rm
	@$(CURDIR)/local/android/android-docker-start.sh &
	@docker compose logs vnc-android-studio
	@until nc -z vnc-android-studio 9100 ; do \
		echo waiting vnc-android-studio container ; \
		sleep 1 ; \
	done
	@echo
	@echo Started Firebase Emulator: 
	@echo View Emulator UI at http://127.0.0.1:4000/
	@echo Run "'make $(@:%-up=%-logs)'" to retrieve more logs
.PHONY: local-docker-compose-vnc-android-studio

local-docker-compose-vnc-android-studio-stop:
	@-docker compose stop vnc-android-studio 2>/dev/null
.PHONY: local-docker-compose-vnc-android-studio-stop

local-docker-compose-vnc-android-studio-rm: local-docker-compose-vnc-android-studio-stop
	@docker compose rm -f vnc-android-studio
.PHONY: local-docker-compose-vnc-android-studio-rm

local-docker-compose-vnc-android-studio-logs:
	@docker compose logs --follow vnc-android-studio
.PHONY: local-docker-compose-vnc-android-studio-logs

local-docker-compose-vnc-android-studio-sh:
	@docker compose exec -it vnc-android-studio bash
.PHONY: local-docker-compose-vnc-android-studio-sh

local-docker-compose-vnc-android-studio-bash:
	@docker compose exec -it vnc-android-studio bash
.PHONY: local-docker-compose-vnc-android-studio-bash
