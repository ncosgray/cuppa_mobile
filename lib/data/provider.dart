/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    provider.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2026 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa state provider
// - Tea list management
// - Store current app settings

import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/common/globals.dart';
import 'package:cuppa_mobile/common/helpers.dart';
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
    _buttonSize = Prefs.loadButtonSize() ?? _buttonSize;
    _appTheme = Prefs.loadAppTheme() ?? _appTheme;
    _appLanguage = Prefs.loadAppLanguage() ?? _appLanguage;
    _collectStats = Prefs.loadCollectStats() ?? _collectStats;
    _stackedView = Prefs.loadStackedView() ?? _stackedView;
    _preNotify = Prefs.loadPreNotify() ?? _preNotify;
    _quickTimer = Prefs.loadQuickTimer() ?? _quickTimer;

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
    int? brewTemp,
    BrewRatio? brewRatio,
    TeaColor? color,
    Color? colorShade,
    TeaIcon? icon,
    bool? isFavorite,
    bool? isSilent,
    int? numInfusions,
    int? infusionInterval,
    int? currentInfusion,
  }) {
    int teaIndex = _teaList.indexOf(tea);
    if (teaIndex >= 0) {
      final Tea target = _teaList[teaIndex];
      if (name != null) {
        target.name = name;
      }
      if (brewTime != null) {
        target.brewTime = brewTime;
      }
      if (brewTemp != null) {
        target.brewTemp = brewTemp;
      }
      if (brewRatio != null) {
        target.brewRatio = brewRatio;
      }
      if (color != null) {
        target.color = color;
      }
      if (colorShade != null) {
        target.colorShade = colorShade;
      }
      if (icon != null) {
        target.icon = icon;
      }
      if (isFavorite != null) {
        target.isFavorite = isFavorite;
      }
      if (isSilent != null) {
        target.isSilent = isSilent;
      }
      if (numInfusions != null && numInfusions != target.numInfusions) {
        // Restart the infusion cycle when the infusion count changes
        target
          ..numInfusions = numInfusions
          ..currentInfusion = 1;
      }
      if (infusionInterval != null) {
        target.infusionInterval = infusionInterval;
      }
      if (currentInfusion != null) {
        target.currentInfusion = currentInfusion;
      }
      saveTeas();

      // Update Live Activity if this tea is actively timing
      if (target.isActive &&
          (name != null ||
              color != null ||
              colorShade != null ||
              icon != null)) {
        liveActivityService.startOrUpdate(activeTeas);
      }
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
            HSLColor aColor = .fromColor(a.colorShade ?? a.color.getColor());
            HSLColor bColor = .fromColor(b.colorShade ?? b.color.getColor());
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
      quickTimer: quickTimer,
    );
  }

  // Apply locale-based defaults and first-run data at app startup
  // Must be called after localizations have loaded, since default teas and
  // the Quick Timer use translated names
  // Returns true on first run, i.e. default presets were loaded
  bool initializeDefaults() {
    bool isFirstRun = false;
    bool doSetupShortcuts = false;

    // Set default brew temp units based on locale
    useCelsius = Prefs.loadUseCelsius() ?? deviceUsesCelsius();

    // Add Quick Timer defaults if not set
    if (!Prefs.quickTimerPrefsExist()) {
      loadQuickTimerDefaults();
      doSetupShortcuts = true;
    }

    // Add default presets if no custom teas have been set
    if (teaCount == 0 && !Prefs.teaPrefsExist()) {
      loadDefaults();
      isFirstRun = true;
      doSetupShortcuts = true;
    }

    // Manage shortcut options
    if (doSetupShortcuts) {
      setupShortcuts();
    }

    return isFirstRun;
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
  }

  // Get favorite tea list
  List<Tea> get favoritesList {
    return _teaList.where((tea) => tea.isFavorite == true).toList();
  }

  // Timer tick counter (incremented on timer state changes only)
  int _timerTick = 0;
  int get timerTick => _timerTick;

  // Notify listeners for timer-related changes
  void notifyTimerTick() {
    _timerTick++;
    notifyListeners();
  }

  // Quick timer tea
  Tea _quickTimer = quickTimerTea(unknownString, defaultQuickTimerSeconds);
  Tea get quickTimer => _quickTimer;
  void setQuickTimer(String name, int newValue) {
    _quickTimer = quickTimerTea(name, newValue, isActive: true);
    Prefs.saveQuickTimer(_quickTimer);
    notifyListeners();

    // Manage shortcut options
    setupShortcuts();
  }

  bool get isQuickTimerActive => _quickTimer.isActive;

  // Load Quick Timer defaults
  void loadQuickTimerDefaults() {
    _quickTimer = quickTimerTea(
      AppString.quick_timer.translate(),
      defaultQuickTimerSeconds,
    );
  }

  // Locate a tea in the tea list or match the Quick Timer
  Tea? _findTea(Tea tea) {
    int teaIndex = _teaList.indexOf(tea);
    if (teaIndex >= 0) {
      return _teaList[teaIndex];
    }
    return tea == _quickTimer ? _quickTimer : null;
  }

  // Persist a tea to the tea list or Quick Timer store
  void _saveTea(Tea tea) {
    if (_teaList.contains(tea)) {
      Prefs.saveTeas(_teaList);
    } else {
      Prefs.saveQuickTimer(_quickTimer);
    }
  }

  // Activate a tea
  void activateTea(Tea tea, int notifyID, bool silentDefault) {
    Tea? target = _findTea(tea);
    if (target == null) {
      // Not in the tea list: make this tea the Quick Timer
      target = tea;
      _quickTimer = tea;
    }
    target.activate(notifyID, silentDefault);
    _saveTea(target);
  }

  // Deactivate a tea
  void deactivateTea(Tea tea) {
    final Tea? target = _findTea(tea);
    if (target != null) {
      target.deactivate();
      _saveTea(target);
    }
  }

  // Adjust a tea's brewing time
  bool incrementTimer(Tea tea, int secs) {
    final Tea? target = _findTea(tea);
    if (target != null) {
      int ms = secs * 1000;
      int now = DateTime.now().millisecondsSinceEpoch;
      if (target.isActive &&
          target.timerEndTime + ms > now &&
          target.timerEndTime + ms <
              now + (teaBrewTimeMaxHours * 3600 * 1000)) {
        target.adjustBrewTimeRemaining(ms);
        _saveTea(target);
        notifyTimerTick();
        return true;
      }
    }
    return false;
  }

  // Increment/decrement active timer by the tea's infusion interval
  void adjustTimerForInfusion(Tea tea) {
    final Tea? target = _findTea(tea);
    if (target != null && target.isActive && target.multipleInfusions) {
      final int now = DateTime.now().millisecondsSinceEpoch;
      target.advanceInfusion();

      // Update the timer
      if (target.currentInfusion == 1) {
        // Cycled back to start: restart at initial brew time
        target.timerEndTime = now + (target.currentBrewTime + 1) * 1000;
      } else {
        final int ms = target.infusionInterval * 1000;
        if (target.timerEndTime + ms > now) {
          target.adjustBrewTimeRemaining(ms);
        } else {
          // Finish timer immediately
          target.timerEndTime = now;
        }
      }
      _saveTea(target);

      // Update Live Activity with adjusted end time
      liveActivityService.startOrUpdate(activeTeas);

      notifyTimerTick();
    }
  }

  // Reset a tea's infusion cycle to the first infusion
  void resetInfusion(Tea tea) {
    final Tea? target = _findTea(tea);
    if (target != null && target.currentInfusion != 1) {
      target.currentInfusion = 1;
      _saveTea(target);
      notifyListeners();
    }
  }

  // Complete a brew: advance the infusion cycle and deactivate
  void completeTea(Tea tea) {
    final Tea? target = _findTea(tea);
    if (target != null) {
      if (target.multipleInfusions) {
        target.advanceInfusion();
      }
      target.deactivate();
      _saveTea(target);
    }
  }

  // Clear active tea
  void clearActiveTea() {
    _teaList.where((tea) => tea.isActive == true).forEach((tea) {
      // Cancelling a timer abandons the session: restart the infusion cycle
      tea
        ..deactivate()
        ..currentInfusion = 1;
    });
    Prefs.saveTeas(_teaList);
    _quickTimer.deactivate();
    Prefs.saveQuickTimer(_quickTimer);
    notifyTimerTick();
  }

  // Get active tea list
  List<Tea> get activeTeas {
    return [
      ..._teaList.where((tea) => tea.isActive),
      if (isQuickTimerActive) _quickTimer,
    ];
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

  // Setting: tea button size
  ButtonSize _buttonSize = ButtonSize.medium;
  ButtonSize get buttonSize => _buttonSize;
  set buttonSize(ButtonSize newValue) {
    _buttonSize = newValue;
    Prefs.saveSettings(buttonSize: _buttonSize);
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

  // Setting: pre-notify before brewing complete
  bool _preNotify = false;
  bool get preNotify => _preNotify;
  set preNotify(bool newValue) {
    _preNotify = newValue;
    Prefs.saveSettings(preNotify: _preNotify);
    notifyListeners();
  }
}

// Sort criteria
enum SortBy {
  alpha(.sort_by_alpha, false),
  favorite(.sort_by_favorite, false),
  color(.sort_by_color, false),
  brewTime(.sort_by_brew_time, false),
  usage(.sort_by_usage, true),
  recent(.sort_by_recent, true);

  const SortBy(this._nameString, this.statsRequired);

  final AppString _nameString;
  final bool statsRequired;

  // Localized sort criteria names
  String get localizedName => _nameString.translate();
}
