/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    tea.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2024 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa data
// - Tea definition class

import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/common/globals.dart';
import 'package:cuppa_mobile/common/helpers.dart';
import 'package:cuppa_mobile/data/brew_ratio.dart';

import 'dart:io' show Platform;
import 'package:flutter/material.dart';

// Tea definition
class Tea {
  // ID
  late int id;

  // Fields
  late String name;
  late int brewTime;
  late int brewTemp;
  late BrewRatio brewRatio;
  late TeaColor color;
  Color? colorShade;
  late TeaIcon icon;
  late bool isFavorite;
  late bool isActive;
  late bool isSilent;
  late int timerEndTime;
  int? timerNotifyID;

  // Constructor
  Tea({
    int? id,
    required this.name,
    required this.brewTime,
    required this.brewTemp,
    required this.brewRatio,
    TeaColor? color,
    int colorValue = defaultTeaColorValue,
    this.colorShade,
    TeaIcon? icon,
    int iconValue = defaultTeaIconValue,
    required this.isFavorite,
    required this.isActive,
    this.isSilent = false,
    this.timerEndTime = 0,
    this.timerNotifyID,
  }) {
    // Assign next tea ID if not given
    this.id = id ?? nextTeaID++;
    // Prefer TeaColor or lookup from value if color not given
    this.color = color ??
        TeaColor.values.firstWhere(
          (color) => color.value == colorValue,
          orElse: () => TeaColor.values[0],
        );
    // Prefer TeaIcon or lookup from value if icon not given
    this.icon = icon ??
        TeaIcon.values.firstWhere(
          (icon) => icon.value == iconValue,
          orElse: () => TeaIcon.values[0],
        );
  }

  // Activate brew timer
  void activate(int notifyID, bool silentDefault) {
    isActive = true;
    isSilent = silentDefault;
    timerEndTime = DateTime.now()
        .add(Duration(seconds: brewTime + 1))
        .millisecondsSinceEpoch;
    timerNotifyID = notifyID;
  }

  // Deactivate brew timer
  void deactivate() {
    isActive = false;
    isSilent = false;
    timerEndTime = 0;
    timerNotifyID = null;
  }

  // Adjust brew time remaining
  void adjustBrewTimeRemaining(int ms) {
    timerEndTime += ms;
  }

  // Get brew time remaining
  int get brewTimeRemaining {
    int secs = DateTime.fromMillisecondsSinceEpoch(timerEndTime)
        .difference(DateTime.now())
        .inSeconds;
    return secs < 0 ? 0 : secs;
  }

  // Tea display getters
  String get buttonName {
    return name.toUpperCase();
  }

  String getTempDisplay({bool? useCelsius}) {
    return formatTemp(brewTemp, useCelsius: useCelsius);
  }

  // Color getter
  Color getColor() {
    return colorShade ?? color.getColor();
  }

  // Icon getter
  IconData get teaIcon {
    return icon.getIcon();
  }

  // Brew time getters
  int get brewTimeSeconds {
    return brewTime - (brewTimeMinutes * 60);
  }

  int get brewTimeMinutes {
    return (brewTime / 60).floor() - (brewTimeHours * 60);
  }

  int get brewTimeHours {
    return (brewTime / 3600).floor();
  }

  // Brew time setters
  set brewTimeSeconds(int newSecs) {
    brewTime = (brewTimeMinutes * 60) + newSecs;
  }

  set brewTimeMinutes(int newMins) {
    brewTime = (newMins * 60) + brewTimeSeconds;
  }

  set brewTimeHours(int newHrs) {
    brewTime = (newHrs * 3600) + brewTimeMinutes;
  }

  // Quick action shortcut icons based on color and tea icon
  get shortcutIcon {
    if (Platform.isIOS) {
      switch (icon) {
        case TeaIcon.cup:
          return shortcutIconIOSCup;
        case TeaIcon.flower:
          return shortcutIconIOSFlower;
        default:
          return shortcutIconIOS;
      }
    } else {
      switch (color) {
        case TeaColor.red:
          {
            switch (icon) {
              case TeaIcon.cup:
                return shortcutIconCupRed;
              case TeaIcon.flower:
                return shortcutIconFlowerRed;
              default:
                return shortcutIconRed;
            }
          }
        case TeaColor.orange:
          {
            switch (icon) {
              case TeaIcon.cup:
                return shortcutIconCupOrange;
              case TeaIcon.flower:
                return shortcutIconFlowerOrange;
              default:
                return shortcutIconOrange;
            }
          }
        case TeaColor.green:
          {
            switch (icon) {
              case TeaIcon.cup:
                return shortcutIconCupGreen;
              case TeaIcon.flower:
                return shortcutIconFlowerGreen;
              default:
                return shortcutIconGreen;
            }
          }
        case TeaColor.blue:
          {
            switch (icon) {
              case TeaIcon.cup:
                return shortcutIconCupBlue;
              case TeaIcon.flower:
                return shortcutIconFlowerBlue;
              default:
                return shortcutIconBlue;
            }
          }
        case TeaColor.purple:
          {
            switch (icon) {
              case TeaIcon.cup:
                return shortcutIconCupPurple;
              case TeaIcon.flower:
                return shortcutIconFlowerPurple;
              default:
                return shortcutIconPurple;
            }
          }
        case TeaColor.brown:
          {
            switch (icon) {
              case TeaIcon.cup:
                return shortcutIconCupBrown;
              case TeaIcon.flower:
                return shortcutIconFlowerBrown;
              default:
                return shortcutIconBrown;
            }
          }
        case TeaColor.pink:
          {
            switch (icon) {
              case TeaIcon.cup:
                return shortcutIconCupPink;
              case TeaIcon.flower:
                return shortcutIconFlowerPink;
              default:
                return shortcutIconPink;
            }
          }
        case TeaColor.amber:
          {
            switch (icon) {
              case TeaIcon.cup:
                return shortcutIconCupAmber;
              case TeaIcon.flower:
                return shortcutIconFlowerAmber;
              default:
                return shortcutIconAmber;
            }
          }
        case TeaColor.teal:
          {
            switch (icon) {
              case TeaIcon.cup:
                return shortcutIconCupTeal;
              case TeaIcon.flower:
                return shortcutIconFlowerTeal;
              default:
                return shortcutIconTeal;
            }
          }
        case TeaColor.cyan:
          {
            switch (icon) {
              case TeaIcon.cup:
                return shortcutIconCupCyan;
              case TeaIcon.flower:
                return shortcutIconFlowerCyan;
              default:
                return shortcutIconCyan;
            }
          }
        case TeaColor.lavender:
          {
            switch (icon) {
              case TeaIcon.cup:
                return shortcutIconCupLavender;
              case TeaIcon.flower:
                return shortcutIconFlowerLavender;
              default:
                return shortcutIconLavender;
            }
          }
        default:
          {
            switch (icon) {
              case TeaIcon.cup:
                return shortcutIconCupBlack;
              case TeaIcon.flower:
                return shortcutIconFlowerBlack;
              default:
                return shortcutIconBlack;
            }
          }
      }
    }
  }

