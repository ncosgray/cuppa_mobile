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
const hairSpace = '\u200a';

// Infer C or F based on temp range
bool isTempCelsius(i) {
  return (i <= boilDegreesC && i != roomTempDegreesF);
}

// Format brew temperature as number with units
String formatTemp(i) {
  return i.toString() + (isTempCelsius(i) ? degreesC : degreesF);
}

// Format brew remaining time as m:ss or hm
String formatTimer(s) {
  int hrs = (s / 3600).floor();
  int mins = (s / 60).floor() - (hrs * 60);
  int secs = s - (mins * 60);

  // Build the time format string
  if (hrs > 0) {
    return '${hrs}h$hairSpace${mins}m';
  } else {
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }
}
