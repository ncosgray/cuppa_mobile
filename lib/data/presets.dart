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
import 'package:cuppa_mobile/data/prefs.dart';
import 'package:cuppa_mobile/data/tea.dart';

import 'package:flutter/material.dart';

// Preset definition
class Preset {
  // Fields
  int brewTime;
  int brewTempDegreesC;
  int brewTempDegreesF;
  TeaColor color;
  bool isCustom;

  // Constructor
  Preset(
      {required this.brewTime,
      required this.brewTempDegreesC,
      required this.brewTempDegreesF,
      required this.color,
      this.isCustom = false});

  // Brew temperature based on unit preference
  get brewTemp {
    return (Prefs.useCelsius ? this.brewTempDegreesC : this.brewTempDegreesF);
  }

  // Color getter
  Color getThemeColor(context) {
    return this.color.getThemeColor(context);
  }
}

// Preset tea types
abstract class Presets {
  // Tea types
  static Map<String, Preset> presetList = {
    // Custom blank tea
    'new_tea_default_name': Preset(
        brewTime: 240,
        brewTempDegreesC: 100,
        brewTempDegreesF: 212,
        color: TeaColor.black,
        isCustom: true),
    // Black tea
    'tea_name_black': Preset(
        brewTime: 240,
        brewTempDegreesC: 100,
        brewTempDegreesF: 212,
        color: TeaColor.black),
    // Assam
    'tea_name_assam': Preset(
        brewTime: 210,
        brewTempDegreesC: 95,
        brewTempDegreesF: 200,
        color: TeaColor.black),
    // Darjeeling
    'tea_name_darjeeling': Preset(
        brewTime: 270,
        brewTempDegreesC: 95,
        brewTempDegreesF: 200,
        color: TeaColor.black),
    // Green tea
    'tea_name_green': Preset(
        brewTime: 150,
        brewTempDegreesC: 80,
        brewTempDegreesF: 180,
        color: TeaColor.green),
    // White tea
    'tea_name_white': Preset(
        brewTime: 300,
        brewTempDegreesC: 80,
        brewTempDegreesF: 180,
        color: TeaColor.green),
    // Herbal tea
    'tea_name_herbal': Preset(
        brewTime: 300,
        brewTempDegreesC: 100,
        brewTempDegreesF: 212,
        color: TeaColor.orange),
    // Chamomile
    'tea_name_chamomile': Preset(
        brewTime: 300,
        brewTempDegreesC: 100,
        brewTempDegreesF: 212,
        color: TeaColor.orange),
    // Mint tea
    'tea_name_mint': Preset(
        brewTime: 240,
        brewTempDegreesC: 100,
        brewTempDegreesF: 212,
        color: TeaColor.orange),
    // Rooibos
    'tea_name_rooibos': Preset(
        brewTime: 180,
        brewTempDegreesC: 100,
        brewTempDegreesF: 212,
        color: TeaColor.orange),
    // Oolong
    'tea_name_oolong': Preset(
        brewTime: 240,
        brewTempDegreesC: 100,
        brewTempDegreesF: 212,
        color: TeaColor.brown),
    // Pu'er
    'tea_name_puer': Preset(
        brewTime: 270,
        brewTempDegreesC: 95,
        brewTempDegreesF: 200,
        color: TeaColor.brown),
  };

  // Create a new tea from a preset tea type
  static Tea newTeaFromPreset({required String key, bool isFavorite = false}) {
    String teaName;

    if (presetList[key]!.isCustom) {
      // Choose a unique blank tea name for custom tea
      int nextNumber = 1;
      do {
        teaName = AppLocalizations.translate('new_tea_default_name') +
            ' ' +
            nextNumber.toString();
        nextNumber++;
      } while (Prefs.teaList.indexWhere((tea) => tea.name == teaName) >= 0);
    } else {
      // Get translated tea name
      teaName = AppLocalizations.translate(key);
    }

    return Tea(
        name: teaName,
        brewTime: presetList[key]!.brewTime,
        brewTemp: presetList[key]!.brewTemp,
        color: presetList[key]!.color,
        isFavorite: isFavorite,
        isActive: false);
  }
}
