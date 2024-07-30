#!/bin/sh
flutter pub remove --offline patrol
flutter pub remove --offline in_app_review
flutter build apk --target lib/main_fdroid.dart
flutter pub add --offline dev:patrol
flutter pub add --offline in_app_review
