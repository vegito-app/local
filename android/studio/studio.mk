LOCAL_ANDROID_STUDIO_DIR ?= $(LOCAL_ANDROID_DIR)/studio

local-android-studio-container-up: local-android-studio-container-rm
	VERSION=latest $(LOCAL_ANDROID_STUDIO_DIR)/docker-compose-up.sh &
	@$(LOCAL_DOCKER_COMPOSE) logs android-studio
	@echo
	@echo Started Androïd studio display: 
	@echo Run "'make $(@:%-up=%-logs)'" to retrieve more logs
.PHONY: local-android-studio-container-up

