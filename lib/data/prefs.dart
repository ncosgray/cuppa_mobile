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

import 'package:cuppa_mobile/main.dart';
import 'package:cuppa_mobile/data/constants.dart';
import 'package:cuppa_mobile/data/localization.dart';
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
  static int appTheme = 0;
  static String appLanguage = '';

  // Color map
  static final Map<int, Color> teaColors = {
    0: Colors.black,
    1: Colors.red[600]!,
    2: Colors.orange,
    3: Colors.green,
    4: Colors.blue,
    5: Colors.purple[400]!,
    6: Colors.brown[400]!,
    7: Colors.pink[200]!,
    8: Colors.amber,
    9: Colors.teal,
    10: Colors.cyan[400]!,
    11: Colors.deepPurple[200]!,
  };

  // Themed color map lookup
  static Color themeColor(int color, context) {
    if (color == 0 || !(Prefs.teaColors.containsKey(color)))
      // "Black" substitutes appropriate color for current theme
      return Theme.of(context).textTheme.button!.color!;
    else
      return Prefs.teaColors[color]!;
  }

  // Brewing temperature options
  static final List<int> brewTemps =
      ([for (var i = 60; i <= 100; i += 5) i] // C temps 60-100
          +
          [for (var i = 140; i <= 200; i += 10) i] +
          [212] // F temps 140-212
      );

  // App theme map
  static final Map<int, ThemeMode> appThemes = {
    0: ThemeMode.system,
    1: ThemeMode.light,
    2: ThemeMode.dark
  };

  // App theme name map
  static final Map<int, String> appThemeNames = {
    0: 'theme_system',
    1: 'theme_light',
    2: 'theme_dark'
  };

  // Quick action shortcut icon map
  static final Map<int, String> shortcutIcons = {
    0: appPlatform == TargetPlatform.iOS ? 'QuickAction' : 'shortcut_black',
    1: appPlatform == TargetPlatform.iOS ? 'QuickAction' : 'shortcut_red',
    2: appPlatform == TargetPlatform.iOS ? 'QuickAction' : 'shortcut_orange',
    3: appPlatform == TargetPlatform.iOS ? 'QuickAction' : 'shortcut_green',
    4: appPlatform == TargetPlatform.iOS ? 'QuickAction' : 'shortcut_blue',
    5: appPlatform == TargetPlatform.iOS ? 'QuickAction' : 'shortcut_purple',
    6: appPlatform == TargetPlatform.iOS ? 'QuickAction' : 'shortcut_brown',
    7: appPlatform == TargetPlatform.iOS ? 'QuickAction' : 'shortcut_pink',
    8: appPlatform == TargetPlatform.iOS ? 'QuickAction' : 'shortcut_amber',
    9: appPlatform == TargetPlatform.iOS ? 'QuickAction' : 'shortcut_teal',
    10: appPlatform == TargetPlatform.iOS ? 'QuickAction' : 'shortcut_cyan',
    11: appPlatform == TargetPlatform.iOS ? 'QuickAction' : 'shortcut_lavender',
  };

  // Fetch top-level app settings such as theme and language
  static void loadTheme() {
    // App settings
    appTheme = sharedPrefs.getInt(prefAppTheme) ?? appTheme;
    appLanguage = sharedPrefs.getString(prefAppLanguage) ?? appLanguage;
  }

  // Fetch tea settings from shared prefs or use defaults
  static void loadTeas() {
    // Initialize teas
    teaList = [];

    // Default: Black tea
    teaList.add(Tea(
        name: sharedPrefs.getString(prefTea1Name) ??
            AppLocalizations.translate('tea_name_black'),
        brewTime: sharedPrefs.getInt(prefTea1BrewTime) ?? 240,
        brewTemp: sharedPrefs.getInt(prefTea1BrewTemp) ??
            (isLocaleMetric ? 100 : 212),
        color: sharedPrefs.getInt(prefTea1Color) ?? 0,
        isFavorite: sharedPrefs.getBool(prefTea1IsFavorite) ?? true,
        isActive: sharedPrefs.getBool(prefTea1IsActive) ?? false));

    // Default: Green tea
    String tea2Name = sharedPrefs.getString(prefTea2Name) ??
        AppLocalizations.translate('tea_name_green');
    teaList.add(Tea(
        name: tea2Name,
        brewTime: sharedPrefs.getInt(prefTea2BrewTime) ?? 150,
        // Select default temp of 212 if name changed from Green tea
        brewTemp: sharedPrefs.getInt(prefTea2BrewTemp) ??
            (tea2Name != AppLocalizations.translate('tea_name_green')
                ? (isLocaleMetric ? 100 : 212)
                : (isLocaleMetric ? 80 : 180)),
        color: sharedPrefs.getInt(prefTea2Color) ?? 3,
        isFavorite: sharedPrefs.getBool(prefTea2IsFavorite) ?? true,
        isActive: sharedPrefs.getBool(prefTea2IsActive) ?? false));

    // Default: Herbal tea
    teaList.add(Tea(
        name: sharedPrefs.getString(prefTea3Name) ??
            AppLocalizations.translate('tea_name_herbal'),
        brewTime: sharedPrefs.getInt(prefTea3BrewTime) ?? 300,
        brewTemp: sharedPrefs.getInt(prefTea3BrewTemp) ??
            (isLocaleMetric ? 100 : 212),
        color: sharedPrefs.getInt(prefTea3Color) ?? 2,
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
    sharedPrefs.setInt(prefTea1Color, teaList[0].color);
    sharedPrefs.setBool(prefTea1IsFavorite, teaList[0].isFavorite);
    sharedPrefs.setBool(prefTea1IsActive, teaList[0].isActive);

    sharedPrefs.setString(prefTea2Name, teaList[1].name);
    sharedPrefs.setInt(prefTea2BrewTime, teaList[1].brewTime);
    sharedPrefs.setInt(prefTea2BrewTemp, teaList[1].brewTemp);
    sharedPrefs.setInt(prefTea2Color, teaList[1].color);
    sharedPrefs.setBool(prefTea2IsFavorite, teaList[1].isFavorite);
    sharedPrefs.setBool(prefTea2IsActive, teaList[1].isActive);

    sharedPrefs.setString(prefTea3Name, teaList[2].name);
    sharedPrefs.setInt(prefTea3BrewTime, teaList[2].brewTime);
    sharedPrefs.setInt(prefTea3BrewTemp, teaList[2].brewTemp);
    sharedPrefs.setInt(prefTea3Color, teaList[2].color);
    sharedPrefs.setBool(prefTea3IsFavorite, teaList[2].isFavorite);
    sharedPrefs.setBool(prefTea3IsActive, teaList[2].isActive);

    List<String> moreTeasEncoded =
        (teaList.sublist(3)).map((tea) => jsonEncode(tea.toJson())).toList();
    sharedPrefs.setStringList(prefMoreTeas, moreTeasEncoded);

    sharedPrefs.setBool(prefShowExtra, showExtra);
    sharedPrefs.setBool(prefUseCelsius, useCelsius);
    sharedPrefs.setInt(prefAppTheme, appTheme);
    sharedPrefs.setString(prefAppLanguage, appLanguage);

    // Manage quick actions
    setQuickActions();
  }

  // Add quick action shortcuts
  static void setQuickActions() {
    quickActions.clearShortcutItems();
    quickActions.setShortcutItems(teaList
        .where((tea) => tea.isFavorite == true)
        .take(favoritesMaxCount)
        .map<ShortcutItem>((tea) {
      // Create a shortcut item for this favorite tea
      return ShortcutItem(
        type: shortcutPrefix + teaList.indexOf(tea).toString(),
        localizedTitle: tea.name,
        icon: tea.shortcutIcon,
      );
    }).toList());
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
