#!/bin/bash

# Change to the script's directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Build F-Droid compatible APK by removing non-FOSS dependencies
flutter pub remove --offline patrol
flutter pub remove --offline integration_test
flutter pub remove --offline in_app_review
flutter build apk --target lib/main_fdroid.dart

# Clean up
git restore pubspec.lock pubspec.yaml
