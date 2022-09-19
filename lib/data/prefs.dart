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
// - Handle shared prefs

import 'package:cuppa_mobile/data/constants.dart';
import 'package:cuppa_mobile/data/globals.dart';
import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/data/tea.dart';

import 'dart:convert';
import 'package:flutter/material.dart';

// Shared prefs functionality
abstract class Prefs {
  // Determine if tea settings exist in shared prefs
  static bool teaPrefsExist() {
    return (sharedPrefs.containsKey(prefTea1Name) &&
        sharedPrefs.containsKey(prefTea1BrewTime));
  }

  // Fetch tea settings from shared prefs or use defaults
  static List<Tea> loadTeas() {
    // Initialize teas
    List<Tea> teaList = [];

    // Verify settings exist before continuing
    if (!teaPrefsExist()) return teaList;

    // Tea 1
    teaList.add(Tea(
        name: sharedPrefs.getString(prefTea1Name) ?? unknownString,
        brewTime: sharedPrefs.getInt(prefTea1BrewTime) ?? 0,
        brewTemp: sharedPrefs.getInt(prefTea1BrewTemp) ?? 100,
        colorValue: sharedPrefs.getInt(prefTea1Color) ?? 0,
        isFavorite: sharedPrefs.getBool(prefTea1IsFavorite) ?? true,
        isActive: sharedPrefs.getBool(prefTea1IsActive) ?? false));

    // Migrate legacy Tea 2
    if (sharedPrefs.containsKey(prefTea2Name) &&
        sharedPrefs.containsKey(prefTea2BrewTime)) {
      teaList.add(Tea(
          name: sharedPrefs.getString(prefTea2Name) ?? unknownString,
          brewTime: sharedPrefs.getInt(prefTea2BrewTime) ?? 0,
          brewTemp: sharedPrefs.getInt(prefTea2BrewTemp) ?? 100,
          colorValue: sharedPrefs.getInt(prefTea2Color) ?? 0,
          isFavorite: sharedPrefs.getBool(prefTea2IsFavorite) ?? true,
          isActive: sharedPrefs.getBool(prefTea2IsActive) ?? false));
      sharedPrefs.remove(prefTea2Name);
      sharedPrefs.remove(prefTea2BrewTime);
      sharedPrefs.remove(prefTea2BrewTemp);
      sharedPrefs.remove(prefTea2Color);
      sharedPrefs.remove(prefTea2IsFavorite);
      sharedPrefs.remove(prefTea2IsActive);
    }

    // Migrate legacy Tea 3
    if (sharedPrefs.containsKey(prefTea3Name) &&
        sharedPrefs.containsKey(prefTea3BrewTime)) {
      teaList.add(Tea(
          name: sharedPrefs.getString(prefTea3Name) ?? unknownString,
          brewTime: sharedPrefs.getInt(prefTea3BrewTime) ?? 0,
          brewTemp: sharedPrefs.getInt(prefTea3BrewTemp) ?? 100,
          colorValue: sharedPrefs.getInt(prefTea3Color) ?? 0,
          isFavorite: sharedPrefs.getBool(prefTea3IsFavorite) ?? true,
          isActive: sharedPrefs.getBool(prefTea3IsActive) ?? false));
      sharedPrefs.remove(prefTea3Name);
      sharedPrefs.remove(prefTea3BrewTime);
      sharedPrefs.remove(prefTea3BrewTemp);
      sharedPrefs.remove(prefTea3Color);
      sharedPrefs.remove(prefTea3IsFavorite);
      sharedPrefs.remove(prefTea3IsActive);
    }

    // More teas list
    List<String>? moreTeasJson =
        sharedPrefs.getStringList(prefMoreTeas) ?? null;
    if (moreTeasJson != null)
      teaList += (moreTeasJson.map<Tea>((tea) => Tea.fromJson(jsonDecode(tea))))
          .toList();

    return teaList;
  }

  // Store teas in shared prefs
  static void saveTeas(List<Tea> teaList) {
    // Tea 1
    sharedPrefs.setString(prefTea1Name, teaList[0].name);
    sharedPrefs.setInt(prefTea1BrewTime, teaList[0].brewTime);
    sharedPrefs.setInt(prefTea1BrewTemp, teaList[0].brewTemp);
    sharedPrefs.setInt(prefTea1Color, teaList[0].color.value);
    sharedPrefs.setBool(prefTea1IsFavorite, teaList[0].isFavorite);
    sharedPrefs.setBool(prefTea1IsActive, teaList[0].isActive);

    // More teas list
    List<String> moreTeasEncoded = (teaList.sublist(teasMinCount))
        .map((tea) => jsonEncode(tea.toJson()))
        .toList();
    sharedPrefs.setStringList(prefMoreTeas, moreTeasEncoded);
  }

  // Get settings from shared prefs
  static bool? loadShowExtra() {
    return sharedPrefs.getBool(prefShowExtra);
  }

  static bool? loadUseCelsius() {
    return sharedPrefs.getBool(prefUseCelsius);
  }

  static AppTheme? loadAppTheme() {
    int? appThemeValue = sharedPrefs.getInt(prefAppTheme);
    if (appThemeValue != null && appThemeValue < AppTheme.values.length)
      return AppTheme.values[appThemeValue];
    else
      return null;
  }

  static String? loadAppLanguage() {
    return sharedPrefs.getString(prefAppLanguage);
  }

  // Store setting(s) in shared prefs
  static void saveSettings(
      {bool? showExtra,
      bool? useCelsius,
      AppTheme? appTheme,
      String? appLanguage}) {
    if (showExtra != null) sharedPrefs.setBool(prefShowExtra, showExtra);
    if (useCelsius != null) sharedPrefs.setBool(prefUseCelsius, useCelsius);
    if (appTheme != null) sharedPrefs.setInt(prefAppTheme, appTheme.value);
    if (appLanguage != null)
      sharedPrefs.setString(prefAppLanguage, appLanguage);
  }

  // Fetch next alarm info from shared prefs
  static int getNextAlarm() {
    return sharedPrefs.getInt(prefNextAlarm) ?? 0;
  }

  // Store next alarm info in shared prefs to persist when app is closed
  static void setNextAlarm(DateTime timerEndTime) {
    sharedPrefs.setInt(prefNextAlarm, timerEndTime.millisecondsSinceEpoch);
  }

  // Clear shared prefs next alarm info
  static void clearNextAlarm() {
    sharedPrefs.setInt(prefNextAlarm, 0);
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

// Brewing temperature options
final List<int> brewTemps =
    ([for (var i = 60; i <= 100; i += 5) i] // C temps 60-100
        +
        [for (var i = 140; i <= 200; i += 10) i] +
        [212] // F temps 140-212
    );
