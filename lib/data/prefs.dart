/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    prefs.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2022 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa preferences
// - Tea settings
// - Handle shared prefs

import 'package:cuppa_mobile/data/constants.dart';
import 'package:cuppa_mobile/data/globals.dart';
import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/data/presets.dart';
import 'package:cuppa_mobile/data/tea.dart';

import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:quick_actions/quick_actions.dart';

// Shared prefs functionality
abstract class Prefs {
  // Teas
  static List<Tea> teaList = [];

  // Settings
  static bool showExtra = false;
  static bool useCelsius = isLocaleMetric;
  static AppTheme appTheme = AppTheme.system;
  static String appLanguage = '';

  // Brewing temperature options
  static final List<int> brewTemps =
      ([for (var i = 60; i <= 100; i += 5) i] // C temps 60-100
          +
          [for (var i = 140; i <= 200; i += 10) i] +
          [212] // F temps 140-212
      );

  // Fetch top-level app settings such as theme and language
  static void loadTheme() {
    // App settings
    appTheme =
        AppTheme.values[sharedPrefs.getInt(prefAppTheme) ?? appTheme.value];
    appLanguage = sharedPrefs.getString(prefAppLanguage) ?? appLanguage;
  }

  // Fetch tea settings from shared prefs or use defaults
  static void loadTeas() {
    // Initialize teas
    teaList = [];

    // Default: Black tea
    teaList.add(Tea(
        name: sharedPrefs.getString(prefTea1Name) ??
            Presets.getPreset(AppString.tea_name_black).localizedName,
        brewTime: sharedPrefs.getInt(prefTea1BrewTime) ??
            Presets.getPreset(AppString.tea_name_black).brewTime,
        brewTemp: sharedPrefs.getInt(prefTea1BrewTemp) ??
            Presets.getPreset(AppString.tea_name_black).brewTemp,
        colorValue: sharedPrefs.getInt(prefTea1Color) ??
            Presets.getPreset(AppString.tea_name_black).color.value,
        isFavorite: sharedPrefs.getBool(prefTea1IsFavorite) ?? true,
        isActive: sharedPrefs.getBool(prefTea1IsActive) ?? false));

    // Default: Green tea
    String tea2Name = sharedPrefs.getString(prefTea2Name) ??
        Presets.getPreset(AppString.tea_name_green).localizedName;
    teaList.add(Tea(
        name: tea2Name,
        brewTime: sharedPrefs.getInt(prefTea2BrewTime) ??
            Presets.getPreset(AppString.tea_name_green).brewTime,
        // Select default temp if name changed from Green tea
        brewTemp: sharedPrefs.getInt(prefTea2BrewTemp) ??
            (tea2Name !=
                    Presets.getPreset(AppString.tea_name_green).localizedName
                ? Presets.getPreset(AppString.tea_name_black).brewTemp
                : Presets.getPreset(AppString.tea_name_green).brewTemp),
        colorValue: sharedPrefs.getInt(prefTea2Color) ??
            Presets.getPreset(AppString.tea_name_green).color.value,
        isFavorite: sharedPrefs.getBool(prefTea2IsFavorite) ?? true,
        isActive: sharedPrefs.getBool(prefTea2IsActive) ?? false));

    // Default: Herbal tea
    teaList.add(Tea(
        name: sharedPrefs.getString(prefTea3Name) ??
            Presets.getPreset(AppString.tea_name_herbal).localizedName,
        brewTime: sharedPrefs.getInt(prefTea3BrewTime) ??
            Presets.getPreset(AppString.tea_name_herbal).brewTime,
        brewTemp: sharedPrefs.getInt(prefTea3BrewTemp) ??
            Presets.getPreset(AppString.tea_name_herbal).brewTemp,
        colorValue: sharedPrefs.getInt(prefTea3Color) ??
            Presets.getPreset(AppString.tea_name_herbal).color.value,
        isFavorite: sharedPrefs.getBool(prefTea3IsFavorite) ?? true,
        isActive: sharedPrefs.getBool(prefTea3IsActive) ?? false));

    // More teas list
    List<String>? moreTeasJson =
        sharedPrefs.getStringList(prefMoreTeas) ?? null;
    if (moreTeasJson != null)
      teaList += (moreTeasJson.map<Tea>((tea) => Tea.fromJson(jsonDecode(tea))))
          .toList();

    // Other settings
    showExtra = sharedPrefs.getBool(prefShowExtra) ?? showExtra;
    useCelsius = sharedPrefs.getBool(prefUseCelsius) ?? useCelsius;

    // Manage quick actions
    setQuickActions();
  }

