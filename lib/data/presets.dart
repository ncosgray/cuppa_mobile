/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    presets.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2025 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa data
// - Preset tea types

import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/common/helpers.dart';
import 'package:cuppa_mobile/data/brew_ratio.dart';
import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/data/tea.dart';

import 'package:flutter/material.dart';

// Preset definition
class Preset {
  Preset({
    required this.key,
    required this.brewTime,
    required this.brewTempDegreesC,
    required this.brewTempDegreesF,
    required this.brewRatioG,
    required this.brewRatioTsp,
    required this.color,
    required this.icon,
    this.isCustom = false,
  });

  // Fields
  AppString key;
  int brewTime;
  int brewTempDegreesC;
  int brewTempDegreesF;
  BrewRatio brewRatioG;
  BrewRatio brewRatioTsp;
  TeaColor color;
  TeaIcon icon;
  bool isCustom;

  // Localized tea name
  String get localizedName {
    return key.translate();
  }

  // Color getter
  Color getColor() {
    return color.getColor();
  }

  // Icon getter
  IconData getIcon() {
    return icon.getIcon();
  }

  // Brew temp display
  String tempDisplay(bool useCelsius) {
    return formatTemp(useCelsius ? brewTempDegreesC : brewTempDegreesF);
  }

  // Brew ratio display
  String ratioDisplay(bool useCelsius) {
    return useCelsius
        ? brewRatioG.numeratorString
        : brewRatioTsp.numeratorString;
  }

  // Create a new tea from this preset
  Tea createTea({required bool useCelsius, bool isFavorite = false}) {
    return Tea(
      name: localizedName,
      brewTime: brewTime,
      brewTemp: (useCelsius ? brewTempDegreesC : brewTempDegreesF),
      brewRatio: (useCelsius ? brewRatioG : brewRatioTsp),
      color: color,
      icon: icon,
      isFavorite: isFavorite,
      isActive: false,
    );
  }
}

