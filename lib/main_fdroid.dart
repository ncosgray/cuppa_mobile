/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    main_fdroid.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2025 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa: a simple tea timer app for Android and iOS
// - Alternate main without app store review prompt

import 'package:cuppa_mobile/cuppa_app.dart';

import 'package:flutter/material.dart';

void main() async {
  await initializeApp();
  runApp(const CuppaApp());
}
