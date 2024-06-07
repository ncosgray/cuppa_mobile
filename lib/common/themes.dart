/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    themes.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2024 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa visual themes

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Theme definitions
final ThemeData lightThemeData = ThemeData(
  brightness: Brightness.light,
  colorSchemeSeed: Colors.blue,
  scaffoldBackgroundColor: Colors.white,
  cardTheme: CardTheme(
    color: Colors.grey.shade100,
  ),
  listTileTheme: const ListTileThemeData(
    iconColor: Colors.grey,
  ),
  iconTheme: const IconThemeData(
    color: Colors.grey,
  ),
  cupertinoOverrideTheme: const CupertinoThemeData(
    primaryColor: CupertinoColors.systemBlue,
  ),
);
final ThemeData darkThemeData = ThemeData(
  brightness: Brightness.dark,
  colorSchemeSeed: Colors.blue,
  scaffoldBackgroundColor: const Color(0xff323232),
  cardTheme: CardTheme(
    color: Colors.grey.shade800,
  ),
  cupertinoOverrideTheme: const CupertinoThemeData(
    primaryColor: CupertinoColors.systemBlue,
  ),
);
final ThemeData blackThemeData = ThemeData(
  brightness: Brightness.dark,
  colorSchemeSeed: Colors.blue,
  scaffoldBackgroundColor: Colors.black,
  cupertinoOverrideTheme: const CupertinoThemeData(
    primaryColor: CupertinoColors.systemBlue,
  ),
);

// Create a light theme
ThemeData createLightTheme({ColorScheme? dynamicColors}) {
  ThemeData theme = lightThemeData;
  if (dynamicColors != null) {
    // Use dynamic colors if provided
    theme = theme.copyWith(colorScheme: dynamicColors.harmonized());
  }
  return theme;
}

// Create a dark or black theme
ThemeData createDarkTheme({
  ColorScheme? dynamicColors,
  bool blackTheme = true,
}) {
  ThemeData theme = blackTheme ? blackThemeData : darkThemeData;
  if (dynamicColors != null) {
    // Use dynamic colors if provided
    theme = theme.copyWith(colorScheme: dynamicColors.harmonized());
  }
  return theme;
}