// Preset tea types
abstract class Presets {
  // Tea types
  static List<Preset> presetList = [
    // Custom blank tea
    Preset(
      key: AppString.new_tea_default_name,
      brewTime: defaultBrewTime,
      brewTempDegreesC: boilDegreesC,
      brewTempDegreesF: boilDegreesF,
      brewRatioG: BrewRatio(
        ratioNumerator: defaultBrewRatioNumeratorG,
        ratioDenominator: defaultBrewRatioDenominatorMl,
        metricNumerator: true,
        metricDenominator: true,
      ),
      brewRatioTsp: BrewRatio(
        ratioNumerator: defaultBrewRatioNumeratorTsp,
        ratioDenominator: defaultBrewRatioDenominatorOz,
        metricNumerator: false,
        metricDenominator: false,
      ),
      color: .black,
      icon: .timer,
      isCustom: true,
    ),
    // Black tea
    Preset(
      key: AppString.tea_name_black,
      brewTime: 240,
      brewTempDegreesC: boilDegreesC,
      brewTempDegreesF: boilDegreesF,
      brewRatioG: BrewRatio(
        ratioNumerator: 3,
        ratioDenominator: 250,
        metricNumerator: true,
        metricDenominator: true,
      ),
      brewRatioTsp: BrewRatio(
        ratioNumerator: 1,
        ratioDenominator: 8,
        metricNumerator: false,
        metricDenominator: false,
      ),
      color: .black,
      icon: .timer,
    ),
    // Assam
    Preset(
      key: AppString.tea_name_assam,
      brewTime: 210,
      brewTempDegreesC: 95,
      brewTempDegreesF: 200,
      brewRatioG: BrewRatio(
        ratioNumerator: 3,
        ratioDenominator: 250,
        metricNumerator: true,
        metricDenominator: true,
      ),
      brewRatioTsp: BrewRatio(
        ratioNumerator: 1,
        ratioDenominator: 8,
        metricNumerator: false,
        metricDenominator: false,
      ),
      color: .black,
      icon: .timer,
    ),
    // Darjeeling
    Preset(
      key: AppString.tea_name_darjeeling,
      brewTime: 270,
      brewTempDegreesC: 95,
      brewTempDegreesF: 200,
      brewRatioG: BrewRatio(
        ratioNumerator: 3,
        ratioDenominator: 250,
        metricNumerator: true,
        metricDenominator: true,
      ),
      brewRatioTsp: BrewRatio(
        ratioNumerator: 1,
        ratioDenominator: 8,
        metricNumerator: false,
        metricDenominator: false,
      ),
      color: .black,
      icon: .timer,
    ),
    // Green tea
    Preset(
      key: AppString.tea_name_green,
      brewTime: 150,
      brewTempDegreesC: 80,
      brewTempDegreesF: 180,
      brewRatioG: BrewRatio(
        ratioNumerator: 3,
        ratioDenominator: 250,
        metricNumerator: true,
        metricDenominator: true,
      ),
      brewRatioTsp: BrewRatio(
        ratioNumerator: 3,
        ratioDenominator: 8,
        metricNumerator: false,
        metricDenominator: false,
      ),
      color: .green,
      icon: .timer,
    ),
    // White tea
    Preset(
      key: AppString.tea_name_white,
      brewTime: 300,
      brewTempDegreesC: 80,
      brewTempDegreesF: 180,
      brewRatioG: BrewRatio(
        ratioNumerator: 3,
        ratioDenominator: 250,
        metricNumerator: true,
        metricDenominator: true,
      ),
      brewRatioTsp: BrewRatio(
        ratioNumerator: 3,
        ratioDenominator: 8,
        metricNumerator: false,
        metricDenominator: false,
      ),
      color: .green,
      icon: .timer,
    ),
    // Herbal tea
    Preset(
      key: AppString.tea_name_herbal,
      brewTime: 300,
      brewTempDegreesC: boilDegreesC,
      brewTempDegreesF: boilDegreesF,
      brewRatioG: BrewRatio(
        ratioNumerator: 6,
        ratioDenominator: 250,
        metricNumerator: true,
        metricDenominator: true,
      ),
      brewRatioTsp: BrewRatio(
        ratioNumerator: 2,
        ratioDenominator: 8,
        metricNumerator: false,
        metricDenominator: false,
      ),
      color: .orange,
      icon: .timer,
    ),
    // Chamomile
    Preset(
      key: AppString.tea_name_chamomile,
      brewTime: 300,
      brewTempDegreesC: boilDegreesC,
      brewTempDegreesF: boilDegreesF,
      brewRatioG: BrewRatio(
        ratioNumerator: 6,
        ratioDenominator: 250,
        metricNumerator: true,
        metricDenominator: true,
      ),
      brewRatioTsp: BrewRatio(
        ratioNumerator: 2,
        ratioDenominator: 8,
        metricNumerator: false,
        metricDenominator: false,
      ),
      color: .orange,
      icon: .timer,
    ),
    // Mint tea
    Preset(
      key: AppString.tea_name_mint,
      brewTime: 240,
      brewTempDegreesC: boilDegreesC,
      brewTempDegreesF: boilDegreesF,
      brewRatioG: BrewRatio(
        ratioNumerator: 6,
        ratioDenominator: 250,
        metricNumerator: true,
        metricDenominator: true,
      ),
      brewRatioTsp: BrewRatio(
        ratioNumerator: 2,
        ratioDenominator: 8,
        metricNumerator: false,
        metricDenominator: false,
      ),
      color: .orange,
      icon: .timer,
    ),
    // Rooibos
    Preset(
      key: AppString.tea_name_rooibos,
      brewTime: 180,
      brewTempDegreesC: boilDegreesC,
      brewTempDegreesF: boilDegreesF,
      brewRatioG: BrewRatio(
        ratioNumerator: 6,
        ratioDenominator: 250,
        metricNumerator: true,
        metricDenominator: true,
      ),
      brewRatioTsp: BrewRatio(
        ratioNumerator: 2,
        ratioDenominator: 8,
        metricNumerator: false,
        metricDenominator: false,
      ),
      color: .orange,
      icon: .timer,
    ),
    // Oolong
    Preset(
      key: AppString.tea_name_oolong,
      brewTime: 240,
      brewTempDegreesC: boilDegreesC,
      brewTempDegreesF: boilDegreesF,
      brewRatioG: BrewRatio(
        ratioNumerator: 4.5,
        ratioDenominator: 250,
        metricNumerator: true,
        metricDenominator: true,
      ),
      brewRatioTsp: BrewRatio(
        ratioNumerator: 1.5,
        ratioDenominator: 8,
        metricNumerator: false,
        metricDenominator: false,
      ),
      color: .brown,
      icon: .timer,
    ),
    // Pu'er
    Preset(
      key: AppString.tea_name_puer,
      brewTime: 270,
      brewTempDegreesC: 95,
      brewTempDegreesF: 200,
      brewRatioG: BrewRatio(
        ratioNumerator: 4.5,
        ratioDenominator: 250,
        metricNumerator: true,
        metricDenominator: true,
      ),
      brewRatioTsp: BrewRatio(
        ratioNumerator: 1.5,
        ratioDenominator: 8,
        metricNumerator: false,
        metricDenominator: false,
      ),
      color: .brown,
      icon: .timer,
    ),
    // Cold brew tea
    Preset(
      key: AppString.tea_name_cold_brew,
      brewTime: 43200,
      brewTempDegreesC: roomTemp,
      brewTempDegreesF: roomTemp,
      brewRatioG: BrewRatio(
        ratioNumerator: 3,
        ratioDenominator: 250,
        metricNumerator: true,
        metricDenominator: true,
      ),
      brewRatioTsp: BrewRatio(
        ratioNumerator: 1,
        ratioDenominator: 8,
        metricNumerator: false,
        metricDenominator: false,
      ),
      color: .blue,
      icon: .timer,
    ),
  ];

  // Get preset from key
  static Preset getPreset(AppString key) {
    return presetList.firstWhere(
      (preset) => preset.key == key,
      orElse: () => presetList[0],
    );
  }
}
