/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    tea_test.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2026 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa unit tests: Tea model
// - JSON serialization round trip and defaults
// - Brew time decomposition, infusions, timer activation

import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/data/brew_ratio.dart';
import 'package:cuppa_mobile/data/tea.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_setup.dart';

// Create a tea with explicit values for testing
Tea makeTea({
  int? id,
  String name = 'Test Tea',
  int brewTime = 240,
  int brewTemp = 100,
  bool isFavorite = false,
  bool isActive = false,
  int numInfusions = defaultNumInfusions,
  int infusionInterval = defaultInfusionInterval,
  int currentInfusion = 1,
}) => Tea(
  id: id,
  name: name,
  brewTime: brewTime,
  brewTemp: brewTemp,
  brewRatio: BrewRatio(
    ratioNumerator: 3,
    ratioDenominator: 250,
    metricNumerator: true,
    metricDenominator: true,
  ),
  isFavorite: isFavorite,
  isActive: isActive,
  numInfusions: numInfusions,
  infusionInterval: infusionInterval,
  currentInfusion: currentInfusion,
);

void main() {
  setUp(() async {
    await setUpTestEnvironment();
  });

  group('Tea JSON', () {
    test('round trips all fields', () {
      Tea tea =
          makeTea(
              id: 7,
              name: 'Oolong',
              brewTime: 90,
              brewTemp: 88,
              isFavorite: true,
              numInfusions: 4,
              infusionInterval: -15,
              currentInfusion: 3,
            )
            ..color = TeaColor.teal
            ..colorShade = const Color.fromRGBO(120, 130, 140, 1)
            ..icon = TeaIcon.flower
            ..isSilent = true
            ..timerEndTime = 123456789
            ..timerNotifyID = notifyID2;

      Tea decoded = Tea.fromJson(jsonDecode(jsonEncode(tea.toJson())));

      expect(decoded.id, 7);
      expect(decoded.name, 'Oolong');
      expect(decoded.brewTime, 90);
      expect(decoded.brewTemp, 88);
      expect(decoded.brewRatio.ratioNumerator, 3);
      expect(decoded.brewRatio.ratioDenominator, 250);
      expect(decoded.color, TeaColor.teal);
      expect(decoded.colorShade, const Color.fromRGBO(120, 130, 140, 1));
      expect(decoded.icon, TeaIcon.flower);
      expect(decoded.isFavorite, true);
      expect(decoded.isActive, false);
      expect(decoded.isSilent, true);
      expect(decoded.timerEndTime, 123456789);
      expect(decoded.timerNotifyID, notifyID2);
      expect(decoded.numInfusions, 4);
      expect(decoded.infusionInterval, -15);
      expect(decoded.currentInfusion, 3);
    });

    test('applies defaults for missing fields', () {
      Tea decoded = Tea.fromJson(const {});

      expect(decoded.name, unknownString);
      expect(decoded.brewTime, defaultBrewTime);
      expect(decoded.brewTemp, boilDegreesC);
      // Default color value 0 maps to black
      expect(decoded.color, TeaColor.black);
      expect(decoded.colorShade, null);
      expect(decoded.icon, TeaIcon.timer);
      expect(decoded.isFavorite, false);
      expect(decoded.isActive, false);
      expect(decoded.isSilent, false);
      expect(decoded.timerEndTime, 0);
      expect(decoded.timerNotifyID, null);
      expect(decoded.numInfusions, defaultNumInfusions);
      expect(decoded.infusionInterval, defaultInfusionInterval);
      expect(decoded.currentInfusion, 1);
    });

    test('applies defaults for malformed fields', () {
      Tea decoded = Tea.fromJson({
        jsonKeyName: 42,
        jsonKeyBrewTime: 'not a number',
        jsonKeyBrewTemp: false,
        jsonKeyColor: 'red',
        jsonKeyIsFavorite: 'yes',
      });

      expect(decoded.name, unknownString);
      expect(decoded.brewTime, defaultBrewTime);
      expect(decoded.brewTemp, boilDegreesC);
      expect(decoded.color, TeaColor.black);
      expect(decoded.isFavorite, false);
    });

    test('unknown color and icon values fall back to defaults', () {
      Tea decoded = Tea.fromJson({jsonKeyColor: 999, jsonKeyIcon: 999});

      // Same fallbacks as missing values: black color, timer icon
      expect(decoded.color, TeaColor.black);
      expect(decoded.icon, TeaIcon.timer);
    });
  });

  group('Tea IDs', () {
    test('assigns sequential IDs when not given', () {
      Tea tea1 = makeTea();
      Tea tea2 = makeTea();

      expect(tea2.id, tea1.id + 1);
    });
  });

  group('Brew time decomposition', () {
    test('splits into hours, minutes, seconds', () {
      Tea tea = makeTea(brewTime: 3725);

      expect(tea.brewTimeHours, 1);
      expect(tea.brewTimeMinutes, 2);
      expect(tea.brewTimeSeconds, 5);
    });

    test('handles sub-hour and sub-minute times', () {
      expect(makeTea(brewTime: 240).brewTimeMinutes, 4);
      expect(makeTea(brewTime: 240).brewTimeSeconds, 0);
      expect(makeTea(brewTime: 59).brewTimeMinutes, 0);
      expect(makeTea(brewTime: 59).brewTimeSeconds, 59);
    });
  });

  group('Infusions', () {
    test('multipleInfusions boundary', () {
      expect(makeTea(numInfusions: 1).multipleInfusions, false);
      expect(makeTea(numInfusions: numInfusionsMin).multipleInfusions, true);
    });

    test('currentBrewTime is brewTime for single infusion', () {
      Tea tea = makeTea(brewTime: 100, numInfusions: 1, currentInfusion: 1);

      expect(tea.currentBrewTime, 100);
    });

    test('currentBrewTime adds interval per infusion', () {
      Tea tea = makeTea(
        brewTime: 100,
        numInfusions: 3,
        infusionInterval: 30,
        currentInfusion: 3,
      );

      expect(tea.currentBrewTime, 160);
    });

    test('currentBrewTime clamps to minimum 1 second', () {
      Tea tea = makeTea(
        brewTime: 20,
        numInfusions: 3,
        infusionInterval: -15,
        currentInfusion: 3,
      );

      expect(tea.currentBrewTime, 1);
    });

    test('advanceInfusion wraps after the last infusion', () {
      Tea tea = makeTea(numInfusions: 3);

      expect(tea.currentInfusion, 1);
      tea.advanceInfusion();
      expect(tea.currentInfusion, 2);
      tea.advanceInfusion();
      expect(tea.currentInfusion, 3);
      tea.advanceInfusion();
      expect(tea.currentInfusion, 1);
    });
  });

  group('Timer activation', () {
    test('activate sets timer state from current brew time', () {
      int before = DateTime.now().millisecondsSinceEpoch;
      Tea tea = makeTea(
        brewTime: 100,
        numInfusions: 2,
        infusionInterval: 30,
        currentInfusion: 2,
      )..activate(notifyID1, true);

      expect(tea.isActive, true);
      expect(tea.isSilent, true);
      expect(tea.timerNotifyID, notifyID1);
      // End time reflects currentBrewTime (130s) plus 1 second lead
      expect(tea.timerEndTime, greaterThanOrEqualTo(before + 131 * 1000));
      expect(tea.timerEndTime, lessThan(before + 133 * 1000));
    });

    test('deactivate resets timer state', () {
      Tea tea = makeTea()
        ..activate(notifyID1, true)
        ..deactivate();

      expect(tea.isActive, false);
      expect(tea.isSilent, false);
      expect(tea.timerEndTime, 0);
      expect(tea.timerNotifyID, null);
    });

    test('brewTimeRemaining clamps to zero when expired', () {
      Tea tea = makeTea()
        ..timerEndTime = DateTime.now().millisecondsSinceEpoch - 5000;

      expect(tea.brewTimeRemaining, 0);
    });

    test('adjustBrewTimeRemaining shifts end time', () {
      Tea tea = makeTea()
        ..timerEndTime = 1000000
        ..adjustBrewTimeRemaining(10000);

      expect(tea.timerEndTime, 1010000);
    });
  });

  group('Display', () {
    test('colorShade takes priority over color', () {
      Tea tea = makeTea()..color = TeaColor.green;

      expect(tea.getColor(), TeaColor.green.color);

      tea.colorShade = const Color.fromRGBO(1, 2, 3, 1);
      expect(tea.getColor(), const Color.fromRGBO(1, 2, 3, 1));
    });

    test('quickTimerTea uses the Quick Timer ID', () {
      Tea tea = quickTimerTea('Quick', 180, isActive: true);

      expect(tea.id, quickTimerTeaID);
      expect(tea.brewTime, 180);
      expect(tea.isActive, true);
    });
  });
}
