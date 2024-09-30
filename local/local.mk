
local-install: frontend-build frontend-bundle backend-install 
.PHONY: local-install

local-run: $(BACKEND_INSTALL_BIN) $(FRONTEND_BUILD_DIR) $(UI_JAVASCRIPT_SOURCE_FILE)
	@$(BACKEND_INSTALL_BIN)
.PHONY: local-run

include $(CURDIR)/local/firebase/firebase.mk
include $(CURDIR)/local/android/android.mk
