GIT_SUBTREE_DIRS := \
android \
clarinet-devnet \
firebase-emulators \
example-application \
gcloud \
nestor

git-subtree-pull: $(GIT_SUBTREE_DIRS:%=git-subtree-%-pull)
.PHONY: git-subtree-pull

git-subtree-push: $(GIT_SUBTREE_DIRS:%=git-subtree-%-push)
.PHONY: git-subtree-push

git-subtree-status:
	@echo "🔍 Checking the status of subtrees..."
	@git status
.PHONY: git-subtree-status

VEGITO_APP_GIT_SUBTREE_REMOTE_BRANCH := subtree/$(VEGITO_PROJECT_NAME)-$(VEGITO_PROJECT_USER)-$(VERSION)

VEGITO_APP_GIT_SUBTREE_REMOTES := \
android \
clarinet-devnet \
firebase-emulators \
example-application \
gcloud \
nestor

$(VEGITO_APP_GIT_SUBTREE_REMOTES:%=git-subtree-%-remote-branch-rm):
	@echo "🗑️ Removing the distribution branch..."
	-git push git@github.com:vegito-app/$(@:git-subtree-%-remote-branch-rm=%).git :$(VEGITO_APP_GIT_SUBTREE_REMOTE_BRANCH)
.PHONY: $(VEGITO_APP_GIT_SUBTREE_REMOTES:%=git-subtree-%-remote-branch-rm)

git-subtree-remote-branch-rm: $(VEGITO_APP_GIT_SUBTREE_REMOTES:%=git-subtree-%-remote-branch-rm)
.PHONY: git-subtree-remote-branch-rm

# ------------------------------------------
# Subtree ./google-cloud
# ------------------------------------------
git-subtree-gcloud-pull:
	@echo "⬇︎ Pulling the gcloud subtree..."
	@git subtree pull --prefix gcloud \
	  git@github.com:vegito-app/gcloud.git main --squash
	@echo "Gcloud subtree pulled successfully."
.PHONY: git-subtree-gcloud-pull

git-subtree-gcloud-push:
	@echo "⬆︎ Pushing changes from the gcloud subtree..."
	@git subtree push --prefix gcloud \
	  git@github.com:vegito-app/gcloud.git $(VEGITO_APP_GIT_SUBTREE_REMOTE_BRANCH)
	@echo "Gcloud subtree pushed successfully."
.PHONY: git-subtree-gcloud-push

VEGITO_GCLOUD_DIR := $(LOCAL_DIR)/gcloud
-include $(VEGITO_GCLOUD_DIR)/gcloud.mk
# ------------------------------------------
# ------------------------------------------
# Subtree ./nestor
# ------------------------------------------
git-subtree-nestor-pull:
	@echo "⬇︎ Pulling the nestor subtree..."
	@git subtree pull --prefix nestor \
	  git@github.com:vegito-app/ai-nestor.git main --squash
	@echo "AI Nestor subtree pulled successfully."
.PHONY: git-subtree-nestor-pull

git-subtree-nestor-push:
	@echo "⬆︎ Pushing changes from the nestor subtree..."
	@git subtree push --prefix nestor \
	  git@github.com:vegito-app/ai-nestor.git $(VEGITO_APP_GIT_SUBTREE_REMOTE_BRANCH)
	@echo "AI Nestor subtree pushed successfully."
.PHONY: git-subtree-nestor-push

LOCAL_ANDROID_DIR := $(LOCAL_DIR)/android
-include $(LOCAL_ANDROID_DIR)/android.mk
# ------------------------------------------
# ------------------------------------------
# Subtree ./android
# ------------------------------------------
git-subtree-android-pull:
	@echo "⬇︎ Pulling the android subtree..."
	@git subtree pull --prefix android \
	  git@github.com:vegito-app/android.git main --squash
	@echo "AI android subtree pulled successfully."
.PHONY: git-subtree-android-pull

