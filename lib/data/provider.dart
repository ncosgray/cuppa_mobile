/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    provider.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2025 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa state provider
// - Tea list management
// - Store current app settings

import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/common/shortcut_handler.dart';
import 'package:cuppa_mobile/data/brew_ratio.dart';
import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/data/prefs.dart';
import 'package:cuppa_mobile/data/presets.dart';
import 'package:cuppa_mobile/data/stats.dart';
import 'package:cuppa_mobile/data/tea.dart';

import 'package:flutter/material.dart';

// Provider for settings changes
class AppProvider extends ChangeNotifier {
  // Initialize provider
  AppProvider() {
    // Fetch app settings such as theme and language
    _showExtraList = Prefs.loadShowExtraList() ?? _showExtraList;
    _hideIncrements = Prefs.loadHideIncrements() ?? _hideIncrements;
    _silentDefault = Prefs.loadSilentDefault() ?? _silentDefault;
    _useBrewRatios = Prefs.loadUseBrewRatios() ?? _useBrewRatios;
    _cupStyle = Prefs.loadCupStyle() ?? _cupStyle;
    _appTheme = Prefs.loadAppTheme() ?? _appTheme;
    _appLanguage = Prefs.loadAppLanguage() ?? _appLanguage;
    _collectStats = Prefs.loadCollectStats() ?? _collectStats;
    _stackedView = Prefs.loadStackedView() ?? _stackedView;

    // Load teas from prefs
    if (Prefs.teaPrefsExist()) {
      _teaList = Prefs.loadTeas();

      // Manage shortcut options
      setupShortcuts();
    }
  }

  // Teas
  List<Tea> _teaList = [];
  List<Tea> get teaList => [..._teaList];
  set teaList(List<Tea> newList) {
    _teaList = newList;
    saveTeas();
  }

  // Get number of teas
  int get teaCount {
    return _teaList.length;
  }

  // Add a new tea, optionally at a specific tea list position
  void addTea(Tea newTea, {int? atIndex}) {
    if (atIndex == null || atIndex < 0 || atIndex > teaCount) {
      atIndex = teaCount;
    }
    _teaList.insert(atIndex, newTea);
    saveTeas();
  }

