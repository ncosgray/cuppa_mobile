/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    prefs_test.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2026 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa unit tests: shared prefs persistence
// - Corrupt data recovery when loading teas and Quick Timer

import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/data/prefs.dart';
import 'package:cuppa_mobile/data/tea.dart';

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

import 'tea_test.dart' show makeTea;
import 'test_setup.dart';

void main() {
  setUp(() async {
    await setUpTestEnvironment();
  });

  group('Corrupt data recovery', () {
    test('loadTeas skips corrupt entries and keeps valid ones', () {
      String validA = jsonEncode(makeTea(id: 1, name: 'Valid A').toJson());
      String validB = jsonEncode(makeTea(id: 2, name: 'Valid B').toJson());
      Prefs.sharedPrefs.setStringList(prefTeaList, [
        validA,
        'not json at all',
        '{"id": "malformed"',
        validB,
      ]);

      List<Tea> loaded = Prefs.loadTeas();

      expect(loaded.map((tea) => tea.name), ['Valid A', 'Valid B']);
    });

    test('loadTeas returns empty list when all entries are corrupt', () {
      Prefs.sharedPrefs.setStringList(prefTeaList, ['garbage', '[]']);

      expect(Prefs.loadTeas(), isEmpty);
    });

    test('loadQuickTimer returns null for corrupt data', () {
      Prefs.sharedPrefs.setString(prefQuickTimer, 'garbage');

      expect(Prefs.loadQuickTimer(), null);
    });
  });
}
