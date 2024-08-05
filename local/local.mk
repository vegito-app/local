local-builder-image-build:
	docker compose build dev
.PHONY: local-builder-image-build

local-builder-image-push:
	docker compose push dev
.PHONY: local-builder-image-push

local-application-image-build: $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS) $(GOOGLE_MAPS_API_KEY_FILE) frontend-node-modules
	@docker build \
	  --build-arg builder_image=$(BUILDER_IMAGE) \
	  --build-arg REACT_APP_UTRADE_FIREBASE_API_KEY=$$UTRADE_FIREBASE_API_KEY \
	  --build-arg REACT_APP_UTRADE_FIREBASE_AUTH_DOMAIN=$$UTRADE_FIREBASE_AUTH_DOMAIN \
	  --build-arg REACT_APP_UTRADE_FIREBASE_DATABASE_URL=$$UTRADE_FIREBASE_DATABASE_URL \
	  --build-arg REACT_APP_UTRADE_FIREBASE_PROJECT_ID=$$UTRADE_FIREBASE_PROJECT_ID \
	  --build-arg REACT_APP_UTRADE_FIREBASE_STORAGE_BUCKET=$$UTRADE_FIREBASE_STORAGE_BUCKET \
	  --build-arg REACT_APP_UTRADE_FIREBASE_MESSAGING_SENDER_ID=$$UTRADE_FIREBASE_MESSAGING_SENDER_ID \
	  --build-arg REACT_APP_UTRADE_FIREBASE_APP_ID=$$UTRADE_FIREBASE_APP_ID \
	  --secret id=google_maps_api_key,src=$(GOOGLE_MAPS_API_KEY_FILE) \
	  -t $(BACKEND_IMAGE) .
.PHONY: local-application-image-build

local-application-image-push: $(GOOGLE_CLOUD_APPLICATION_CREDENTIALS) $(GOOGLE_MAPS_API_KEY_FILE)
	@docker push $(BACKEND_IMAGE)
.PHONY: local-application-image-push

local-application-image-run:
	@docker run --rm \
	  -p 8080:8080 \
	  -v $(GOOGLE_APPLICATION_CREDENTIALS):$(GOOGLE_APPLICATION_CREDENTIALS) \
	  -e GOOGLE_APPLICATION_CREDENTIALS \
	  -e UTRADE_FIREBASE_DATABASE_URL \
	  -e UTRADE_FIREBASE_PROJECT_ID \
	  -e UTRADE_FIREBASE_STORAGE_BUCKET  \
	  $(BACKEND_IMAGE)
.PHONY: local-application-image-run

local-backend-build-all-run: frontend-build frontend-bundle backend-install 
	@backend
.PHONY: local-backend-build-all-run

local-backend-run: $(BACKEND_INSTALL_BIN) 
	@backend
.PHONY: local-backend-run