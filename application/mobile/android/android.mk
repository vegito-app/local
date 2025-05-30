application-mobile-android-native-build:
	@echo "Building Android native application"
	@cd $(CURDIR)/application/mobile/android && ./gradlew assembleRelease
.PHONY: application-mobile-android-native-build

application-mobile-android-native-build-debug:
	@echo "Building Android native application"
	@cd $(CURDIR)/application/mobile/android && ./gradlew assembleDebug
.PHONY: application-mobile-android-native-build-debug