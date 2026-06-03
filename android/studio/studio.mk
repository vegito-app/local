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
	@echo "⚠️  Starting Android Studio with LAN-optimized settings..."
	@echo "📌 Note: This mode is best suited for low-latency,
	@$(MAKE) local-android-studio-container-up \
	  XPRA_ARGS="\
	    --quality=90 \
	    --speed=40 \
	    --encoding=h264 \
	  "
.PHONY: local-android-studio-lan

# high efficiency
local-android-studio-wan:
	@echo "⚠️  Starting Android Studio with WAN-optimized settings..."
	@echo "📌 Note: This mode prioritizes smooth streaming and low bandwidth usage over
	@$(MAKE) local-android-studio-container-up \
	  XPRA_ARGS="\
	    --quality=40 \
	    --speed=90 \
	    --encoding=webp \
	  "
.PHONY: local-android-studio-wan

# lossless
local-android-studio-ide:
	@echo "⚠️  Starting Android Studio with lossless settings..."
	@echo "📌 Note: This mode provides the best visual quality, but may require a high-bandwidth connection for smooth performance."
	@$(MAKE) local-android-studio-container-up \
	  XPRA_ARGS="\
	    --quality=100 \
	    --speed=0 \
	    --encoding=rgb \
	  "
.PHONY: local-android-studio-ide

# Smooth streaming
local-android-studio-video:
	@echo "⚠️  Starting Android Studio with video streaming settings..."
	@echo "📌 Note: This mode prioritizes smooth streaming over visual quality. It's recommended for low-bandwidth connections."
	@$(MAKE) local-android-studio-container-up \
	  XPRA_ARGS="\
	    --quality=60 \
	    --speed=80 \
	    --encoding=h264 \
	  "
.PHONY: local-android-studio-video
