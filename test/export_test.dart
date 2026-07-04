/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    export_test.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2026 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa unit tests: export/import
// - Export file JSON round trip
// - Malformed and partial input handling

import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/data/export.dart';
import 'package:cuppa_mobile/data/prefs.dart';
import 'package:cuppa_mobile/data/stats.dart';
import 'package:cuppa_mobile/data/tea.dart';

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

import 'tea_test.dart' show makeTea;
import 'test_setup.dart';

void main() {
  setUp(() async {
    await setUpTestEnvironment();
  });

  group('ExportFile round trip', () {
    test('preserves settings, teas, and stats', () {
      Tea teaA = makeTea(
        id: 1,
        name: 'Sencha',
        brewTime: 120,
        brewTemp: 80,
        isFavorite: true,
        numInfusions: 3,
        infusionInterval: 15,
      );
      Tea teaB = makeTea(id: 2, name: 'Rooibos', brewTime: 300);
      Stat stat = Stat(tea: teaA, timerStartTime: 1234567890);

      String exported = ExportFile(
        settings: ExportSettings(
          nextTeaID: 12,
          showExtraList: [0, 2],
          hideIncrements: false,
          silentDefault: true,
          useCelsius: true,
          useBrewRatios: true,
          cupStyleValue: CupStyle.mug.value,
          buttonSizeValue: ButtonSize.large.value,
          appThemeValue: AppTheme.black.value,
          appLanguage: 'en_US',
          collectStats: true,
          stackedView: true,
          preNotify: false,
        ),
        teaList: [teaA, teaB],
        stats: [stat],
      ).toJson();

      ExportFile decoded = ExportFile.fromJson(jsonDecode(exported));

      // Settings
      expect(decoded.settings, isNotNull);
      expect(decoded.settings!.nextTeaID, 12);
      expect(decoded.settings!.showExtraList, [0, 2]);
      expect(decoded.settings!.hideIncrements, false);
      expect(decoded.settings!.silentDefault, true);
      expect(decoded.settings!.useCelsius, true);
      expect(decoded.settings!.useBrewRatios, true);
      expect(decoded.settings!.cupStyleValue, CupStyle.mug.value);
      expect(decoded.settings!.buttonSizeValue, ButtonSize.large.value);
      expect(decoded.settings!.appThemeValue, AppTheme.black.value);
      expect(decoded.settings!.appLanguage, 'en_US');
      expect(decoded.settings!.collectStats, true);
      expect(decoded.settings!.stackedView, true);
      expect(decoded.settings!.preNotify, false);

      // Teas
      expect(decoded.teaList, isNotNull);
      expect(decoded.teaList!.length, 2);
      expect(decoded.teaList![0].id, 1);
      expect(decoded.teaList![0].name, 'Sencha');
      expect(decoded.teaList![0].brewTime, 120);
      expect(decoded.teaList![0].brewTemp, 80);
      expect(decoded.teaList![0].isFavorite, true);
      expect(decoded.teaList![0].numInfusions, 3);
      expect(decoded.teaList![0].infusionInterval, 15);
      expect(decoded.teaList![1].name, 'Rooibos');

      // Stats
      expect(decoded.stats, isNotNull);
      expect(decoded.stats!.length, 1);
      expect(decoded.stats![0].id, 1);
      expect(decoded.stats![0].name, 'Sencha');
      expect(decoded.stats![0].brewTime, 120);
      expect(decoded.stats![0].timerStartTime, 1234567890);
    });

    test('returns null fields for malformed data', () {
      ExportFile decoded = ExportFile.fromJson(
        jsonDecode('{"unexpected": true}'),
      );

      expect(decoded.settings, null);
      expect(decoded.teaList, null);
      expect(decoded.stats, null);
    });
  });

  group('ExportSettings', () {
    test('missing keys parse as nulls', () {
      ExportSettings settings = ExportSettings.fromJson(const {});

      expect(settings.nextTeaID, null);
      expect(settings.showExtra, null);
      expect(settings.showExtraList, null);
      expect(settings.hideIncrements, null);
      expect(settings.appLanguage, null);
    });

    test('legacy showExtra flag parses', () {
      ExportSettings settings = ExportSettings.fromJson({
        jsonKeyShowExtra: true,
      });

      expect(settings.showExtra, true);
      expect(settings.showExtraList, null);
    });

    test('legacy showExtra is not re-exported', () {
      ExportSettings settings = ExportSettings(showExtra: true);

      expect(settings.toJson().containsKey(jsonKeyShowExtra), false);
    });
  });
}
