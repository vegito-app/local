ARG apk_runner_appium_image=europe-west1-docker.pkg.dev/moov-dev-439608/docker-repository-public/vegito-local:android-appium-latest
FROM ${apk_runner_appium_image} AS runner
