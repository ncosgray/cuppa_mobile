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

const boilDegreesC = 100;
const boilDegreesF = 212;
const roomTempDegreesC = 20;
const roomTempDegreesF = 68;
const degreesC = '\u00b0C';
const degreesF = '\u00b0F';

// Infer C or F based on temp range
bool isTempCelsius(i) {
  return (i <= boilDegreesC && i != roomTempDegreesF);
}

// Format brew temperature as number with units
String formatTemp(i) {
  return i.toString() + (isTempCelsius(i) ? degreesC : degreesF);
}

// Format brew remaining time as m:ss
String formatTimer(s) {
  // Build the time format string
  int mins = (s / 60).floor();
  int secs = s - (mins * 60);
  return '$mins:${secs.toString().padLeft(2, '0')}';
}
