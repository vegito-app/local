APPLICATION_DIR ?= $(CURDIR)/application
APPLICATION_MOBILE_DIR = $(APPLICATION_DIR)/mobile

-include $(APPLICATION_DIR)/frontend/frontend.mk
-include $(APPLICATION_DIR)/backend/backend.mk
-include $(APPLICATION_MOBILE_DIR)/mobile.mk
