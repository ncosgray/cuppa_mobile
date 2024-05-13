/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    helpers.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2024 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa helper functions

import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/common/globals.dart';
import 'package:cuppa_mobile/data/localization.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:region_settings/region_settings.dart';

// Type conversion
T? tryCast<T>(dynamic object) => object is T ? object : null;

// Precision extension for double
extension Ex on double {
  double toPrecision([int n = 1]) => double.parse(toStringAsFixed(n));
}

// Localized temperature units
String get degreesC {
  return '$degreeSymbol${AppString.unit_celsius.translate()}';
}

String get degreesF {
  return '$degreeSymbol${AppString.unit_fahrenheit.translate()}';
}

// Check if device is set to use Celsius
bool deviceUsesCelsius() {
  return regionSettings.temperatureUnits == TemperatureUnit.celsius;
}

// Room temp check based on locale
bool isRoomTemp(i, {bool? useCelsius}) {
  return i == roomTemp ||
      i == roomTempDegreesC ||
      (i == roomTempDegreesF && !(useCelsius ?? deviceUsesCelsius()));
}

// Infer C or F based on temp range and locale
bool isCelsiusTemp(i, {bool? useCelsius}) {
  if (isRoomTemp(i, useCelsius: useCelsius)) {
    return useCelsius ?? deviceUsesCelsius();
  } else {
    return i <= boilDegreesC;
  }
}

// Format brew temperature as number with optional units
String formatTemp(i, {bool? useCelsius}) {
  if (isRoomTemp(i, useCelsius: useCelsius)) {
    // Room temperature
    return '$emDash$degreeSymbol';
  }
  String unit = useCelsius == null
      ? degreeSymbol
      : isCelsiusTemp(i, useCelsius: useCelsius) && !useCelsius
          ? degreesC
          : !isCelsiusTemp(i, useCelsius: useCelsius) && useCelsius
              ? degreesF
              : degreeSymbol;
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

// Localized epoch time formatting as date or datetime string
String formatDate(int ms, {bool dateTime = false}) {
  String languageCode = AppLocalizations.instance.locale.languageCode;
  DateFormat formatter = fallbackLanguages.contains(languageCode)
      ? DateFormat('yyyy-MM-dd')
      : DateFormat.yMMMd(languageCode);
  if (dateTime) {
    formatter = formatter.add_Hms();
  }
  return formatter.format(DateTime.fromMillisecondsSinceEpoch(ms));
}

// Localized decimal number formatting
String formatDecimal(double i) {
  String languageCode = AppLocalizations.instance.locale.languageCode;
  return NumberFormat(
    '0.0',
    fallbackLanguages.contains(languageCode) ? null : languageCode,
  ).format(i);
}

// Format number as percentage
String formatPercent(i) {
  return NumberFormat('#%').format(i);
}

// Format ratio amounts with units
String formatNumeratorAmount(
  double i, {
  required bool useMetric,
}) {
  String unit = useMetric
      ? AppString.unit_grams.translate()
      : AppString.unit_teaspoons.translate();
  return '${formatDecimal(i)}$unit';
}

String formatDenominatorAmount(
  int i, {
  required bool useMetric,
}) {
  String unit = useMetric
      ? AppString.unit_milliliters.translate()
      : AppString.unit_ounces.translate();
  return '$i$unit';
}

// Fetch details about the device size and orientation
({double width, double height, bool isPortrait, bool isLargeDevice})
    getDeviceSize(BuildContext context) {
  double deviceWidth = MediaQuery.of(context).size.width;
  double deviceHeight = MediaQuery.of(context).size.height;

  return (
    width: deviceWidth,
    height: deviceHeight,
    isPortrait: deviceHeight > deviceWidth,
    isLargeDevice:
        deviceWidth >= largeDeviceSize && deviceHeight >= largeDeviceSize,
  );
}
