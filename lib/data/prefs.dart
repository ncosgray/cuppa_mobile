/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    prefs.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2025 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa preferences
// - Handle shared prefs

import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/data/brew_ratio.dart';
import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/data/tea.dart';

import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/util/legacy_to_async_migration_util.dart';

// Shared prefs functionality
abstract class Prefs {
  static late SharedPreferencesWithCache sharedPrefs;
  static int nextTeaID = 0;

  // Initialize shared preferences instance
  static init() async {
    const SharedPreferencesOptions sharedPreferencesOptions =
        SharedPreferencesOptions();

    // Migrate legacy prefs
    final legacyPrefs = await SharedPreferences.getInstance();
    await migrateLegacySharedPreferencesToSharedPreferencesAsyncIfNecessary(
      legacySharedPreferencesInstance: legacyPrefs,
      sharedPreferencesAsyncOptions: sharedPreferencesOptions,
      migrationCompletedKey: prefMigratedPrefs,
    );

    // Instantiate shared prefs with caching
    sharedPrefs = await SharedPreferencesWithCache.create(
      cacheOptions: SharedPreferencesWithCacheOptions(),
      sharedPreferencesOptions: sharedPreferencesOptions,
    );
  }

  // Determine if tea settings exist in shared prefs
  static bool teaPrefsExist() {
    return sharedPrefs.containsKey(prefTeaList);
  }

  // Fetch tea settings from shared prefs or use defaults
  static List<Tea> loadTeas() {
    // Initialize teas
    List<Tea> teaList = [];
    bool migrated = false;

    // Initialize next tea ID
    nextTeaID = sharedPrefs.getInt(prefNextTeaID) ?? 0;

    // Migrate legacy Tea 1
    if (sharedPrefs.containsKey(prefTea1Name) &&
        sharedPrefs.containsKey(prefTea1BrewTime)) {
      teaList.add(
        Tea(
          name: sharedPrefs.getString(prefTea1Name) ?? unknownString,
          brewTime: sharedPrefs.getInt(prefTea1BrewTime) ?? defaultBrewTime,
          brewTemp: sharedPrefs.getInt(prefTea1BrewTemp) ?? boilDegreesC,
          brewRatio: BrewRatio(),
          colorValue: sharedPrefs.getInt(prefTea1Color) ?? defaultTeaColorValue,
          iconValue: sharedPrefs.getInt(prefTea1Icon) ?? defaultTeaIconValue,
          isFavorite: sharedPrefs.getBool(prefTea1IsFavorite) ?? true,
          isActive: sharedPrefs.getBool(prefTea1IsActive) ?? false,
        ),
      );
      sharedPrefs
        ..remove(prefTea1Name)
        ..remove(prefTea1BrewTime)
        ..remove(prefTea1BrewTemp)
        ..remove(prefTea1Color)
        ..remove(prefTea1IsFavorite)
        ..remove(prefTea1IsActive);
      migrated = true;
    }

    // Migrate legacy Tea 2
    if (sharedPrefs.containsKey(prefTea2Name) &&
        sharedPrefs.containsKey(prefTea2BrewTime)) {
      teaList.add(
        Tea(
          name: sharedPrefs.getString(prefTea2Name) ?? unknownString,
          brewTime: sharedPrefs.getInt(prefTea2BrewTime) ?? defaultBrewTime,
          brewTemp: sharedPrefs.getInt(prefTea2BrewTemp) ?? boilDegreesC,
          brewRatio: BrewRatio(),
          colorValue: sharedPrefs.getInt(prefTea2Color) ?? defaultTeaColorValue,
          iconValue: defaultTeaIconValue,
          isFavorite: sharedPrefs.getBool(prefTea2IsFavorite) ?? true,
          isActive: sharedPrefs.getBool(prefTea2IsActive) ?? false,
        ),
      );
      sharedPrefs
        ..remove(prefTea2Name)
        ..remove(prefTea2BrewTime)
        ..remove(prefTea2BrewTemp)
        ..remove(prefTea2Color)
        ..remove(prefTea2IsFavorite)
        ..remove(prefTea2IsActive);
      migrated = true;
    }

    // Migrate legacy Tea 3
    if (sharedPrefs.containsKey(prefTea3Name) &&
        sharedPrefs.containsKey(prefTea3BrewTime)) {
      teaList.add(
        Tea(
          name: sharedPrefs.getString(prefTea3Name) ?? unknownString,
          brewTime: sharedPrefs.getInt(prefTea3BrewTime) ?? defaultBrewTime,
          brewTemp: sharedPrefs.getInt(prefTea3BrewTemp) ?? boilDegreesC,
          brewRatio: BrewRatio(),
          colorValue: sharedPrefs.getInt(prefTea3Color) ?? defaultTeaColorValue,
          iconValue: defaultTeaIconValue,
          isFavorite: sharedPrefs.getBool(prefTea3IsFavorite) ?? true,
          isActive: sharedPrefs.getBool(prefTea3IsActive) ?? false,
        ),
      );
      sharedPrefs
        ..remove(prefTea3Name)
        ..remove(prefTea3BrewTime)
        ..remove(prefTea3BrewTemp)
        ..remove(prefTea3Color)
        ..remove(prefTea3IsFavorite)
        ..remove(prefTea3IsActive);
      migrated = true;
    }

    // Load tea list
    List<String>? teaListJson = sharedPrefs.getStringList(prefTeaList);
    if (teaListJson != null) {
      try {
        teaList += (teaListJson
            .map<Tea>((tea) => Tea.fromJson(jsonDecode(tea)))).toList();
      } catch (e) {
        // Something went wrong
      }
    }

    // Save to shared prefs if any legacy teas were migrated
    if (migrated) {
      saveTeas(teaList);
    }

    return teaList;
  }

