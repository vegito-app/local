gcloud-firebase-adminsdk-service-account-roles-list:
	@echo "🔎 Listing IAM roles for Firebase Admin SDK service account $(FIREBASE_ADMINSDK_SERVICEACCOUNT)..."
	@$(GCLOUD) projects get-iam-policy $(GOOGLE_CLOUD_PROJECT_ID) \
	  --flatten="bindings[].members" \
	  --format='table(bindings.role)' \
	  --filter="bindings.members:$(FIREBASE_ADMINSDK_SERVICEACCOUNT)"
.PHONY: gcloud-firebase-adminsdk-service-account-roles-list
