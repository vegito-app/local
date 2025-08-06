LOCAL_APPLICATION_DIR ?= $(CURDIR)/application
APPLICATION_MOBILE_DIR = $(LOCAL_APPLICATION_DIR)/mobile

-include $(LOCAL_APPLICATION_DIR)/frontend/frontend.mk
-include $(LOCAL_APPLICATION_DIR)/backend/backend.mk
-include $(APPLICATION_MOBILE_DIR)/mobile.mk
