/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    prefs.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2021 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa preferences
// - Tea definitions

class Teas {
  // Tea names
  static const String BLACK = 'BLACK';
  static const String GREEN = 'GREEN';
  static const String HERBAL = 'HERBAL';

  // Tea steep times
  static var teaTimerSeconds = {
    BLACK: 240,
    GREEN: 150,
    HERBAL: 300,
  };

  // Button names
  static var teaButton = {
    BLACK: 'BLACK',
    GREEN: 'GREEN',
    HERBAL: 'HERBAL',
  };

  // Tea full names
  static var teaFullName = {
    BLACK: 'Black tea',
    GREEN: 'Green tea',
    HERBAL: 'Herbal tea',
  };

  // Brewing complete text
  static String teaTimerTitle = 'Brewing complete...';
  static var teaTimerText = {
    BLACK: 'Black tea is now ready!',
    GREEN: 'Green tea is now ready!',
    HERBAL: 'Herbal tea is now ready!',
  };
}
