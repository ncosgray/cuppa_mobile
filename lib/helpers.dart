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

import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/data/prefs.dart';

// Format brew temperature as number with units
String formatTemp(i) {
  // Infer C or F based on temp range
  if (i <= 100)
    return i.toString() + '\u00b0C';
  else
    return i.toString() + '\u00b0F';
}

// Format brew remaining time as m:ss
String formatTimer(s) {
  // Build the time format string
  int mins = (s / 60).floor();
  int secs = s - (mins * 60);
  String secsString = secs.toString();
  if (secs < 10) secsString = '0' + secsString;
  return mins.toString() + ':' + secsString;
}

// Create a unique default tea name
String getNextDefaultTeaName() {
  // Build the name string
  String nextName;
  int nextNumber = 1;
  do {
    nextName = AppLocalizations.translate('new_tea_default_name') +
        ' ' +
        nextNumber.toString();
    nextNumber++;
  } while (Prefs.teaList.indexWhere((tea) => tea.name == nextName) >= 0);
  return nextName;
}
