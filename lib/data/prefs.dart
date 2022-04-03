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

import 'package:Cuppa/main.dart';
import 'package:Cuppa/data/localization.dart';

import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:quick_actions/quick_actions.dart';

// Teas
List<Tea> teaList = [];

// Settings
bool showExtra = false;
bool useCelsius = isLocaleMetric;
int appTheme = 0;
String appLanguage = '';

// Limits
final int teaNameMaxLength = 16;
final int teasMinCount = 3;
final int teasMaxCount = 15;

// Quick actions
final QuickActions quickActions = const QuickActions();
final int favoritesMaxCount = 4; // iOS limitation
final String shortcutPrefix = 'shortcutTea';

// Tea definition
class Tea {
  // ID
  late UniqueKey id;

  // Fields
  late String name;
  late int brewTime;
  late int brewTemp;
  late int color;
  late bool isFavorite;
  late bool isActive;

  // Constructor
  Tea(
      {required String name,
      required int brewTime,
      required int brewTemp,
      required int color,
      required bool isFavorite,
      required bool isActive}) {
    id = UniqueKey();
    this.name = name;
    this.brewTime = brewTime;
    this.brewTemp = brewTemp;
    this.color = color;
    this.isFavorite = isFavorite;
    this.isActive = isActive;
  }

  // Tea display getters
  get buttonName {
    return this.name.toUpperCase();
  }

  get tempDisplay {
    return formatTemp(this.brewTemp);
  }

  // Color getter
  Color getThemeColor(context) {
    return Prefs.themeColor(this.color, context);
  }

  // Shortcut icon name based on color
  get shortcutIcon {
    return Prefs.shortcutIcons[this.color];
  }

  // Brew time getters
  int get brewTimeSeconds {
    return this.brewTime - (this.brewTimeMinutes * 60);
  }

  int get brewTimeMinutes {
    return (this.brewTime / 60).floor();
  }

  // Brew time setters
  set brewTimeSeconds(int newSecs) {
    this.brewTime = (this.brewTimeMinutes * 60) + newSecs;
  }

  set brewTimeMinutes(int newMins) {
    this.brewTime = (newMins * 60) + this.brewTimeSeconds;
  }

  // Factories
  factory Tea.fromJson(Map<String, dynamic> json) {
    return Tea(
        name: json['name'] ?? '',
        brewTime: json['brewTime'] ?? 0,
        brewTemp: json['brewTemp'] ?? 0,
        color: json['color'] ?? 0,
        isFavorite: json['isFavorite'] ?? false,
        isActive: json['isActive'] ?? false);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': this.name,
      'brewTime': this.brewTime,
      'brewTemp': this.brewTemp,
      'color': this.color,
      'isFavorite': this.isFavorite,
      'isActive': this.isActive,
    };
  }

  // Overrides for comparisons
  @override
  bool operator ==(otherTea) {
    return (otherTea is Tea) &&
        otherTea.name == this.name &&
        otherTea.brewTime == this.brewTime &&
        otherTea.brewTemp == this.brewTemp &&
        otherTea.color == this.color &&
        otherTea.isFavorite == this.isFavorite &&
        otherTea.isActive == this.isActive;
  }

  @override
  int get hashCode =>
      this.name.hashCode ^
      this.brewTime.hashCode ^
      this.brewTemp.hashCode ^
      this.color.hashCode ^
      this.isFavorite.hashCode ^
      this.isActive.hashCode;
}

// Shared prefs functionality
abstract class Prefs {
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

  // Shared prefs keys for teas and other settings
  static const _prefTea1Name = 'Cuppa_tea1_name';
  static const _prefTea1BrewTime = 'Cuppa_tea1_brew_time';
  static const _prefTea1BrewTemp = 'Cuppa_tea1_brew_temp';
  static const _prefTea1Color = 'Cuppa_tea1_color';
  static const _prefTea1IsFavorite = 'Cuppa_tea1_is_favorite';
  static const _prefTea1IsActive = 'Cuppa_tea1_is_active';
  static const _prefTea2Name = 'Cuppa_tea2_name';
  static const _prefTea2BrewTime = 'Cuppa_tea2_brew_time';
  static const _prefTea2BrewTemp = 'Cuppa_tea2_brew_temp';
  static const _prefTea2Color = 'Cuppa_tea2_color';
  static const _prefTea2IsFavorite = 'Cuppa_tea2_is_favorite';
  static const _prefTea2IsActive = 'Cuppa_tea2_is_active';
  static const _prefTea3Name = 'Cuppa_tea3_name';
  static const _prefTea3BrewTime = 'Cuppa_tea3_brew_time';
  static const _prefTea3BrewTemp = 'Cuppa_tea3_brew_temp';
  static const _prefTea3Color = 'Cuppa_tea3_color';
  static const _prefTea3IsFavorite = 'Cuppa_tea3_is_favorite';
  static const _prefTea3IsActive = 'Cuppa_tea3_is_active';
  static const _prefMoreTeas = 'Cuppa_tea_list';
  static const _prefShowExtra = 'Cuppa_show_extra';
  static const _prefUseCelsius = 'Cuppa_use_celsius';
  static const _prefAppTheme = 'Cuppa_app_theme';
  static const _prefAppLanguage = 'Cuppa_app_language';

