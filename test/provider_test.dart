/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    provider_test.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2026 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa unit tests: AppProvider
// - Tea list management and persistence
// - Timer activation, adjustment, and infusion handling
// - Settings persistence and change notification

import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/data/prefs.dart';
import 'package:cuppa_mobile/data/provider.dart';
import 'package:cuppa_mobile/data/tea.dart';

import 'package:flutter_test/flutter_test.dart';

import 'tea_test.dart' show makeTea;
import 'test_setup.dart';

void main() {
  late AppProvider provider;

  setUp(() async {
    await setUpTestEnvironment();
    provider = AppProvider();
  });

  group('Tea list management', () {
    test('addTea appends by default and inserts at index', () {
      Tea teaA = makeTea(name: 'A');
      Tea teaB = makeTea(name: 'B');
      Tea teaC = makeTea(name: 'C');

      provider
        ..addTea(teaA)
        ..addTea(teaB)
        ..addTea(teaC, atIndex: 1);

      expect(provider.teaList.map((tea) => tea.name), ['A', 'C', 'B']);
      expect(provider.teaCount, 3);
    });

    test('addTea clamps out-of-range indexes', () {
      provider
        ..addTea(makeTea(name: 'A'), atIndex: 99)
        ..addTea(makeTea(name: 'B'), atIndex: -5);

      expect(provider.teaList.map((tea) => tea.name), ['A', 'B']);
    });

    test('deleteTea removes by ID', () {
      Tea teaA = makeTea(name: 'A');
      Tea teaB = makeTea(name: 'B');
      provider
        ..addTea(teaA)
        ..addTea(teaB)
        ..deleteTea(teaA);

      expect(provider.teaList.map((tea) => tea.name), ['B']);
    });

    test('reorderTeas moves a tea forward and back', () {
      provider
        ..addTea(makeTea(name: 'A'))
        ..addTea(makeTea(name: 'B'))
        ..addTea(makeTea(name: 'C'))
        ..reorderTeas(0, 3);

      expect(provider.teaList.map((tea) => tea.name), ['B', 'C', 'A']);

      provider.reorderTeas(2, 0);
      expect(provider.teaList.map((tea) => tea.name), ['A', 'B', 'C']);
    });

    test('clearTeaList empties the list', () {
      provider
        ..addTea(makeTea())
        ..addTea(makeTea())
        ..clearTeaList();

      expect(provider.teaCount, 0);
    });

    test('teas persist to prefs and reload', () {
      Tea tea = makeTea(name: 'Persisted', brewTime: 120);
      provider.addTea(tea);

      List<Tea> reloaded = Prefs.loadTeas();
      expect(reloaded.length, 1);
      expect(reloaded[0].id, tea.id);
      expect(reloaded[0].name, 'Persisted');
      expect(reloaded[0].brewTime, 120);
    });

    test('favoritesList filters favorites', () {
      provider
        ..addTea(makeTea(name: 'A', isFavorite: true))
        ..addTea(makeTea(name: 'B'))
        ..addTea(makeTea(name: 'C', isFavorite: true));

      expect(provider.favoritesList.map((tea) => tea.name), ['A', 'C']);
    });

    test('updateTea changes fields and resets infusion on count change', () {
      Tea tea = makeTea(name: 'A', numInfusions: 3, currentInfusion: 3);
      provider
        ..addTea(tea)
        ..updateTea(tea, name: 'B', brewTemp: 80, numInfusions: 5);

      Tea updated = provider.teaList[0];
      expect(updated.name, 'B');
      expect(updated.brewTemp, 80);
      expect(updated.numInfusions, 5);
      expect(updated.currentInfusion, 1);
    });

    test('mutations notify listeners', () {
      int notifications = 0;
      provider.addListener(() => notifications++);

      Tea tea = makeTea();
      provider.addTea(tea);
      expect(notifications, 1);

      provider.updateTea(tea, name: 'Renamed');
      expect(notifications, 2);

      provider.deleteTea(tea);
      expect(notifications, 3);
    });
  });

  group('Sorting', () {
    test('sorts alphabetically by default', () async {
      provider
        ..addTea(makeTea(name: 'Chai'))
        ..addTea(makeTea(name: 'Assam'))
        ..addTea(makeTea(name: 'Bancha'));
      await provider.sortTeas();

      expect(provider.teaList.map((tea) => tea.name), [
        'Assam',
        'Bancha',
        'Chai',
      ]);
    });

    test('sorts favorites first', () async {
      provider
        ..addTea(makeTea(name: 'Chai'))
        ..addTea(makeTea(name: 'Assam'))
        ..addTea(makeTea(name: 'Bancha', isFavorite: true));
      await provider.sortTeas(sortBy: SortBy.favorite);

      expect(provider.teaList.map((tea) => tea.name), [
        'Bancha',
        'Assam',
        'Chai',
      ]);
    });

    test('sorts by brew time ascending', () async {
      provider
        ..addTea(makeTea(name: 'Long', brewTime: 300))
        ..addTea(makeTea(name: 'Short', brewTime: 60))
        ..addTea(makeTea(name: 'Medium', brewTime: 120));
      await provider.sortTeas(sortBy: SortBy.brewTime);

      expect(provider.teaList.map((tea) => tea.name), [
        'Short',
        'Medium',
        'Long',
      ]);
    });
  });

  group('Timer state', () {
    test('activateTea activates a list tea and persists', () {
      Tea tea = makeTea(brewTime: 100);
      provider
        ..addTea(tea)
        ..activateTea(tea, notifyID1, true);

      expect(provider.teaList[0].isActive, true);
      expect(provider.teaList[0].isSilent, true);
      expect(provider.activeTeas.length, 1);

      List<Tea> reloaded = Prefs.loadTeas();
      expect(reloaded[0].isActive, true);
      expect(reloaded[0].timerNotifyID, notifyID1);
    });

    test('activateTea on a non-list tea becomes the Quick Timer', () {
      Tea tea = quickTimerTea('Quick', 60);
      provider.activateTea(tea, notifyID2, false);

      expect(provider.quickTimer.isActive, true);
      expect(provider.isQuickTimerActive, true);
      expect(provider.quickTimer.timerNotifyID, notifyID2);

      Tea? reloaded = Prefs.loadQuickTimer();
      expect(reloaded, isNotNull);
      expect(reloaded!.isActive, true);
    });

    test('deactivateTea resets a list tea and persists', () {
      Tea tea = makeTea();
      provider
        ..addTea(tea)
        ..activateTea(tea, notifyID1, false)
        ..deactivateTea(tea);

      expect(provider.teaList[0].isActive, false);
      expect(provider.activeTeas, isEmpty);
      expect(Prefs.loadTeas()[0].isActive, false);
    });

    test('clearActiveTea deactivates everything', () {
      Tea tea = makeTea();
      provider
        ..addTea(tea)
        ..activateTea(tea, notifyID1, false)
        ..activateTea(quickTimerTea('Quick', 60), notifyID2, false)
        ..clearActiveTea();

      expect(provider.activeTeas, isEmpty);
    });

    test('incrementTimer adjusts an active timer', () {
      Tea tea = makeTea(brewTime: 100);
      provider
        ..addTea(tea)
        ..activateTea(tea, notifyID1, false);
      int endTime = provider.teaList[0].timerEndTime;

      expect(provider.incrementTimer(tea, 10), true);
      expect(provider.teaList[0].timerEndTime, endTime + 10000);

      expect(provider.incrementTimer(tea, -10), true);
      expect(provider.teaList[0].timerEndTime, endTime);
    });

    test('incrementTimer rejects inactive teas', () {
      Tea tea = makeTea();
      provider.addTea(tea);

      expect(provider.incrementTimer(tea, 10), false);
    });

    test('incrementTimer rejects adjustments below zero remaining', () {
      Tea tea = makeTea(brewTime: 5);
      provider
        ..addTea(tea)
        ..activateTea(tea, notifyID1, false);

      expect(provider.incrementTimer(tea, -30), false);
    });

    test('incrementTimer rejects adjustments beyond the maximum', () {
      Tea tea = makeTea(brewTime: 100);
      provider
        ..addTea(tea)
        ..activateTea(tea, notifyID1, false);

      expect(provider.incrementTimer(tea, teaBrewTimeMaxHours * 3600), false);
    });

    test('incrementTimer adjusts the Quick Timer', () {
      Tea tea = quickTimerTea('Quick', 60);
      provider.activateTea(tea, notifyID2, false);
      int endTime = provider.quickTimer.timerEndTime;

      expect(provider.incrementTimer(provider.quickTimer, 10), true);
      expect(provider.quickTimer.timerEndTime, endTime + 10000);
    });
  });

  group('Infusion adjustments', () {
    test('adjustTimerForInfusion advances and extends the timer', () {
      Tea tea = makeTea(brewTime: 100, numInfusions: 3, infusionInterval: 30);
      provider
        ..addTea(tea)
        ..activateTea(tea, notifyID1, false);
      int endTime = provider.teaList[0].timerEndTime;

      provider.adjustTimerForInfusion(tea);

      expect(provider.teaList[0].currentInfusion, 2);
      expect(provider.teaList[0].timerEndTime, endTime + 30000);
    });

    test('adjustTimerForInfusion restarts on wrap to infusion 1', () {
      Tea tea = makeTea(
        brewTime: 100,
        numInfusions: 2,
        infusionInterval: 30,
        currentInfusion: 2,
      );
      provider
        ..addTea(tea)
        ..activateTea(tea, notifyID1, false);
      int before = DateTime.now().millisecondsSinceEpoch;

      provider.adjustTimerForInfusion(tea);

      // Wrapped back to infusion 1: restarts at initial brew time
      expect(provider.teaList[0].currentInfusion, 1);
      expect(
        provider.teaList[0].timerEndTime,
        greaterThanOrEqualTo(before + 101 * 1000),
      );
      expect(provider.teaList[0].timerEndTime, lessThan(before + 103 * 1000));
    });

    test('adjustTimerForInfusion ends timer when decrement passes now', () {
      Tea tea = makeTea(brewTime: 10, numInfusions: 3, infusionInterval: -30);
      provider
        ..addTea(tea)
        ..activateTea(tea, notifyID1, false)
        ..adjustTimerForInfusion(tea);

      expect(provider.teaList[0].currentInfusion, 2);
      expect(provider.teaList[0].brewTimeRemaining, 0);
    });

    test('adjustTimerForInfusion ignores single-infusion teas', () {
      Tea tea = makeTea(brewTime: 100, numInfusions: 1);
      provider
        ..addTea(tea)
        ..activateTea(tea, notifyID1, false);
      int endTime = provider.teaList[0].timerEndTime;

      provider.adjustTimerForInfusion(tea);

      expect(provider.teaList[0].currentInfusion, 1);
      expect(provider.teaList[0].timerEndTime, endTime);
    });
  });

  group('Settings', () {
    test('settings persist and reload into a new provider', () {
      provider
        ..hideIncrements = false
        ..silentDefault = true
        ..cupStyle = CupStyle.mug
        ..buttonSize = ButtonSize.large
        ..appTheme = AppTheme.black
        ..collectStats = true
        ..stackedView = true
        ..preNotify = true;

      AppProvider reloaded = AppProvider();
      expect(reloaded.hideIncrements, false);
      expect(reloaded.silentDefault, true);
      expect(reloaded.cupStyle, CupStyle.mug);
      expect(reloaded.buttonSize, ButtonSize.large);
      expect(reloaded.appTheme, AppTheme.black);
      expect(reloaded.collectStats, true);
      expect(reloaded.stackedView, true);
      expect(reloaded.preNotify, true);
    });

    test('toggleExtraInfo adds and removes without duplicates', () {
      int notifications = 0;
      provider
        ..addListener(() => notifications++)
        ..toggleExtraInfo(ExtraInfo.brewTime, true);
      expect(provider.showExtraList, [ExtraInfo.brewTime]);
      expect(notifications, 1);

      // No-op: already enabled
      provider.toggleExtraInfo(ExtraInfo.brewTime, true);
      expect(provider.showExtraList, [ExtraInfo.brewTime]);
      expect(notifications, 1);

      provider.toggleExtraInfo(ExtraInfo.brewTime, false);
      expect(provider.showExtraList, isEmpty);
      expect(notifications, 2);
    });

    test('setQuickTimer persists name and time', () {
      provider.setQuickTimer('Custom', 90);

      expect(provider.quickTimer.name, 'Custom');
      expect(provider.quickTimer.brewTime, 90);

      Tea? reloaded = Prefs.loadQuickTimer();
      expect(reloaded!.name, 'Custom');
      expect(reloaded.brewTime, 90);
    });
  });
}