  // Store all settings in shared prefs
  static void save() {
    sharedPrefs.setString(prefTea1Name, teaList[0].name);
    sharedPrefs.setInt(prefTea1BrewTime, teaList[0].brewTime);
    sharedPrefs.setInt(prefTea1BrewTemp, teaList[0].brewTemp);
    sharedPrefs.setInt(prefTea1Color, teaList[0].color.value);
    sharedPrefs.setBool(prefTea1IsFavorite, teaList[0].isFavorite);
    sharedPrefs.setBool(prefTea1IsActive, teaList[0].isActive);

    sharedPrefs.setString(prefTea2Name, teaList[1].name);
    sharedPrefs.setInt(prefTea2BrewTime, teaList[1].brewTime);
    sharedPrefs.setInt(prefTea2BrewTemp, teaList[1].brewTemp);
    sharedPrefs.setInt(prefTea2Color, teaList[1].color.value);
    sharedPrefs.setBool(prefTea2IsFavorite, teaList[1].isFavorite);
    sharedPrefs.setBool(prefTea2IsActive, teaList[1].isActive);

    sharedPrefs.setString(prefTea3Name, teaList[2].name);
    sharedPrefs.setInt(prefTea3BrewTime, teaList[2].brewTime);
    sharedPrefs.setInt(prefTea3BrewTemp, teaList[2].brewTemp);
    sharedPrefs.setInt(prefTea3Color, teaList[2].color.value);
    sharedPrefs.setBool(prefTea3IsFavorite, teaList[2].isFavorite);
    sharedPrefs.setBool(prefTea3IsActive, teaList[2].isActive);

    List<String> moreTeasEncoded =
        (teaList.sublist(3)).map((tea) => jsonEncode(tea.toJson())).toList();
    sharedPrefs.setStringList(prefMoreTeas, moreTeasEncoded);

    sharedPrefs.setBool(prefShowExtra, showExtra);
    sharedPrefs.setBool(prefUseCelsius, useCelsius);
    sharedPrefs.setInt(prefAppTheme, appTheme.value);
    sharedPrefs.setString(prefAppLanguage, appLanguage);

    // Manage quick actions
    setQuickActions();
  }

  // Add quick action shortcuts
  static void setQuickActions() {
    quickActions.clearShortcutItems();
    quickActions
        .setShortcutItems(Prefs.favoritesList().map<ShortcutItem>((tea) {
      // Create a shortcut item for this favorite tea
      return ShortcutItem(
        type: shortcutPrefix + teaList.indexOf(tea).toString(),
        localizedTitle: tea.name,
        icon: tea.shortcutIcon,
      );
    }).toList());
  }

  // Get favorite tea list
  static List<Tea> favoritesList() {
    return teaList.where((tea) => tea.isFavorite == true).toList();
  }

  // Get active tea
  static Tea? getActiveTea() {
    return teaList.firstWhereOrNull((tea) => tea.isActive == true);
  }

  // Fetch next alarm info from shared prefs
  static int getNextAlarm() {
    return sharedPrefs.getInt(prefNextAlarm) ?? 0;
  }

  // Store next alarm info in shared prefs to persist when app is closed
  static void setNextAlarm(DateTime timerEndTime) {
    sharedPrefs.setInt(prefNextAlarm, timerEndTime.millisecondsSinceEpoch);
    Prefs.save();
  }

  // Clear shared prefs next alarm info
  static void clearNextAlarm() {
    sharedPrefs.setInt(prefNextAlarm, 0);
    teaList.where((tea) => tea.isActive == true).forEach((tea) {
      tea.isActive = false;
    });
    Prefs.save();
  }
}

// App themes
enum AppTheme {
  system(0),
  theme_light(1),
  theme_dark(2);

  final int value;

  const AppTheme(this.value);

  // App theme modes
  get themeMode {
    switch (value) {
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  // Localized theme names
  get localizedName {
    switch (value) {
      case 1:
        return AppString.theme_light.translate();
      case 2:
        return AppString.theme_dark.translate();
      default:
        return AppString.theme_system.translate();
    }
  }
}
