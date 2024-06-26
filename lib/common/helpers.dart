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

// Type conversion
T? tryCast<T>(dynamic object) => object is T ? object : null;

// Precision extension for double
extension Ex on double {
  double toPrecision([int n = 1]) => double.parse(toStringAsFixed(n));
}

// Room temp check based on locale
bool isRoomTemp(i, {bool? useCelsius}) {
  return i == roomTemp ||
      i == roomTempDegreesC ||
      (i == roomTempDegreesF && !(useCelsius ?? isLocaleMetric));
}

// Infer C or F based on temp range and locale
bool isCelsiusTemp(i, {bool? useCelsius}) {
  if (isRoomTemp(i, useCelsius: useCelsius)) {
    return useCelsius ?? isLocaleMetric;
  } else {
    return i <= boilDegreesC;
  }
}

// Localized temperature units
String get degreesC {
  return '$degreeSymbol${AppString.unit_celsius.translate()}';
}

String get degreesF {
  return '$degreeSymbol${AppString.unit_fahrenheit.translate()}';
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

// Format epoch time as date or datetime string
String formatDate(ms, {bool dateTime = false}) {
  return ms > 0
      ? dateTime
          ? DateFormat('yyyy-MM-dd HH:mm')
              .format(DateTime.fromMillisecondsSinceEpoch(ms))
          : DateFormat('yyyy-MM-dd')
              .format(DateTime.fromMillisecondsSinceEpoch(ms))
      : '';
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
  return '${i.toPrecision()}$unit';
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
