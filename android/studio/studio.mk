LOCAL_ANDROID_STUDIO_DIR ?= $(LOCAL_ANDROID_DIR)/studio

local-android-studio-container-up: local-android-studio-container-rm
	@$(LOCAL_ANDROID_STUDIO_DIR)/docker-compose-up.sh &
	@$(LOCAL_DOCKER_COMPOSE) logs android-studio
	@echo
	@echo Started Androïd studio display: 
	@echo Run "'make $(@:%-up=%-logs)'" to retrieve more logs
.PHONY: local-android-studio-container-up

# high quality
local-android-studio-lan:
	@XPRA_QUALITY=90 \
	XPRA_SPEED=40 \
	XPRA_ENCODING=h264 \
	$(MAKE) local-android-studio-container-up
.PHONY: local-android-studio-lan

# high efficiency
local-android-studio-wan:
	@XPRA_QUALITY=40 \
	XPRA_SPEED=90 \
	XPRA_ENCODING=webp \
	$(MAKE) local-android-studio-container-up
.PHONY: local-android-studio-wan

# lossless
local-android-studio-ide:
	@XPRA_QUALITY=100 \
	XPRA_SPEED=0 \
	XPRA_ENCODING=rgb \
	$(MAKE) local-android-studio-container-up
.PHONY: local-android-studio-ide

# Smooth streaming
local-android-studio-video:
	@XPRA_MIN_QUALITY=60 \
	XPRA_SPEED=80 \
	XPRA_ENCODING=h264 \
	$(MAKE) local-android-studio-container-up
.PHONY: local-android-studio-video