  // Store teas in shared prefs
  static void saveTeas(List<Tea> teaList) {
    List<String> teaListEncoded =
        teaList.map((tea) => jsonEncode(tea.toJson())).toList();
    sharedPrefs.setStringList(prefTeaList, teaListEncoded);

    // Ensure next tea ID is valid
    int maxTeaID = maxBy(teaList, (tea) => tea.id)?.id ?? -1;
    if (nextTeaID <= maxTeaID) {
      nextTeaID = maxTeaID + 1;
    }
    sharedPrefs.setInt(prefNextTeaID, nextTeaID);
  }

  // Get settings from shared prefs
  static bool? loadShowExtra() {
    return sharedPrefs.getBool(prefShowExtra);
  }

  static bool? loadHideIncrements() {
    return sharedPrefs.getBool(prefHideIncrements);
  }

  static bool? loadSilentDefault() {
    return sharedPrefs.getBool(prefSilentDefault);
  }

  static bool? loadUseCelsius() {
    return sharedPrefs.getBool(prefUseCelsius);
  }

  static bool? loadUseBrewRatios() {
    return sharedPrefs.getBool(prefUseBrewRatios);
  }

  static CupStyle? loadCupStyle() {
    int? cupStyleValue = sharedPrefs.getInt(prefCupStyle);
    if (cupStyleValue != null && cupStyleValue < CupStyle.values.length) {
      return CupStyle.values[cupStyleValue];
    } else {
      return null;
    }
  }

  static AppTheme? loadAppTheme() {
    int? appThemeValue = sharedPrefs.getInt(prefAppTheme);
    if (appThemeValue != null && appThemeValue < AppTheme.values.length) {
      return AppTheme.values[appThemeValue];
    } else {
      return null;
    }
  }

  static String? loadAppLanguage() {
    return sharedPrefs.getString(prefAppLanguage);
  }

  static bool? loadCollectStats() {
    return sharedPrefs.getBool(prefCollectStats);
  }

  static bool? loadStackedView() {
    return sharedPrefs.getBool(prefStackedView);
  }

