/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    tea.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2023 Nathan Cosgray. All rights reserved.

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
  late TeaIcon icon;
  late bool isFavorite;
  late bool isActive;
  late int timerEndTime;
  int? timerNotifyID;

  // Constructor
  Tea(
      {required String name,
      required int brewTime,
      required int brewTemp,
      TeaColor? color,
      int colorValue = 0,
      TeaIcon? icon,
      int iconValue = 0,
      required bool isFavorite,
      required bool isActive,
      int timerEndTime = 0,
      int? timerNotifyID}) {
    this.id = UniqueKey();
    this.name = name;
    this.brewTime = brewTime;
    this.brewTemp = brewTemp;
    // Prefer TeaColor or lookup from value if color not given
    this.color = color ?? TeaColor.values[colorValue];
    // Prefer TeaIcon or lookup from value if icon not given
    this.icon = icon ?? TeaIcon.values[iconValue];
    this.isFavorite = isFavorite;
    this.isActive = isActive;
    this.timerEndTime = timerEndTime;
    this.timerNotifyID = timerNotifyID;
  }

  // Activate brew timer
  void activate(int notifyID) {
    this.isActive = true;
    this.timerEndTime = DateTime.now()
        .add(Duration(seconds: this.brewTime + 1))
        .millisecondsSinceEpoch;
    this.timerNotifyID = notifyID;
  }

  // Deactivate brew timer
  void deactivate() {
    this.isActive = false;
    this.timerEndTime = 0;
    this.timerNotifyID = null;
  }

  // Get brew time remaining
  int get brewTimeRemaining {
    int secs = DateTime.fromMillisecondsSinceEpoch(timerEndTime)
        .difference(DateTime.now())
        .inSeconds;
    return secs < 0 ? 0 : secs;
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

  // Icon getter
  IconData get teaIcon {
    return this.icon.getIcon();
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

  // Quick action shortcut icons based on color and tea icon
  get shortcutIcon {
    if (appPlatform == TargetPlatform.iOS) {
      switch (this.icon) {
        case TeaIcon.cup:
          return shortcutIconIOSCup;
        case TeaIcon.flower:
          return shortcutIconIOSFlower;
        default:
          return shortcutIconIOS;
      }
    } else {
      switch (this.color) {
        case TeaColor.red:
          {
            switch (this.icon) {
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
            switch (this.icon) {
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
            switch (this.icon) {
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
            switch (this.icon) {
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
            switch (this.icon) {
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
            switch (this.icon) {
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
            switch (this.icon) {
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
            switch (this.icon) {
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
            switch (this.icon) {
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
            switch (this.icon) {
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
            switch (this.icon) {
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
            switch (this.icon) {
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
      name: json[jsonKeyName] ?? '',
      brewTime: json[jsonKeyBrewTime] ?? 0,
      brewTemp: json[jsonKeyBrewTemp] ?? 0,
      colorValue: json[jsonKeyColor] ?? 0,
      iconValue: json[jsonKeyIcon] ?? 0,
      isFavorite: json[jsonKeyIsFavorite] ?? false,
      isActive: json[jsonKeyIsActive] ?? false,
      timerEndTime: json[jsonKeyTimerEndTime] ?? 0,
      timerNotifyID: json[jsonKeyTimerNotifyID],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      jsonKeyName: this.name,
      jsonKeyBrewTime: this.brewTime,
      jsonKeyBrewTemp: this.brewTemp,
      jsonKeyColor: this.color.value,
      jsonKeyIcon: this.icon.value,
      jsonKeyIsFavorite: this.isFavorite,
      jsonKeyIsActive: this.isActive,
      jsonKeyTimerEndTime: this.timerEndTime,
      jsonKeyTimerNotifyID: this.timerNotifyID,
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
        return Colors.red.shade600;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.green;
      case 4:
        return Colors.blue;
      case 5:
        return Colors.purple.shade400;
      case 6:
        return Colors.brown.shade400;
      case 7:
        return Colors.pink.shade200;
      case 8:
        return Colors.amber;
      case 9:
        return Colors.teal;
      case 10:
        return Colors.cyan.shade400;
      case 11:
        return Colors.deepPurple.shade200;
      default:
        // "Black" substitutes appropriate color for current theme
        return Theme.of(context).brightness == Brightness.dark
            ? Colors.grey
            : Colors.black54;
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
