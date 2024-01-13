/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    prefs.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2024 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa preferences
// - Handle shared prefs

import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/common/globals.dart';
import 'package:cuppa_mobile/common/helpers.dart';
import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/data/tea.dart';

import 'dart:convert';
import 'package:flutter/material.dart';

// Shared prefs functionality
abstract class Prefs {
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
          brewTime: sharedPrefs.getInt(prefTea1BrewTime) ?? 0,
          brewTemp: sharedPrefs.getInt(prefTea1BrewTemp) ?? 100,
          colorValue: sharedPrefs.getInt(prefTea1Color) ?? 0,
          iconValue: sharedPrefs.getInt(prefTea1Icon) ?? 0,
          isFavorite: sharedPrefs.getBool(prefTea1IsFavorite) ?? true,
          isActive: sharedPrefs.getBool(prefTea1IsActive) ?? false,
        ),
      );
      sharedPrefs.remove(prefTea1Name);
      sharedPrefs.remove(prefTea1BrewTime);
      sharedPrefs.remove(prefTea1BrewTemp);
      sharedPrefs.remove(prefTea1Color);
      sharedPrefs.remove(prefTea1IsFavorite);
      sharedPrefs.remove(prefTea1IsActive);
      migrated = true;
    }

    // Migrate legacy Tea 2
    if (sharedPrefs.containsKey(prefTea2Name) &&
        sharedPrefs.containsKey(prefTea2BrewTime)) {
      teaList.add(
        Tea(
          name: sharedPrefs.getString(prefTea2Name) ?? unknownString,
          brewTime: sharedPrefs.getInt(prefTea2BrewTime) ?? 0,
          brewTemp: sharedPrefs.getInt(prefTea2BrewTemp) ?? 100,
          colorValue: sharedPrefs.getInt(prefTea2Color) ?? 0,
          iconValue: 0,
          isFavorite: sharedPrefs.getBool(prefTea2IsFavorite) ?? true,
          isActive: sharedPrefs.getBool(prefTea2IsActive) ?? false,
        ),
      );
      sharedPrefs.remove(prefTea2Name);
      sharedPrefs.remove(prefTea2BrewTime);
      sharedPrefs.remove(prefTea2BrewTemp);
      sharedPrefs.remove(prefTea2Color);
      sharedPrefs.remove(prefTea2IsFavorite);
      sharedPrefs.remove(prefTea2IsActive);
      migrated = true;
    }

    // Migrate legacy Tea 3
    if (sharedPrefs.containsKey(prefTea3Name) &&
        sharedPrefs.containsKey(prefTea3BrewTime)) {
      teaList.add(
        Tea(
          name: sharedPrefs.getString(prefTea3Name) ?? unknownString,
          brewTime: sharedPrefs.getInt(prefTea3BrewTime) ?? 0,
          brewTemp: sharedPrefs.getInt(prefTea3BrewTemp) ?? 100,
          colorValue: sharedPrefs.getInt(prefTea3Color) ?? 0,
          iconValue: 0,
          isFavorite: sharedPrefs.getBool(prefTea3IsFavorite) ?? true,
          isActive: sharedPrefs.getBool(prefTea3IsActive) ?? false,
        ),
      );
      sharedPrefs.remove(prefTea3Name);
      sharedPrefs.remove(prefTea3BrewTime);
      sharedPrefs.remove(prefTea3BrewTemp);
      sharedPrefs.remove(prefTea3Color);
      sharedPrefs.remove(prefTea3IsFavorite);
      sharedPrefs.remove(prefTea3IsActive);
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
    sharedPrefs.setInt(prefNextTeaID, nextTeaID);
  }

  // Get settings from shared prefs
  static bool? loadShowExtra() {
    return sharedPrefs.getBool(prefShowExtra);
  }

  static bool? loadHideIncrements() {
    return sharedPrefs.getBool(prefHideIncrements);
  }

  static bool? loadUseCelsius() {
    return sharedPrefs.getBool(prefUseCelsius);
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

  // Store setting(s) in shared prefs
  static void saveSettings({
    bool? showExtra,
    bool? hideIncrements,
    bool? useCelsius,
    AppTheme? appTheme,
    String? appLanguage,
    bool? collectStats,
  }) {
    if (showExtra != null) {
      sharedPrefs.setBool(prefShowExtra, showExtra);
    }
    if (hideIncrements != null) {
      sharedPrefs.setBool(prefHideIncrements, hideIncrements);
    }
    if (useCelsius != null) {
      sharedPrefs.setBool(prefUseCelsius, useCelsius);
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
  }

  // Get and set tutorial status
  static bool get showTutorial {
    return !(sharedPrefs.getBool(prefSkipTutorial) ?? false);
  }

  static void setSkipTutorial() {
    sharedPrefs.setBool(prefSkipTutorial, true);
  }
}

// App themes
enum AppTheme {
  system(0),
  light(1),
  dark(2),
  black(3),
  systemBlack(4);

  final int value;

  const AppTheme(this.value);

  // App theme modes
  get themeMode {
    switch (value) {
      case 1:
        return ThemeMode.light;
      case 2:
      case 3:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  // Dark theme darkness
  get blackTheme {
    switch (value) {
      case 3:
      case 4:
        return true;
      default:
        return false;
    }
  }

  // Localized theme names
  get localizedName {
    switch (value) {
      case 1:
        return AppString.theme_light.translate();
      case 2:
        return AppString.theme_dark.translate();
      case 3:
        return AppString.theme_black.translate();
      case 4:
        return AppString.theme_system_black.translate();
      default:
        return AppString.theme_system.translate();
    }
  }
}

// Brewing time options
final List<int> brewTimeHourOptions =
    List.generate(teaBrewTimeMaxHours, (i) => i);
final List<int> brewTimeMinuteOptions =
    List.generate(teaBrewTimeMaxMinutes, (i) => i);
final List<int> brewTimeSecondOptions = [0, 15, 30, 45];

// Brewing temperature options
final List<int> brewTempCOptions =
    ([roomTempDegreesC] + [for (var i = 50; i <= boilDegreesC; i += 5) i]);
final List<int> brewTempFOptions = ([roomTempDegreesF] +
    [for (var i = 110; i <= 200; i += 10) i] +
    [boilDegreesF]);

// App language options
final List<String> languageOptions =
    [followSystemLanguage] + supportedLanguageCodes;