  // Fetch all settings from shared prefs or use defaults
  static void load() {
    // Initialize teas
    teaList = [];

    // Default: Black tea
    teaList.add(Tea(
        name: sharedPrefs.getString(_prefTea1Name) ??
            AppLocalizations.translate('tea_name_black'),
        brewTime: sharedPrefs.getInt(_prefTea1BrewTime) ?? 240,
        brewTemp: sharedPrefs.getInt(_prefTea1BrewTemp) ??
            (isLocaleMetric ? 100 : 212),
        color: sharedPrefs.getInt(_prefTea1Color) ?? 0,
        isFavorite: sharedPrefs.getBool(_prefTea1IsFavorite) ?? true,
        isActive: sharedPrefs.getBool(_prefTea1IsActive) ?? false));

    // Default: Green tea
    String tea2Name = sharedPrefs.getString(_prefTea2Name) ??
        AppLocalizations.translate('tea_name_green');
    teaList.add(Tea(
        name: tea2Name,
        brewTime: sharedPrefs.getInt(_prefTea2BrewTime) ?? 150,
        // Select default temp of 212 if name changed from Green tea
        brewTemp: sharedPrefs.getInt(_prefTea2BrewTemp) ??
            (tea2Name != AppLocalizations.translate('tea_name_green')
                ? (isLocaleMetric ? 100 : 212)
                : (isLocaleMetric ? 80 : 180)),
        color: sharedPrefs.getInt(_prefTea2Color) ?? 3,
        isFavorite: sharedPrefs.getBool(_prefTea2IsFavorite) ?? true,
        isActive: sharedPrefs.getBool(_prefTea2IsActive) ?? false));

    // Default: Herbal tea
    teaList.add(Tea(
        name: sharedPrefs.getString(_prefTea3Name) ??
            AppLocalizations.translate('tea_name_herbal'),
        brewTime: sharedPrefs.getInt(_prefTea3BrewTime) ?? 300,
        brewTemp: sharedPrefs.getInt(_prefTea3BrewTemp) ??
            (isLocaleMetric ? 100 : 212),
        color: sharedPrefs.getInt(_prefTea3Color) ?? 2,
        isFavorite: sharedPrefs.getBool(_prefTea3IsFavorite) ?? true,
        isActive: sharedPrefs.getBool(_prefTea3IsActive) ?? false));

    // More teas list
    List<String>? moreTeasJson =
        sharedPrefs.getStringList(_prefMoreTeas) ?? null;
    if (moreTeasJson != null)
      teaList += (moreTeasJson.map<Tea>((tea) => Tea.fromJson(jsonDecode(tea))))
          .toList();

    // Other settings
    showExtra = sharedPrefs.getBool(_prefShowExtra) ?? showExtra;
    useCelsius = sharedPrefs.getBool(_prefUseCelsius) ?? useCelsius;
    appTheme = sharedPrefs.getInt(_prefAppTheme) ?? appTheme;
    appLanguage = sharedPrefs.getString(_prefAppLanguage) ?? appLanguage;

    // Manage quick actions
    setQuickActions();
  }

  // Store all settings in shared prefs
  static void save() {
    sharedPrefs.setString(_prefTea1Name, teaList[0].name);
    sharedPrefs.setInt(_prefTea1BrewTime, teaList[0].brewTime);
    sharedPrefs.setInt(_prefTea1BrewTemp, teaList[0].brewTemp);
    sharedPrefs.setInt(_prefTea1Color, teaList[0].color);
    sharedPrefs.setBool(_prefTea1IsFavorite, teaList[0].isFavorite);
    sharedPrefs.setBool(_prefTea1IsActive, teaList[0].isActive);

    sharedPrefs.setString(_prefTea2Name, teaList[1].name);
    sharedPrefs.setInt(_prefTea2BrewTime, teaList[1].brewTime);
    sharedPrefs.setInt(_prefTea2BrewTemp, teaList[1].brewTemp);
    sharedPrefs.setInt(_prefTea2Color, teaList[1].color);
    sharedPrefs.setBool(_prefTea2IsFavorite, teaList[1].isFavorite);
    sharedPrefs.setBool(_prefTea2IsActive, teaList[1].isActive);

    sharedPrefs.setString(_prefTea3Name, teaList[2].name);
    sharedPrefs.setInt(_prefTea3BrewTime, teaList[2].brewTime);
    sharedPrefs.setInt(_prefTea3BrewTemp, teaList[2].brewTemp);
    sharedPrefs.setInt(_prefTea3Color, teaList[2].color);
    sharedPrefs.setBool(_prefTea3IsFavorite, teaList[2].isFavorite);
    sharedPrefs.setBool(_prefTea3IsActive, teaList[2].isActive);

    List<String> moreTeasEncoded =
        (teaList.sublist(3)).map((tea) => jsonEncode(tea.toJson())).toList();
    sharedPrefs.setStringList(_prefMoreTeas, moreTeasEncoded);

    sharedPrefs.setBool(_prefShowExtra, showExtra);
    sharedPrefs.setBool(_prefUseCelsius, useCelsius);
    sharedPrefs.setInt(_prefAppTheme, appTheme);
    sharedPrefs.setString(_prefAppLanguage, appLanguage);

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

  // Shared prefs next alarm info keys
  static const _prefNextAlarm = 'Cuppa_next_alarm_time';

  // Fetch next alarm info from shared prefs
  static int getNextAlarm() {
    return sharedPrefs.getInt(_prefNextAlarm) ?? 0;
  }

  // Store next alarm info in shared prefs to persist when app is closed
  static void setNextAlarm(DateTime timerEndTime) {
    sharedPrefs.setInt(_prefNextAlarm, timerEndTime.millisecondsSinceEpoch);
    Prefs.save();
  }

  // Clear shared prefs next alarm info
  static void clearNextAlarm() {
    sharedPrefs.setInt(_prefNextAlarm, 0);
    teaList.where((tea) => tea.isActive == true).forEach((tea) {
      tea.isActive = false;
    });
    Prefs.save();
  }
}
