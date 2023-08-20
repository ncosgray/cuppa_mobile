/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    presets.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2023 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa data
// - Preset tea types

import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/data/tea.dart';
import 'package:cuppa_mobile/helpers.dart';

import 'package:flutter/material.dart';

// Preset definition
class Preset {
  // Fields
  AppString key;
  int brewTime;
  int brewTempDegreesC;
  int brewTempDegreesF;
  TeaColor color;
  TeaIcon icon;
  bool isCustom;

  // Constructor
  Preset({
    required this.key,
    required this.brewTime,
    required this.brewTempDegreesC,
    required this.brewTempDegreesF,
    required this.color,
    required this.icon,
    this.isCustom = false,
  });

  // Localized tea name
  get localizedName {
    return this.key.translate();
  }

  // Color getter
  Color getThemeColor(context) {
    return this.color.getThemeColor(context);
  }

  // Icon getter
  IconData getIcon() {
    return this.icon.getIcon();
  }

  // Brew temp getter
  String tempDisplay(bool useCelsius) {
    return formatTemp(
      useCelsius ? this.brewTempDegreesC : this.brewTempDegreesF,
    );
  }

  // Create a new tea from this preset
  Tea createTea({required bool useCelsius, bool isFavorite = false}) {
    return Tea(
      name: this.localizedName,
      brewTime: this.brewTime,
      brewTemp: (useCelsius ? this.brewTempDegreesC : this.brewTempDegreesF),
      color: this.color,
      icon: this.icon,
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
      brewTime: 240,
      brewTempDegreesC: 100,
      brewTempDegreesF: 212,
      color: TeaColor.black,
      icon: TeaIcon.timer,
      isCustom: true,
    ),
    // Black tea
    Preset(
      key: AppString.tea_name_black,
      brewTime: 240,
      brewTempDegreesC: 100,
      brewTempDegreesF: 212,
      color: TeaColor.black,
      icon: TeaIcon.timer,
    ),
    // Assam
    Preset(
      key: AppString.tea_name_assam,
      brewTime: 210,
      brewTempDegreesC: 95,
      brewTempDegreesF: 200,
      color: TeaColor.black,
      icon: TeaIcon.timer,
    ),
    // Darjeeling
    Preset(
      key: AppString.tea_name_darjeeling,
      brewTime: 270,
      brewTempDegreesC: 95,
      brewTempDegreesF: 200,
      color: TeaColor.black,
      icon: TeaIcon.timer,
    ),
    // Green tea
    Preset(
      key: AppString.tea_name_green,
      brewTime: 150,
      brewTempDegreesC: 80,
      brewTempDegreesF: 180,
      color: TeaColor.green,
      icon: TeaIcon.timer,
    ),
    // White tea
    Preset(
      key: AppString.tea_name_white,
      brewTime: 300,
      brewTempDegreesC: 80,
      brewTempDegreesF: 180,
      color: TeaColor.green,
      icon: TeaIcon.timer,
    ),
    // Herbal tea
    Preset(
      key: AppString.tea_name_herbal,
      brewTime: 300,
      brewTempDegreesC: 100,
      brewTempDegreesF: 212,
      color: TeaColor.orange,
      icon: TeaIcon.timer,
    ),
    // Chamomile
    Preset(
      key: AppString.tea_name_chamomile,
      brewTime: 300,
      brewTempDegreesC: 100,
      brewTempDegreesF: 212,
      color: TeaColor.orange,
      icon: TeaIcon.timer,
    ),
    // Mint tea
    Preset(
      key: AppString.tea_name_mint,
      brewTime: 240,
      brewTempDegreesC: 100,
      brewTempDegreesF: 212,
      color: TeaColor.orange,
      icon: TeaIcon.timer,
    ),
    // Rooibos
    Preset(
      key: AppString.tea_name_rooibos,
      brewTime: 180,
      brewTempDegreesC: 100,
      brewTempDegreesF: 212,
      color: TeaColor.orange,
      icon: TeaIcon.timer,
    ),
    // Oolong
    Preset(
      key: AppString.tea_name_oolong,
      brewTime: 240,
      brewTempDegreesC: 100,
      brewTempDegreesF: 212,
      color: TeaColor.brown,
      icon: TeaIcon.timer,
    ),
    // Pu'er
    Preset(
      key: AppString.tea_name_puer,
      brewTime: 270,
      brewTempDegreesC: 95,
      brewTempDegreesF: 200,
      color: TeaColor.brown,
      icon: TeaIcon.timer,
    ),
    // Cold brew tea
    Preset(
      key: AppString.tea_name_cold_brew,
      brewTime: 43200,
      brewTempDegreesC: 20,
      brewTempDegreesF: 68,
      color: TeaColor.blue,
      icon: TeaIcon.timer,
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
