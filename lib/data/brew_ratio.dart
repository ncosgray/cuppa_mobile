/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    brew_ratio.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2024 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa data
// - Brew ratio class

import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/common/globals.dart';
import 'package:cuppa_mobile/common/helpers.dart';

// Brew ratio definition
class BrewRatio {
  // Fields
  late double _ratioNumerator;
  late int _ratioDenominator;
  late bool _metricNumerator;
  late bool _metricDenominator;

  // Constructor
  BrewRatio({
    double? ratioNumerator,
    int? ratioDenominator,
    bool? metricNumerator,
    bool? metricDenominator,
  }) {
    _ratioNumerator = ratioNumerator?.toPrecision() ??
        (isLocaleMetric
            ? defaultBrewRatioNumeratorG
            : defaultBrewRatioNumeratorTsp);
    _ratioDenominator = ratioDenominator ??
        (isLocaleMetric
            ? defaultBrewRatioDenominatorMl
            : defaultBrewRatioDenominatorOz);
    _metricNumerator = metricNumerator ?? isLocaleMetric;
    _metricDenominator = metricDenominator ?? isLocaleMetric;
  }

  // Factories
  factory BrewRatio.fromJson(Map<String, dynamic> json) {
    return BrewRatio(
      ratioNumerator: tryCast<double>(json[jsonKeyBrewRatioNumerator]),
      ratioDenominator: tryCast<int>(json[jsonKeyBrewRatioDenominator]),
      metricNumerator: tryCast<bool>(json[jsonKeyBrewRatioMetricNumerator]),
      metricDenominator: tryCast<bool>(json[jsonKeyBrewRatioMetricDenominator]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      jsonKeyBrewRatioNumerator: _ratioNumerator,
      jsonKeyBrewRatioDenominator: _ratioDenominator,
      jsonKeyBrewRatioMetricNumerator: _metricNumerator,
      jsonKeyBrewRatioMetricDenominator: _metricDenominator,
    };
  }

  // Getters
  double get ratioNumerator => _ratioNumerator;
  int get ratioDenominator => _ratioDenominator;
  bool get metricNumerator => _metricNumerator;
  bool get metricDenominator => _metricDenominator;

  String get numeratorString {
    return formatNumeratorAmount(
      _ratioNumerator,
      useMetric: _metricNumerator,
    );
  }

  String get denominatorString {
    return formatDenominatorAmount(
      _ratioDenominator,
      useMetric: _metricDenominator,
    );
  }

  String get ratioString {
    return '$numeratorString / $denominatorString';
  }

  // Setters
  set ratioNumerator(double? d) {
    _ratioNumerator = d?.toPrecision() ??
        (isLocaleMetric
            ? defaultBrewRatioNumeratorG
            : defaultBrewRatioNumeratorTsp);
  }

  set ratioDenominator(int? i) {
    _ratioDenominator = i ??
        (isLocaleMetric
            ? defaultBrewRatioDenominatorMl
            : defaultBrewRatioDenominatorOz);
  }

  set metricNumerator(bool? b) {
    _metricNumerator = b ?? isLocaleMetric;
  }

  set metricDenominator(bool? b) {
    _metricDenominator = b ?? isLocaleMetric;
  }
}
