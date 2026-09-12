#!/bin/bash

# Abort on any failed command, unset variable, or failed pipe stage
set -Eeuo pipefail

# Change to the script's directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Always restore the pubspec files, whether the build succeeded or failed
cleanup() {
  local status=$?
  git restore pubspec.lock pubspec.yaml \
    || echo "warning: could not restore pubspec files" >&2
  exit $status
}
trap cleanup EXIT
trap 'echo "build_fdroid.sh: failed at line $LINENO" >&2' ERR

# Build F-Droid compatible APK by removing non-FOSS dependencies
flutter pub remove --offline integration_test
# The easy way:
#flutter pub remove --offline patrol
#flutter pub remove --offline in_app_review
# The F-Droid way:
sed -i '' -E -e '/  patrol/d' -e '/in_app_review/d' pubspec.yaml
sed -i '' -E -e '/  patrol/,/version/d' -e '/in_app_review|http_multi_server|dispose_scope|shelf/,/version/d' pubspec.lock
flutter pub get --enforce-lockfile

flutter build apk --target lib/main_fdroid.dart