  // Factories
  factory Tea.fromJson(Map<String, dynamic> json) {
    return Tea(
      id: tryCast<int>(json[jsonKeyID]),
      name: tryCast<String>(json[jsonKeyName]) ?? unknownString,
      brewTime: tryCast<int>(json[jsonKeyBrewTime]) ?? defaultBrewTime,
      brewTemp: tryCast<int>(json[jsonKeyBrewTemp]) ?? boilDegreesC,
      brewRatio: json[jsonKeyBrewRatio] != null
          ? BrewRatio.fromJson(json[jsonKeyBrewRatio])
          : BrewRatio(),
      colorValue: tryCast<int>(json[jsonKeyColor]) ?? defaultTeaColorValue,
      colorShade: tryCast<int>(json[jsonKeyColorShadeRed]) != null &&
              tryCast<int>(json[jsonKeyColorShadeGreen]) != null &&
              tryCast<int>(json[jsonKeyColorShadeBlue]) != null
          ? Color.fromRGBO(
              json[jsonKeyColorShadeRed],
              json[jsonKeyColorShadeGreen],
              json[jsonKeyColorShadeBlue],
              1.0,
            )
          : null,
      iconValue: tryCast<int>(json[jsonKeyIcon]) ?? defaultTeaIconValue,
      isFavorite: tryCast<bool>(json[jsonKeyIsFavorite]) ?? false,
      isActive: tryCast<bool>(json[jsonKeyIsActive]) ?? false,
      isSilent: tryCast<bool>(json[jsonKeyIsSilent]) ?? false,
      timerEndTime: tryCast<int>(json[jsonKeyTimerEndTime]) ?? 0,
      timerNotifyID: tryCast<int>(json[jsonKeyTimerNotifyID]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      jsonKeyID: id,
      jsonKeyName: name,
      jsonKeyBrewTime: brewTime,
      jsonKeyBrewTemp: brewTemp,
      jsonKeyBrewRatio: brewRatio,
      jsonKeyColor: color.value,
      jsonKeyColorShadeRed: colorShade?.red,
      jsonKeyColorShadeGreen: colorShade?.green,
      jsonKeyColorShadeBlue: colorShade?.blue,
      jsonKeyIcon: icon.value,
      jsonKeyIsFavorite: isFavorite,
      jsonKeyIsActive: isActive,
      jsonKeyIsSilent: isSilent,
      jsonKeyTimerEndTime: timerEndTime,
      jsonKeyTimerNotifyID: timerNotifyID,
    };
  }
}

// Tea colors
enum TeaColor {
  red(1),
  pink(7),
  orange(2),
  amber(8),
  green(3),
  teal(9),
  blue(4),
  cyan(10),
  purple(5),
  lavender(11),
  black(0),
  brown(6);

  final int value;

  const TeaColor(this.value);

  // Material color map
  Color getColor() {
    switch (value) {
      case 1:
        return Colors.red.shade600;
      case 2:
        return Colors.orange.shade500;
      case 3:
        return Colors.green.shade500;
      case 4:
        return Colors.blue.shade600;
      case 5:
        return Colors.purple.shade400;
      case 6:
        return Colors.brown.shade400;
      case 7:
        return Colors.pink.shade400;
      case 8:
        return Colors.amber.shade500;
      case 9:
        return Colors.teal.shade500;
      case 10:
        return Colors.cyan.shade500;
      case 11:
        return Colors.deepPurple.shade400;
      default:
        return Colors.grey.shade600;
    }
  }
}

// Tea icons
enum TeaIcon {
  timer(0),
  cup(1),
  flower(2);

  final int value;

  const TeaIcon(this.value);

  // Material icon map
  IconData getIcon() {
    switch (value) {
      case 1:
        return Icons.local_cafe_outlined;
      case 2:
        return Icons.local_florist_outlined;
      default:
        return Icons.timer_outlined;
    }
  }
}

// Dummy tea for prototype items
final Tea dummyTea = Tea(
  name: unknownString * teaNameMaxLength,
  brewTime: defaultBrewTime,
  brewTemp: boilDegreesC,
  brewRatio: BrewRatio(),
  isFavorite: false,
  isActive: false,
);
