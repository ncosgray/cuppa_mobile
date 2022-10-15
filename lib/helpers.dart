/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    helpers.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2022 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa helper functions

const maxDegreesC = 100;
const degreesC = '\u00b0C';
const degreesF = '\u00b0F';

// Format brew temperature as number with units
String formatTemp(i) {
  // Infer C or F based on temp range
  if (i <= maxDegreesC) {
    return i.toString() + degreesC;
  } else {
    return i.toString() + degreesF;
  }
}

// Format brew remaining time as m:ss
String formatTimer(s) {
  // Build the time format string
  int mins = (s / 60).floor();
  int secs = s - (mins * 60);
  return '$mins:${secs.toString().padLeft(2, '0')}';
}
