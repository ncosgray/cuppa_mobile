/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    tea.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2025 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa data
// - Tea definition class

import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/common/helpers.dart';
import 'package:cuppa_mobile/data/brew_ratio.dart';
import 'package:cuppa_mobile/data/prefs.dart';

import 'dart:io' show Platform;
import 'package:flutter/material.dart';

// Tea definition
class Tea {
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
    this.id = id ?? Prefs.nextTeaID++;
    // Prefer TeaColor or lookup from value if color not given
    this.color =
        color ??
        TeaColor.values.firstWhere(
          (color) => color.value == colorValue,
          orElse: () => TeaColor.values[0],
        );
    // Prefer TeaIcon or lookup from value if icon not given
    this.icon =
        icon ??
        TeaIcon.values.firstWhere(
          (icon) => icon.value == iconValue,
          orElse: () => TeaIcon.values[0],
        );
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
      colorShade:
          tryCast<int>(json[jsonKeyColorShadeRed]) != null &&
              tryCast<int>(json[jsonKeyColorShadeGreen]) != null &&
              tryCast<int>(json[jsonKeyColorShadeBlue]) != null
          ? Color.fromRGBO(
              json[jsonKeyColorShadeRed],
              json[jsonKeyColorShadeGreen],
              json[jsonKeyColorShadeBlue],
              1,
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
      jsonKeyColorShadeRed: convertRGBToInt(colorShade?.r),
      jsonKeyColorShadeGreen: convertRGBToInt(colorShade?.g),
      jsonKeyColorShadeBlue: convertRGBToInt(colorShade?.b),
      jsonKeyIcon: icon.value,
      jsonKeyIsFavorite: isFavorite,
      jsonKeyIsActive: isActive,
      jsonKeyIsSilent: isSilent,
      jsonKeyTimerEndTime: timerEndTime,
      jsonKeyTimerNotifyID: timerNotifyID,
    };
  }

  // Fields
  late int id;
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
    int secs = DateTime.fromMillisecondsSinceEpoch(
      timerEndTime,
    ).difference(DateTime.now()).inSeconds;
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
  String get shortcutIcon {
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
}

// Tea colors
enum TeaColor {
  red(1, Color.fromARGB(255, 229, 57, 53)), // Colors.red.shade600
  pink(7, Color.fromARGB(255, 236, 64, 122)), // Colors.pink.shade400
  orange(2, Color.fromARGB(255, 255, 152, 0)), // Colors.orange.shade500
  amber(8, Color.fromARGB(255, 255, 193, 7)), // Colors.amber.shade500
  green(3, Color.fromARGB(255, 76, 175, 80)), // Colors.green.shade500
  teal(9, Color.fromARGB(255, 0, 150, 136)), // Colors.teal.shade500
  blue(4, Color.fromARGB(255, 30, 136, 229)), // Colors.blue.shade600
  cyan(10, Color.fromARGB(255, 0, 188, 212)), // Colors.cyan.shade500
  purple(5, Color.fromARGB(255, 171, 71, 188)), // Colors.purple.shade400
  lavender(11, Color.fromARGB(255, 126, 87, 194)), // Colors.deepPurple.shade400
  black(0, Color.fromARGB(255, 117, 117, 117)), // Colors.grey.shade600
  brown(6, Color.fromARGB(255, 141, 110, 99)); // Colors.brown.shade400

  const TeaColor(this.value, this.color);

  final int value;
  final Color color;

  // Material color map
  Color getColor() => color;
}

// Tea icons
enum TeaIcon {
  timer(0, Icons.timer_outlined),
  cup(1, Icons.local_cafe_outlined),
  flower(2, Icons.local_florist_outlined);

  const TeaIcon(this.value, this.icon);

  final int value;
  final IconData icon;

  // Material icon map
  IconData getIcon() => icon;
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
