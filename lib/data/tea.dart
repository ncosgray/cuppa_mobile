/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    tea.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2022 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa data
// - Tea definition class

import 'package:cuppa_mobile/data/constants.dart';
import 'package:cuppa_mobile/data/globals.dart';
import 'package:cuppa_mobile/helpers.dart';

import 'package:flutter/material.dart';

// Tea definition
class Tea {
  // ID
  late UniqueKey id;

  // Fields
  late String name;
  late int brewTime;
  late int brewTemp;
  late TeaColor color;
  late bool isFavorite;
  late bool isActive;

  // Constructor
  Tea(
      {required String name,
      required int brewTime,
      required int brewTemp,
      TeaColor? color,
      int colorValue = 0,
      required bool isFavorite,
      required bool isActive}) {
    this.id = UniqueKey();
    this.name = name;
    this.brewTime = brewTime;
    this.brewTemp = brewTemp;
    // Prefer TeaColor or lookup from value if color not given
    this.color = color ?? TeaColor.values[colorValue];
    this.isFavorite = isFavorite;
    this.isActive = isActive;
  }

  // Tea display getters
  get buttonName {
    return this.name.toUpperCase();
  }

  get tempDisplay {
    return formatTemp(this.brewTemp);
  }

  // Color getter
  Color getThemeColor(context) {
    return this.color.getThemeColor(context);
  }

  // Shortcut icon name based on color
  get shortcutIcon {
    return this.color.shortcutIcon;
  }

  // Brew time getters
  int get brewTimeSeconds {
    return this.brewTime - (this.brewTimeMinutes * 60);
  }

  int get brewTimeMinutes {
    return (this.brewTime / 60).floor();
  }

  // Brew time setters
  set brewTimeSeconds(int newSecs) {
    this.brewTime = (this.brewTimeMinutes * 60) + newSecs;
  }

  set brewTimeMinutes(int newMins) {
    this.brewTime = (newMins * 60) + this.brewTimeSeconds;
  }

  // Factories
  factory Tea.fromJson(Map<String, dynamic> json) {
    return Tea(
        name: json[jsonKeyName] ?? '',
        brewTime: json[jsonKeyBrewTime] ?? 0,
        brewTemp: json[jsonKeyBrewTemp] ?? 0,
        colorValue: json[jsonKeyColor] ?? 0,
        isFavorite: json[jsonKeyIsFavorite] ?? false,
        isActive: json[jsonKeyIsActive] ?? false);
  }

  Map<String, dynamic> toJson() {
    return {
      jsonKeyName: this.name,
      jsonKeyBrewTime: this.brewTime,
      jsonKeyBrewTemp: this.brewTemp,
      jsonKeyColor: this.color.value,
      jsonKeyIsFavorite: this.isFavorite,
      jsonKeyIsActive: this.isActive,
    };
  }
}

// Tea colors
enum TeaColor {
  black(0),
  red(1),
  orange(2),
  green(3),
  blue(4),
  purple(5),
  brown(6),
  pink(7),
  amber(8),
  teal(9),
  cyan(10),
  lavender(11);

  final int value;

  const TeaColor(this.value);

  // Themed color map
  Color getThemeColor(context) {
    switch (value) {
      case 1:
        return Colors.red[600]!;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.green;
      case 4:
        return Colors.blue;
      case 5:
        return Colors.purple[400]!;
      case 6:
        return Colors.brown[400]!;
      case 7:
        return Colors.pink[200]!;
      case 8:
        return Colors.amber;
      case 9:
        return Colors.teal;
      case 10:
        return Colors.cyan[400]!;
      case 11:
        return Colors.deepPurple[200]!;
      default:
        // "Black" substitutes appropriate color for current theme
        return Theme.of(context).textTheme.button!.color!;
    }
  }

  // Quick action shortcut icons
  get shortcutIcon {
    if (appPlatform == TargetPlatform.iOS) {
      return shortcutIconIOS;
    } else {
      switch (value) {
        case 1:
          return shortcutIconRed;
        case 2:
          return shortcutIconOrange;
        case 3:
          return shortcutIconGreen;
        case 4:
          return shortcutIconBlue;
        case 5:
          return shortcutIconPurple;
        case 6:
          return shortcutIconBrown;
        case 7:
          return shortcutIconPink;
        case 8:
          return shortcutIconAmber;
        case 9:
          return shortcutIconTeal;
        case 10:
          return shortcutIconCyan;
        case 11:
          return shortcutIconLavender;
        default:
          return shortcutIconBlack;
      }
    }
  }
}
