#!/bin/bash
set -euo pipefail
flutter pub get
if [ ! -f build/app/outputs/flutter-apk/app-${INFRA_ENV}-release.apk ]; then
  flutter build apk --flavor "${INFRA_ENV}" --release
fi