  // Store setting(s) in shared prefs
  static void saveSettings({
    bool? showExtra,
    bool? hideIncrements,
    bool? silentDefault,
    bool? useCelsius,
    bool? useBrewRatios,
    CupStyle? cupStyle,
    AppTheme? appTheme,
    String? appLanguage,
    bool? collectStats,
    bool? stackedView,
  }) {
    if (showExtra != null) {
      sharedPrefs.setBool(prefShowExtra, showExtra);
    }
    if (hideIncrements != null) {
      sharedPrefs.setBool(prefHideIncrements, hideIncrements);
    }
    if (silentDefault != null) {
      sharedPrefs.setBool(prefSilentDefault, silentDefault);
    }
    if (useCelsius != null) {
      sharedPrefs.setBool(prefUseCelsius, useCelsius);
    }
    if (useBrewRatios != null) {
      sharedPrefs.setBool(prefUseBrewRatios, useBrewRatios);
    }
    if (cupStyle != null) {
      sharedPrefs.setInt(prefCupStyle, cupStyle.value);
    }
    if (appTheme != null) {
      sharedPrefs.setInt(prefAppTheme, appTheme.value);
    }
    if (appLanguage != null) {
      sharedPrefs.setString(prefAppLanguage, appLanguage);
    }
    if (collectStats != null) {
      sharedPrefs.setBool(prefCollectStats, collectStats);
    }
    if (stackedView != null) {
      sharedPrefs.setBool(prefStackedView, stackedView);
    }
  }

  // Get and set tutorial status
  static bool get showTutorial {
    return !(sharedPrefs.getBool(prefSkipTutorial) ?? false);
  }

  static void setSkipTutorial() {
    sharedPrefs.setBool(prefSkipTutorial, true);
  }

  // Get and increment review prompt counter
  static int get reviewPromptCounter {
    return (sharedPrefs.getInt(prefReviewPromptCounter) ?? 0);
  }

  static void incrementReviewPromptCounter() {
    int count = reviewPromptCounter;
    sharedPrefs.setInt(prefReviewPromptCounter, ++count);
  }
}

// Cup styles
enum CupStyle {
  classic(0, AppString.prefs_cup_style_classic, cupImageClassic),
  floral(1, AppString.prefs_cup_style_floral, cupImageFloral),
  chinese(2, AppString.prefs_cup_style_chinese, cupImageChinese),
  mug(3, AppString.prefs_cup_style_mug, cupImageMug);

  const CupStyle(this.value, this._nameString, this._cupImage);

  final int value;
  final AppString _nameString;
  final String _cupImage;

  // Cup style images
  Image get image {
    return Image.asset(
      _cupImage,
      fit: BoxFit.fitWidth,
      gaplessPlayback: true,
    );
  }

  // Localized style names
  String get localizedName => _nameString.translate();
}

// App themes
enum AppTheme {
  system(0, AppString.theme_system, ThemeMode.system, false),
  light(1, AppString.theme_light, ThemeMode.light, false),
  dark(2, AppString.theme_dark, ThemeMode.dark, false),
  black(3, AppString.theme_black, ThemeMode.dark, true),
  systemBlack(4, AppString.theme_system_black, ThemeMode.system, true);

  const AppTheme(this.value, this._nameString, this.themeMode, this.blackTheme);

  final int value;
  final AppString _nameString;
  final ThemeMode themeMode;
  final bool blackTheme;

  // Localized theme names
  String get localizedName => _nameString.translate();
}

// Brewing time options
final List<int> brewTimeHourOptions =
    List.generate(teaBrewTimeMaxHours, (i) => i);
final List<int> brewTimeMinuteOptions =
    List.generate(teaBrewTimeMaxMinutes, (i) => i);
final List<int> brewTimeSecondOptions = [0, 15, 30, 45];

// Brewing temperature options
final List<int> brewTempCOptions = [
  roomTemp,
  ...[for (var i = minDegreesC; i <= boilDegreesC; i++) i],
];
final List<int> brewTempFOptions = [
  roomTemp,
  ...[for (var i = minDegreesF; i <= 210; i += 2) i],
  boilDegreesF,
];
final List<int> brewTempCIncrements = [
  roomTemp,
  ...[for (var i = minDegreesC; i <= boilDegreesC; i += 5) i],
];
final List<int> brewTempFIncrements = [
  roomTemp,
  minDegreesF,
  ...[for (var i = 110; i <= 200; i += 10) i],
  boilDegreesF,
];

// Brew ratio denominator options
final List<int> brewRatioMlOptions = [for (var i = 50; i <= 500; i += 50) i];
final List<int> brewRatioOzOptions = [
  1,
  ...[for (var i = 2; i <= 18; i += 2) i],
];
