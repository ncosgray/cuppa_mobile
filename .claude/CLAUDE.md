# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## About

Cuppa Mobile is a Flutter-based tea timer app for Android (7+) and iOS (16+). Users tap a tea button to start a countdown timer; the app supports up to 2 simultaneous timers, local notifications, and full customization of teas.

- Package ID: `com.nathanatos.Cuppa`
- Version format: `major.minor.patch+buildNumber` in [pubspec.yaml](pubspec.yaml)
- F-Droid build uses `lib/main_fdroid.dart` (no in-app review, no patrol)

## Commands

```bash
# Run the app
flutter run

# Build
flutter build apk                         # Android (standard)
flutter build ipa                         # iOS
./build_fdroid.sh                         # F-Droid APK (removes non-FOSS deps)

# Lint / analyze
flutter analyze

# Integration tests (requires device/emulator)
flutter test integration_test/            # screenshot collection only (not true integration tests)
patrol test patrol_test/app_test.dart     # full end-to-end integration tests with Patrol

# Screenshots (requires AVD/simulator setup)
./run_screenhots.sh
```

## Architecture

### State Management
The app uses the `provider` package with a single `AppProvider` (`lib/data/provider.dart`) that is a `ChangeNotifier`. It holds the tea list, active timer state, and all user settings. Widgets read from the provider using `Selector` (preferred over `Consumer`) to minimize rebuilds.

### Key Data Flow
1. `main()` → `initializeApp()` → `Prefs.init()` (shared preferences), then `runApp(CuppaApp())`
2. `CuppaApp` creates a `ChangeNotifierProvider<AppProvider>` wrapping the widget tree
3. `AppProvider` loads teas and settings from `Prefs` (shared preferences) on construction
4. Tea timer state is stored on `Tea` objects inside `AppProvider._teaList`; active timers track `timerEndTime` (epoch ms) which survives app restarts

### Directory Layout
- `lib/main.dart` — standard entry point (includes in-app review prompt)
- `lib/main_fdroid.dart` — F-Droid entry point (no review prompt)
- `lib/cuppa_app.dart` — app initialization and `MaterialApp` builder; sets up theme, localization, dynamic color
- `lib/data/` — data models and persistence
  - `tea.dart` — `Tea` class (serialized as JSON in shared prefs), `TeaColor` and `TeaIcon` enums
  - `provider.dart` — `AppProvider` (all app state); `SortBy` enum
  - `prefs.dart` — `Prefs` abstract class (shared preferences I/O); `CupStyle`, `ButtonSize`, `AppTheme`, `ExtraInfo` enums
  - `stats.dart` — timer usage stats stored in SQLite via `sqflite`
  - `presets.dart` — built-in tea presets
  - `brew_ratio.dart` — brew ratio model
  - `localization.dart` — custom localization system using JSON files in `langs/`; `AppString` enum for all UI strings
  - `export.dart` — import/export functionality
- `lib/common/` — shared utilities and constants
  - `constants.dart` — all numeric limits, defaults, preference keys, image paths
  - `globals.dart` — app-wide globals (navigator key, region settings, package info)
  - `platform_adaptive.dart` — platform-adaptive widgets (Cupertino on iOS, Material on Android)
- `lib/pages/` — full-screen pages: `timer_page.dart`, `prefs_page.dart`, `stats_page.dart`, `about_page.dart`
- `lib/widgets/` — reusable widgets: tea buttons, dialogs for editing tea settings, teacup animation, countdown timer

### Localization
Translations live in `langs/*.json` files (loaded as Flutter assets). The `AppString` enum in `lib/data/localization.dart` defines all string keys. Call `AppString.some_key.translate()` anywhere — no `BuildContext` required. The default locale is `en_GB`. Translations are managed via [Weblate](https://hosted.weblate.org/engage/cuppa/).

### Persistence
- **Tea list and settings**: `shared_preferences` (JSON-encoded list stored under `prefTeaList`)
- **Usage statistics**: SQLite database via `sqflite` (`lib/data/stats.dart`)
- Legacy prefs are migrated automatically on first launch

### Lint Rules (enforced)
Key rules from [analysis_options.yaml](analysis_options.yaml):
- `always_use_package_imports` — always use `package:cuppa_mobile/...` imports, never relative
- `prefer_single_quotes`
- `require_trailing_commas`
- `sort_constructors_first`
- `eol_at_end_of_file`

### Dart Code Conventions
- Imports for `package:cuppa_mobile` should be listed before other imports
- Prefer dot shorthands