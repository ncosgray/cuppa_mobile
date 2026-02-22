/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    integration_test_driver.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2026 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Screenshot test driver

import 'dart:io';
import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  // Setup screenshots
  String testLang = Platform.environment['TEST_LOCALE'] ?? 'en-US';
  String screenshotPath = 'screenshots-output/$testLang/';
  String deviceName = (Platform.environment['DEVICE_NAME'] ?? '').replaceAll(
    RegExp(r'[^a-zA-Z0-9]'),
    '',
  );
  String screenshotPrefix = deviceName.isEmpty ? '' : '${deviceName}_';
  await integrationDriver(
    onScreenshot:
        (String name, List<int> bytes, [Map<String, Object?>? args]) async {
          final File image = await File(
            '$screenshotPath/$screenshotPrefix$name.png',
          ).create(recursive: true);
          image.writeAsBytesSync(bytes);
          return true;
        },
  );
}
