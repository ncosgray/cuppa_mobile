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
import 'package:cuppa_mobile/common/icons.dart';
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
  static Future<void> init() async {
    const SharedPreferencesOptions sharedPreferencesOptions = .new();

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
        teaList += (teaListJson.map<Tea>(
          (tea) => Tea.fromJson(jsonDecode(tea)),
        )).toList();
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
    List<String> teaListEncoded = teaList
        .map((tea) => jsonEncode(tea.toJson()))
        .toList();
    sharedPrefs.setStringList(prefTeaList, teaListEncoded);

    // Ensure next tea ID is valid
    int maxTeaID = maxBy(teaList, (tea) => tea.id)?.id ?? -1;
    if (nextTeaID <= maxTeaID) {
      nextTeaID = maxTeaID + 1;
    }
    sharedPrefs.setInt(prefNextTeaID, nextTeaID);
  }

  // Get settings from shared prefs
  static List<ExtraInfo>? loadShowExtraList() {
    if (sharedPrefs.containsKey(prefShowExtraList)) {
      return (sharedPrefs.getStringList(prefShowExtraList) ?? [])
          .map(
            (element) => ExtraInfo.values.cast<ExtraInfo?>().firstWhere(
              (infoType) => infoType?.value.toString() == element,
              orElse: () => null,
            ),
          )
          .where((infoType) => infoType != null)
          .cast<ExtraInfo>()
          .toList();
    } else if (sharedPrefs.containsKey(prefShowExtra)) {
      // Migrate from legacy setting
      List<ExtraInfo> list = (sharedPrefs.getBool(prefShowExtra) ?? false)
          ? ExtraInfo.values
          : defaultShowExtraList;
      saveSettings(showExtraList: list);
      sharedPrefs.remove(prefShowExtra);
      return list;
    } else {
      return null;
    }
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
    if (cupStyleValue != null && CupStyle.isValid(cupStyleValue)) {
      return CupStyle.fromValue(cupStyleValue)!;
    } else {
      return null;
    }
  }

  static ButtonSize? loadButtonSize() {
    int? buttonSizeValue = sharedPrefs.getInt(prefButtonSize);
    if (buttonSizeValue != null && ButtonSize.isValid(buttonSizeValue)) {
      return ButtonSize.fromValue(buttonSizeValue)!;
    } else {
      return null;
    }
  }

  static AppTheme? loadAppTheme() {
    int? appThemeValue = sharedPrefs.getInt(prefAppTheme);
    if (appThemeValue != null && AppTheme.isValid(appThemeValue)) {
      return AppTheme.fromValue(appThemeValue)!;
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
    List<ExtraInfo>? showExtraList,
    bool? hideIncrements,
    bool? silentDefault,
    bool? useCelsius,
    bool? useBrewRatios,
    CupStyle? cupStyle,
    ButtonSize? buttonSize,
    AppTheme? appTheme,
    String? appLanguage,
    bool? collectStats,
    bool? stackedView,
  }) {
    if (showExtraList != null) {
      sharedPrefs.setStringList(
        prefShowExtraList,
        showExtraList.map((infoType) => infoType.value.toString()).toList(),
      );
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
    if (buttonSize != null) {
      sharedPrefs.setInt(prefButtonSize, buttonSize.value);
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
  classic(0, .prefs_cup_style_classic, cupImageClassic),
  floral(1, .prefs_cup_style_floral, cupImageFloral),
  chinese(2, .prefs_cup_style_chinese, cupImageChinese),
  mug(3, .prefs_cup_style_mug, cupImageMug),
  none(99, .prefs_cup_style_none, null);

  const CupStyle(this.value, this._nameString, this._cupImage);

  final int value;
  final AppString _nameString;
  final String? _cupImage;

  // Cup style images
  Widget get image {
    if (_cupImage == null) {
      return noneIcon;
    } else {
      return Image.asset(_cupImage, fit: .fitWidth, gaplessPlayback: true);
    }
  }

  // Localized style names
  String get localizedName => _nameString.translate();

  // Value lookups
  static final _valueMap = {for (var item in CupStyle.values) item.value: item};
  static bool isValid(int value) => _valueMap.containsKey(value);
  static CupStyle? fromValue(int value) => _valueMap[value];
}

// Timer button size options
enum ButtonSize {
  small(0, .prefs_button_size_small, 0.9),
  medium(1, .prefs_button_size_medium, 1),
  large(2, .prefs_button_size_large, 1.1);

  const ButtonSize(this.value, this._nameString, this.scale);

  final int value;
  final AppString _nameString;
  final double scale;

  // Localized button size names
  String get localizedName => _nameString.translate();

  // Value lookups
  static final _valueMap = {
    for (var item in ButtonSize.values) item.value: item,
  };
  static bool isValid(int value) => _valueMap.containsKey(value);
  static ButtonSize? fromValue(int value) => _valueMap[value];
}

// App themes
enum AppTheme {
  system(0, .theme_system, .system, false),
  light(1, .theme_light, .light, false),
  dark(2, .theme_dark, .dark, false),
  black(3, .theme_black, .dark, true),
  systemBlack(4, .theme_system_black, .system, true);

  const AppTheme(this.value, this._nameString, this.themeMode, this.blackTheme);

  final int value;
  final AppString _nameString;
  final ThemeMode themeMode;
  final bool blackTheme;

  // Localized theme names
  String get localizedName => _nameString.translate();

  // Value lookups
  static final _valueMap = {for (var item in AppTheme.values) item.value: item};
  static bool isValid(int value) => _valueMap.containsKey(value);
  static AppTheme? fromValue(int value) => _valueMap[value];
}

// Extra info options
enum ExtraInfo {
  brewTime(0, .prefs_extra_brew_time),
  brewTemp(1, .prefs_extra_brew_temp),
  brewRatio(2, .prefs_extra_brew_ratio);

  const ExtraInfo(this.value, this._nameString);

  final int value;
  final AppString _nameString;

  // Localized extra info names
  String get localizedName => _nameString.translate();
}

List<ExtraInfo> defaultShowExtraList = List<ExtraInfo>.empty(growable: true);

// Brewing time options
final List<int> brewTimeHourOptions = List.generate(
  teaBrewTimeMaxHours,
  (i) => i,
);
final List<int> brewTimeMinuteOptions = List.generate(
  teaBrewTimeMaxMinutes,
  (i) => i,
);
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
