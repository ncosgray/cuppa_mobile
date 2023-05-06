/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    helpers.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2023 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa helper functions

import 'package:cuppa_mobile/data/localization.dart';

const boilDegreesC = 100;
const boilDegreesF = 212;
const roomTempDegreesC = 20;
const roomTempDegreesF = 68;
const degreeSymbol = '\u00b0';
const hairSpace = '\u200a';

// Infer C or F based on temp range
bool isTempCelsius(i) {
  return (i <= boilDegreesC && i != roomTempDegreesF);
}

// Localized temperature units
String get degreesC {
  return '$degreeSymbol${AppString.unit_celsius.translate()}';
}

String get degreesF {
  return '$degreeSymbol${AppString.unit_fahrenheit.translate()}';
}

// Format brew temperature as number with units
String formatTemp(i) {
  String unit = isTempCelsius(i) ? degreesC : degreesF;
  return '$i$unit';
}

// Format brew remaining time as m:ss or hm
String formatTimer(s) {
  int hrs = (s / 3600).floor();
  int mins = (s / 60).floor() - (hrs * 60);
  int secs = s - (mins * 60);

  // Build the localized time format string
  if (hrs > 0) {
    String unitH = AppString.unit_hours.translate();
    String unitM = AppString.unit_minutes.translate();
    return '$hrs$unitH$hairSpace$mins$unitM';
  } else {
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }
}