  // Update one or more settings for a tea
  void updateTea(
    Tea tea, {
    String? name,
    int? brewTime,
    int? brewTimeHours,
    int? brewTimeMinutes,
    int? brewTimeSeconds,
    int? brewTemp,
    BrewRatio? brewRatio,
    TeaColor? color,
    Color? colorShade,
    TeaIcon? icon,
    bool? isFavorite,
    bool? isSilent,
  }) {
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
      if (brewRatio != null) {
        _teaList[teaIndex].brewRatio = brewRatio;
      }
      if (color != null) {
        _teaList[teaIndex].color = color;
      }
      if (colorShade != null) {
        _teaList[teaIndex].colorShade = colorShade;
      }
      if (icon != null) {
        _teaList[teaIndex].icon = icon;
      }
      if (isFavorite != null) {
        _teaList[teaIndex].isFavorite = isFavorite;
      }
      if (isSilent != null) {
        _teaList[teaIndex].isSilent = isSilent;
      }
      saveTeas();
    }
  }

  // Sort the tea list
  Future<void> sortTeas({SortBy? sortBy}) async {
    switch (sortBy) {
      case SortBy.favorite:
        {
          // Sort favorites first, then alpha
          _teaList.sort((a, b) {
            int compare = (a.isFavorite ? 0 : 1).compareTo(
              b.isFavorite ? 0 : 1,
            );
            if (compare != 0) {
              return compare;
            }
            return a.name.compareTo(b.name);
          });
        }
      case SortBy.color:
        {
          // Sort by hue/lightness, then alpha
          _teaList.sort((a, b) {
            HSLColor aColor = HSLColor.fromColor(
              a.colorShade ?? a.color.getColor(),
            );
            HSLColor bColor = HSLColor.fromColor(
              b.colorShade ?? b.color.getColor(),
            );
            int compare = aColor.hue.compareTo(bColor.hue);
            if (compare != 0) {
              return compare;
            }
            compare = bColor.lightness.compareTo(aColor.lightness);
            if (compare != 0) {
              return compare;
            }
            return a.name.compareTo(b.name);
          });
        }
      case SortBy.brewTime:
        {
          // Sort shortest brew time first, then alpha
          _teaList.sort((a, b) {
            int compare = a.brewTime.compareTo(b.brewTime);
            if (compare != 0) {
              return compare;
            }
            return a.name.compareTo(b.name);
          });
        }
      case SortBy.usage:
      case SortBy.recent:
        {
          // Fetch sort order from stats
          List<Stat> stats = await Stats.getTeaStats(
            sortBy == SortBy.recent
                ? ListQuery.recentlyUsed
                : ListQuery.mostUsed,
          );

          // Sort most used/recent first, then alpha
          _teaList.sort((a, b) {
            int aUsage = (stats.firstWhere(
              (stat) => stat.id == a.id,
              orElse: () => Stat(count: 0),
            )).count;
            int bUsage = (stats.firstWhere(
              (stat) => stat.id == b.id,
              orElse: () => Stat(count: 0),
            )).count;
            int compare = bUsage.compareTo(aUsage);
            if (compare != 0) {
              return compare;
            }
            return a.name.compareTo(b.name);
          });
        }
      default:
        {
          // Default to alpha sort
          _teaList.sort((a, b) => a.name.compareTo(b.name));
        }
    }
    saveTeas();
  }

  // Reorder the tea list
  void reorderTeas(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
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

    // Manage shortcut options
    setupShortcuts();
  }

  // Set up shortcuts
  Future<void> setupShortcuts() async {
    await ShortcutHandler.populate(
      teaList: teaList,
      favoritesList: favoritesList,
    );
  }

  // Load teas from default presets
  void loadDefaults() {
    _teaList
      ..add(
        Presets.getPreset(
          AppString.tea_name_black,
        ).createTea(useCelsius: _useCelsius, isFavorite: true),
      )
      ..add(
        Presets.getPreset(
          AppString.tea_name_green,
        ).createTea(useCelsius: _useCelsius, isFavorite: true),
      )
      ..add(
        Presets.getPreset(
          AppString.tea_name_herbal,
        ).createTea(useCelsius: _useCelsius, isFavorite: true),
      );

    // Manage shortcut options
    setupShortcuts();
  }

  // Get favorite tea list
  List<Tea> get favoritesList {
    return _teaList.where((tea) => tea.isFavorite == true).toList();
  }

  // Activate a tea
  void activateTea(Tea tea, int notifyID, silentDefault) {
    int teaIndex = _teaList.indexOf(tea);
    if (teaIndex >= 0) {
      _teaList[teaIndex].activate(notifyID, silentDefault);
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

  // Adjust a tea's brewing time
  bool incrementTimer(Tea tea, int secs) {
    int teaIndex = _teaList.indexOf(tea);
    if (teaIndex >= 0) {
      Tea tea = _teaList[teaIndex];
      int ms = secs * 1000;
      int now = DateTime.now().millisecondsSinceEpoch;
      if (tea.isActive &&
          tea.timerEndTime + ms > now &&
          tea.timerEndTime + ms < now + (teaBrewTimeMaxHours * 3600 * 1000)) {
        tea.adjustBrewTimeRemaining(ms);
        Prefs.saveTeas(_teaList);
        notifyListeners();
        return true;
      }
    }
    return false;
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

  // Setting: show brew time, temperature, and ratio on timer buttons
  List<ExtraInfo> _showExtraList = defaultShowExtraList;
  List<ExtraInfo> get showExtraList => _showExtraList;
  set showExtraList(List<ExtraInfo> newList) {
    _showExtraList = newList;
    Prefs.saveSettings(showExtraList: _showExtraList);
    notifyListeners();
  }

  void toggleExtraInfo(ExtraInfo infoType, bool enabled) {
    bool updated = false;

    if (enabled && !_showExtraList.contains(infoType)) {
      _showExtraList.add(infoType);
      updated = true;
    } else if (!enabled && _showExtraList.contains(infoType)) {
      _showExtraList.remove(infoType);
      updated = true;
    }

    if (updated) {
      Prefs.saveSettings(showExtraList: _showExtraList);
      notifyListeners();
    }
  }

  // Setting: hide timer increment buttons
  bool _hideIncrements = true;
  bool get hideIncrements => _hideIncrements;
  set hideIncrements(bool newValue) {
    _hideIncrements = newValue;
    Prefs.saveSettings(hideIncrements: _hideIncrements);
    notifyListeners();
  }

  // Setting: default to silent timer notifications
  bool _silentDefault = false;
  bool get silentDefault => _silentDefault;
  set silentDefault(bool newValue) {
    _silentDefault = newValue;
    Prefs.saveSettings(silentDefault: _silentDefault);
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

  // Setting: use brew ratios
  bool _useBrewRatios = false;
  bool get useBrewRatios => _useBrewRatios;
  set useBrewRatios(bool newValue) {
    _useBrewRatios = newValue;
    Prefs.saveSettings(useBrewRatios: _useBrewRatios);
    notifyListeners();
  }

  // Setting: teacup style
  CupStyle _cupStyle = CupStyle.classic;
  CupStyle get cupStyle => _cupStyle;
  set cupStyle(CupStyle newValue) {
    _cupStyle = newValue;
    Prefs.saveSettings(cupStyle: _cupStyle);
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

  // Setting: collect timer usage stats
  bool _collectStats = false;
  bool get collectStats => _collectStats;
  set collectStats(bool newValue) {
    _collectStats = newValue;
    Prefs.saveSettings(collectStats: _collectStats);
    notifyListeners();
  }

  // Setting: stacked timer button view
  bool _stackedView = false;
  bool get stackedView => _stackedView;
  set stackedView(bool newValue) {
    _stackedView = newValue;
    Prefs.saveSettings(stackedView: _stackedView);
    notifyListeners();
  }

  // Notify listeners
  void notify() {
    notifyListeners();
  }
}

// Sort criteria
enum SortBy {
  alpha(AppString.sort_by_alpha, false),
  favorite(AppString.sort_by_favorite, false),
  color(AppString.sort_by_color, false),
  brewTime(AppString.sort_by_brew_time, false),
  usage(AppString.sort_by_usage, true),
  recent(AppString.sort_by_recent, true);

  const SortBy(this._nameString, this.statsRequired);

  final AppString _nameString;
  final bool statsRequired;

  // Localized sort criteria names
  String get localizedName => _nameString.translate();
}
