/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    test_setup.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2026 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa unit test setup
// - Initialize globals and in-memory shared prefs for unit tests

import 'package:cuppa_mobile/common/globals.dart';
import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/data/prefs.dart';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:region_settings/region_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

// Set up globals and fresh in-memory shared prefs for a unit test
Future<void> setUpTestEnvironment() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Region settings fixture (metric defaults)
  regionSettings = RegionSettings(
    locale: 'en_US',
    temperatureUnits: TemperatureUnit.celsius,
    usesMetricSystem: true,
    firstDayOfWeek: 1,
    dateFormat: RegionDateFormats(
      short: 'M/d/yy',
      medium: 'MMM d, y',
      long: 'MMMM d, y',
    ),
    timeFormat: RegionTimeFormats(
      short: 'h:mm a',
      medium: 'h:mm:ss a',
      long: 'h:mm:ss a z',
    ),
    numberFormat: RegionNumberFormats(
      integer: '#,###,###',
      decimal: '#,###,###.##',
    ),
    icuNumberFormat: '#,##0.###',
    decimalSeparator: '.',
    groupSeparator: ',',
  );

  // Mock the quick actions channel used by shortcut setup
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/quick_actions'),
        (MethodCall call) async => null,
      );

  // Load default localizations so translated strings resolve
  await const AppLocalizationsDelegate(
    isSystemLanguage: true,
  ).load(defaultLocale);

  // Fresh in-memory shared prefs stores
  SharedPreferences.setMockInitialValues({});
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.empty();
  await Prefs.init();
  Prefs.nextTeaID = 0;
}
