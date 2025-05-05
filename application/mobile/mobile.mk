application-mobile-flutter-pub-get:
	@cd $(CURDIR)/application/mobile && flutter pub get
.PHoNY: application-mobile-flutter-pub-get

APPLICATION_MOBILE_BUILDS = apk ios

$(APPLICATION_MOBILE_BUILDS:%=application-mobile-flutter-build-%):
	@flutter build $(@:application-mobile-flutter-build-%=%) \
	  --dart-define=BACKEND_URL=$(BACKEND_URL)
.PHONY: $(APPLICATION_MOBILE_BUILDS:%=application-mobile-flutter-build-%)

application-mobile-build: $(APPLICATION_MOBILE_BUILDS:%=application-mobile-flutter-build-%)
.PHONY: application-mobile-build
