/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    themes.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2025 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa visual themes

import 'dart:io' show Platform;
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Theme definitions
final ThemeData lightThemeData = ThemeData(
  brightness: Brightness.light,
  colorSchemeSeed: Colors.blue,
  scaffoldBackgroundColor: Colors.white,
  cardTheme: CardThemeData(color: Colors.grey.shade100),
  listTileTheme: const ListTileThemeData(iconColor: Colors.grey),
  sliderTheme: SliderThemeData(inactiveTrackColor: Colors.grey.shade300),
  iconTheme: const IconThemeData(color: Colors.grey),
  snackBarTheme: SnackBarThemeData(backgroundColor: Colors.grey.shade700),
  splashFactory: splashFactory,
  pageTransitionsTheme: pageTransitionsTheme,
  fontFamily: fontFamily,
  cupertinoOverrideTheme: cupertinoOverrideTheme,
);
final ThemeData darkThemeData = ThemeData(
  brightness: Brightness.dark,
  colorSchemeSeed: Colors.blue,
  scaffoldBackgroundColor: const Color(0xff323232),
  cardTheme: CardThemeData(color: Colors.grey.shade800),
  sliderTheme: SliderThemeData(inactiveTrackColor: Colors.grey.shade800),
  splashFactory: splashFactory,
  pageTransitionsTheme: pageTransitionsTheme,
  fontFamily: fontFamily,
  cupertinoOverrideTheme: cupertinoOverrideTheme,
);
final ThemeData blackThemeData = ThemeData(
  brightness: Brightness.dark,
  colorSchemeSeed: Colors.blue,
  scaffoldBackgroundColor: Colors.black,
  sliderTheme: SliderThemeData(inactiveTrackColor: Colors.grey.shade800),
  splashFactory: splashFactory,
  pageTransitionsTheme: pageTransitionsTheme,
  fontFamily: fontFamily,
  cupertinoOverrideTheme: cupertinoOverrideTheme,
);

// Create a light theme
ThemeData createLightTheme({
  ColorScheme? dynamicColors,
  bool highContrast = false,
}) {
  ThemeData theme = lightThemeData;
  if (dynamicColors != null) {
    // Use dynamic colors if provided
    theme = theme.copyWith(colorScheme: dynamicColors.harmonized());
  }
  if (highContrast) {
    // Apply high contrast adjustments
    theme = theme.copyWith(
      cupertinoOverrideTheme: CupertinoThemeData(
        primaryColor: CupertinoColors.systemBlue.highContrastColor,
      ),
    );
  }
  return theme;
}

// Create a dark or black theme
ThemeData createDarkTheme({
  ColorScheme? dynamicColors,
  bool blackTheme = true,
  bool highContrast = false,
}) {
  ThemeData theme = blackTheme ? blackThemeData : darkThemeData;
  if (dynamicColors != null) {
    // Use dynamic colors if provided
    theme = theme.copyWith(colorScheme: dynamicColors.harmonized());
  }
  if (highContrast) {
    // Apply high contrast adjustments
    theme = theme.copyWith(
      cupertinoOverrideTheme: CupertinoThemeData(
        primaryColor: CupertinoColors.systemBlue.darkHighContrastColor,
      ),
    );
  }
  return theme;
}

// Common theme elements
InteractiveInkFeatureFactory? get splashFactory =>
    Platform.isIOS ? NoSplash.splashFactory : null;

PageTransitionsTheme get pageTransitionsTheme => const PageTransitionsTheme(
  builders: <TargetPlatform, PageTransitionsBuilder>{
    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
  },
);

String? get fontFamily => Platform.isIOS ? 'CupertinoSystemDisplay' : null;

CupertinoThemeData get cupertinoOverrideTheme =>
    const CupertinoThemeData(primaryColor: CupertinoColors.systemBlue);
