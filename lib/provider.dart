/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    provider.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2022 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa state provider

import 'package:cuppa_mobile/data/prefs.dart';

import 'package:flutter/material.dart';

// Provider for settings changes
class AppProvider extends ChangeNotifier {
  void update() {
    // Save user settings
    Prefs.save();

    // Ensure UI elements get updated
    notifyListeners();
  }
}
