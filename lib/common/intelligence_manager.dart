/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    intelligence.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2024 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa integration with Apple AppIntents

import 'dart:io';
import 'package:intelligence/intelligence.dart';
import 'package:intelligence/model/representable.dart';

// Intelligence plugin wrapper including platform checks
abstract class IntelligenceManager {
  static final Intelligence intelligence = Intelligence();

  // Populate items (iOS only)
  static Future<void> populate(List<Representable> items) async {
    if (Platform.isIOS) {
      await intelligence.populate(items);
    }
  }

  // Listen for selections (iOS only)
  static void listen(Function(String) onData) {
    if (Platform.isIOS) {
      intelligence.selectionsStream().listen(onData);
    }
  }
}
