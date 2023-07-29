/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    provider.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2023 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa state provider
// - Tea list management
// - Store current app settings

import 'package:cuppa_mobile/data/constants.dart';
import 'package:cuppa_mobile/data/globals.dart';
import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/data/prefs.dart';
import 'package:cuppa_mobile/data/presets.dart';
import 'package:cuppa_mobile/data/tea.dart';

import 'package:flutter/material.dart';
import 'package:quick_actions/quick_actions.dart';

// Provider for settings changes
class AppProvider extends ChangeNotifier {
  // Teas
  List<Tea> _teaList = [];
  List<Tea> get teaList => [..._teaList];

  // Get number of teas
  int get teaCount {
    return _teaList.length;
  }

  // Add a new tea, optionally at a specific tea list position
  void addTea(Tea newTea, {int? atIndex}) {
    newTea.animate = true;
    if (atIndex == null || atIndex < 0 || atIndex > teaCount) {
      atIndex = teaCount;
    }
    _teaList.insert(atIndex, newTea);
    saveTeas();
  }

  // Update one or more settings for a tea
  void updateTea(Tea tea,
      {String? name,
      int? brewTime,
      int? brewTimeHours,
      int? brewTimeMinutes,
      int? brewTimeSeconds,
      int? brewTemp,
      TeaColor? color,
      TeaIcon? icon,
      bool? isFavorite}) {
    int teaIndex = _teaList.indexOf(tea);
    if (teaIndex >= 0) {
      if (name != null) {
        _teaList[teaIndex].name = name;
      }
      if (brewTime != null) {
        _teaList[teaIndex].brewTime = brewTime;
      }
      if (brewTimeHours != null) {
        _teaList[teaIndex].brewTimeHours = brewTimeHours;
      }
      if (brewTimeMinutes != null) {
        _teaList[teaIndex].brewTimeMinutes = brewTimeMinutes;
      }
      if (brewTimeSeconds != null) {
        _teaList[teaIndex].brewTimeSeconds = brewTimeSeconds;
      }
      if (brewTemp != null) {
        _teaList[teaIndex].brewTemp = brewTemp;
      }
      if (color != null) {
        _teaList[teaIndex].color = color;
      }
      if (icon != null) {
        _teaList[teaIndex].icon = icon;
      }
      if (isFavorite != null) {
        _teaList[teaIndex].isFavorite = isFavorite;
      }
      saveTeas();
    }
  }

  // Reorder the tea list
  void reorderTeas(int oldIndex, int newIndex) {
    Tea tea = _teaList.removeAt(oldIndex);
    _teaList.insert(newIndex, tea);
    saveTeas();
  }

  // Delete a tea
  void deleteTea(Tea oldTea) {
    _teaList.removeWhere((tea) => tea.id == oldTea.id);
    saveTeas();
  }

  // Delete entire tea list
  void clearTeaList() {
    _teaList.clear();
    saveTeas();
  }

  // Save teas to prefs and ensure UI elements get updated
  void saveTeas() {
    Prefs.saveTeas(_teaList);
    notifyListeners();

    // Manage quick actions
    setQuickActions();
  }

  // Add quick action shortcuts
  void setQuickActions() {
    quickActions.setShortcutItems(favoritesList.map<ShortcutItem>((tea) {
      // Create a shortcut item for this favorite tea
      return ShortcutItem(
        type: shortcutPrefixID + tea.id.toString(),
        localizedTitle: tea.name,
        icon: tea.shortcutIcon,
      );
    }).toList());
  }

  // Load teas from default presets
  void loadDefaults() {
    _teaList.add(Presets.getPreset(AppString.tea_name_black)
        .createTea(useCelsius: _useCelsius, isFavorite: true));
    _teaList.add(Presets.getPreset(AppString.tea_name_green)
        .createTea(useCelsius: _useCelsius, isFavorite: true));
    _teaList.add(Presets.getPreset(AppString.tea_name_herbal)
        .createTea(useCelsius: _useCelsius, isFavorite: true));

    // Manage quick actions
    setQuickActions();
  }

  // Get favorite tea list
  List<Tea> get favoritesList {
    return _teaList.where((tea) => tea.isFavorite == true).toList();
  }

  // Activate a tea
  void activateTea(Tea tea, int notifyID) {
    int teaIndex = _teaList.indexOf(tea);
    if (teaIndex >= 0) {
      _teaList[teaIndex].activate(notifyID);
      Prefs.saveTeas(_teaList);
      notifyListeners();
    }
  }

  // Deactivate a tea
  void deactivateTea(Tea tea) {
    int teaIndex = _teaList.indexOf(tea);
    if (teaIndex >= 0) {
      _teaList[teaIndex].deactivate();
      Prefs.saveTeas(_teaList);
      notifyListeners();
    }
  }

  // Clear active tea
  void clearActiveTea() {
    _teaList.where((tea) => tea.isActive == true).forEach((tea) {
      tea.deactivate();
    });
    Prefs.saveTeas(_teaList);
    notifyListeners();
  }

  // Get active tea list
  List<Tea> get activeTeas {
    return _teaList.where((tea) => tea.isActive == true).toList();
  }

  // Setting: show brew time and temperature on timer buttons
  bool _showExtra = false;
  bool get showExtra => _showExtra;
  set showExtra(bool newValue) {
    _showExtra = newValue;
    Prefs.saveSettings(showExtra: _showExtra);
    notifyListeners();
  }

  // Setting: use Celsius temperature for new teas
  bool _useCelsius = true;
  bool get useCelsius => _useCelsius;
  set useCelsius(bool newValue) {
    _useCelsius = newValue;
    Prefs.saveSettings(useCelsius: _useCelsius);
    notifyListeners();
  }

  // Setting: app color theme
  AppTheme _appTheme = AppTheme.system;
  AppTheme get appTheme => _appTheme;
  set appTheme(AppTheme newValue) {
    _appTheme = newValue;
    Prefs.saveSettings(appTheme: _appTheme);
    notifyListeners();
  }

  // Setting: app language
  String _appLanguage = followSystemLanguage;
  String get appLanguage => _appLanguage;
  set appLanguage(String newValue) {
    _appLanguage = newValue;
    Prefs.saveSettings(appLanguage: _appLanguage);
    notifyListeners();
  }

  // Notify listeners
  void notify() {
    notifyListeners();
  }

  // Initialize provider
  AppProvider() {
    // Fetch app settings such as theme and language
    _showExtra = Prefs.loadShowExtra() ?? _showExtra;
    _appTheme = Prefs.loadAppTheme() ?? _appTheme;
    _appLanguage = Prefs.loadAppLanguage() ?? _appLanguage;

    // Load teas from prefs
    if (Prefs.teaPrefsExist()) {
      _teaList = Prefs.loadTeas();

      // Manage quick actions
      setQuickActions();
    }
  }
}
