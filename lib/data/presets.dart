/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    presets.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2022 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa data
// - Preset tea types

import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/data/tea.dart';

import 'package:flutter/material.dart';

// Preset definition
class Preset {
  // Fields
  AppString key;
  int brewTime;
  int brewTempDegreesC;
  int brewTempDegreesF;
  TeaColor color;
  bool isCustom;

  // Constructor
  Preset(
      {required this.key,
      required this.brewTime,
      required this.brewTempDegreesC,
      required this.brewTempDegreesF,
      required this.color,
      this.isCustom = false});

  // Localized tea name
  get localizedName {
    return this.key.translate();
  }

  // Color getter
  Color getThemeColor(context) {
    return this.color.getThemeColor(context);
  }

  // Create a new tea from this preset
  Tea createTea({required bool useCelsius, bool isFavorite = false}) {
    return Tea(
        name: this.localizedName,
        brewTime: this.brewTime,
        brewTemp: (useCelsius ? this.brewTempDegreesC : this.brewTempDegreesF),
        color: this.color,
        isFavorite: isFavorite,
        isActive: false);
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
        isCustom: true),
    // Black tea
    Preset(
        key: AppString.tea_name_black,
        brewTime: 240,
        brewTempDegreesC: 100,
        brewTempDegreesF: 212,
        color: TeaColor.black),
    // Assam
    Preset(
        key: AppString.tea_name_assam,
        brewTime: 210,
        brewTempDegreesC: 95,
        brewTempDegreesF: 200,
        color: TeaColor.black),
    // Darjeeling
    Preset(
        key: AppString.tea_name_darjeeling,
        brewTime: 270,
        brewTempDegreesC: 95,
        brewTempDegreesF: 200,
        color: TeaColor.black),
    // Green tea
    Preset(
        key: AppString.tea_name_green,
        brewTime: 150,
        brewTempDegreesC: 80,
        brewTempDegreesF: 180,
        color: TeaColor.green),
    // White tea
    Preset(
        key: AppString.tea_name_white,
        brewTime: 300,
        brewTempDegreesC: 80,
        brewTempDegreesF: 180,
        color: TeaColor.green),
    // Herbal tea
    Preset(
        key: AppString.tea_name_herbal,
        brewTime: 300,
        brewTempDegreesC: 100,
        brewTempDegreesF: 212,
        color: TeaColor.orange),
    // Chamomile
    Preset(
        key: AppString.tea_name_chamomile,
        brewTime: 300,
        brewTempDegreesC: 100,
        brewTempDegreesF: 212,
        color: TeaColor.orange),
    // Mint tea
    Preset(
        key: AppString.tea_name_mint,
        brewTime: 240,
        brewTempDegreesC: 100,
        brewTempDegreesF: 212,
        color: TeaColor.orange),
    // Rooibos
    Preset(
        key: AppString.tea_name_rooibos,
        brewTime: 180,
        brewTempDegreesC: 100,
        brewTempDegreesF: 212,
        color: TeaColor.orange),
    // Oolong
    Preset(
        key: AppString.tea_name_oolong,
        brewTime: 240,
        brewTempDegreesC: 100,
        brewTempDegreesF: 212,
        color: TeaColor.brown),
    // Pu'er
    Preset(
        key: AppString.tea_name_puer,
        brewTime: 270,
        brewTempDegreesC: 95,
        brewTempDegreesF: 200,
        color: TeaColor.brown),
  ];

  // Get preset from key
  static Preset getPreset(AppString key) {
    return presetList.firstWhere((preset) => preset.key == key,
        orElse: () => presetList[0]);
  }
}