git-subtree-android-push:
	@echo "⬆︎ Pushing changes from the android subtree..."
	@git subtree push --prefix android \
	  git@github.com:vegito-app/android.git $(VEGITO_APP_GIT_SUBTREE_REMOTE_BRANCH)
	@echo "Android subtree pushed successfully."
.PHONY: git-subtree-android-push

LOCAL_FIREBASE_EMULATORS_DIR := $(LOCAL_DIR)/firebase-emulators
-include $(LOCAL_FIREBASE_EMULATORS_DIR)/firebase-emulators.mk
# ------------------------------------------
# ------------------------------------------
# Subtree ./firebase-emulators
# ------------------------------------------
git-subtree-firebase-emulators-pull:
	@echo "⬇︎ Pulling the firebase-emulators subtree..."
	@git subtree pull --prefix firebase-emulators \
	  git@github.com:vegito-app/firebase-emulators.git main --squash
	@echo "AI firebase-emulators subtree pulled successfully."
.PHONY: git-subtree-firebase-emulators-pull

git-subtree-firebase-emulators-push:
	@echo "⬆︎ Pushing changes from the firebase-emulators subtree..."
	@git subtree push --prefix firebase-emulators \
	  git@github.com:vegito-app/firebase-emulators.git $(VEGITO_APP_GIT_SUBTREE_REMOTE_BRANCH)
	@echo "Android subtree pushed successfully."
.PHONY: git-subtree-firebase-emulators-push

LOCAL_CLARINET_DEVNET_DIR := $(LOCAL_DIR)/clarinet-devnet
-include $(LOCAL_CLARINET_DEVNET_DIR)/clarinet-devnet.mk
# ------------------------------------------
# ------------------------------------------
# Subtree ./clarinet-devnet
# ------------------------------------------
git-subtree-clarinet-devnet-pull:
	@echo "⬇︎ Pulling the clarinet-devnet subtree..."
	@git subtree pull --prefix clarinet-devnet \
	  git@github.com:vegito-app/clarinet-devnet.git main --squash
	@echo "AI clarinet-devnet subtree pulled successfully."
.PHONY: git-subtree-clarinet-devnet-pull

git-subtree-clarinet-devnet-push:
	@echo "⬆︎ Pushing changes from the clarinet-devnet subtree..."
	@git subtree push --prefix clarinet-devnet \
	  git@github.com:vegito-app/clarinet-devnet.git $(VEGITO_APP_GIT_SUBTREE_REMOTE_BRANCH)
	@echo "Android subtree pushed successfully."
.PHONY: git-subtree-clarinet-devnet-push

# ------------------------------------------
# ------------------------------------------
# Subtree ./example-application
# ------------------------------------------
git-subtree-example-application-pull:
	@echo "⬇︎ Pulling the example-application subtree..."
	@git subtree pull --prefix example-application \
	  git@github.com:vegito-app/example-application.git main --squash
	@echo "Example Application subtree pulled successfully."
.PHONY: git-subtree-example-application-pull

git-subtree-example-application-push:
	@echo "⬆︎ Pushing changes from the example-application subtree..."
	@git subtree push --prefix example-application \
	  git@github.com:vegito-app/example-application.git $(VEGITO_APP_GIT_SUBTREE_REMOTE_BRANCH)
	@echo "Example application subtree pushed successfully."
.PHONY: git-subtree-example-application-push

export VEGITO_EXAMPLE_APPLICATION_BUILDER_IMAGES_BASE ?= $(LOCAL_DOCKER_PUBLIC_IMAGES_BASE_NAME):example-application-builder
export VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGES_BASE ?= $(LOCAL_DOCKER_PUBLIC_IMAGES_BASE_NAME):example-application-backend
export VEGITO_EXAMPLE_APPLICATION_MOBILE_IMAGES_BASE ?= $(LOCAL_DOCKER_PUBLIC_IMAGES_BASE_NAME):example-application-mobile

-include $(VEGITO_EXAMPLE_APPLICATION_DIR)/example-application.mk
# ------------------------------------------
