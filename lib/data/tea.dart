/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    tea.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2026 Nathan Cosgray. All rights reserved.

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
    this.numInfusions = defaultNumInfusions,
    this.infusionInterval = defaultInfusionInterval,
    this.currentInfusion = 1,
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
      numInfusions:
          tryCast<int>(json[jsonKeyNumInfusions]) ?? defaultNumInfusions,
      infusionInterval:
          tryCast<int>(json[jsonKeyInfusionInterval]) ??
          defaultInfusionInterval,
      currentInfusion: tryCast<int>(json[jsonKeyCurrentInfusion]) ?? 1,
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
      jsonKeyNumInfusions: numInfusions,
      jsonKeyInfusionInterval: infusionInterval,
      jsonKeyCurrentInfusion: currentInfusion,
    };
  }

  // Fields
  late int id;
  String name;
  int brewTime;
  int brewTemp;
  BrewRatio brewRatio;
  late TeaColor color;
  Color? colorShade;
  late TeaIcon icon;
  bool isFavorite;
  bool isActive;
  bool isSilent;
  int timerEndTime;
  int? timerNotifyID;
  int numInfusions;
  int infusionInterval;
  int currentInfusion;

  // Activate brew timer
  void activate(int notifyID, bool silentDefault) {
    isActive = true;
    isSilent = silentDefault;
    timerEndTime = DateTime.now()
        .add(Duration(seconds: currentBrewTime + 1))
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

  // Multiple infusions getters
  bool get multipleInfusions => numInfusions >= numInfusionsMin;

  // Brew time for the current infusion
  int get currentBrewTime {
    if (!multipleInfusions) return brewTime;
    final int time = brewTime + (currentInfusion - 1) * infusionInterval;
    // Minimum 1 second
    return time < 1 ? 1 : time;
  }

  // Advance to the next infusion, wrapping around after the last
  void advanceInfusion() {
    currentInfusion = currentInfusion >= numInfusions ? 1 : currentInfusion + 1;
  }

  // Brew time getters
  int get brewTimeSeconds {
    return brewTime % 60;
  }

  int get brewTimeMinutes {
    return (brewTime % 3600) ~/ 60;
  }

  int get brewTimeHours {
    return brewTime ~/ 3600;
  }

  // Brew time setters
  set brewTimeSeconds(int newSecs) {
    brewTime = (brewTimeHours * 3600) + (brewTimeMinutes * 60) + newSecs;
  }

  set brewTimeMinutes(int newMins) {
    brewTime = (brewTimeHours * 3600) + (newMins * 60) + brewTimeSeconds;
  }

  set brewTimeHours(int newHrs) {
    brewTime = (newHrs * 3600) + (brewTimeMinutes * 60) + brewTimeSeconds;
  }

  // Quick action shortcut icons based on color and tea icon
  String get shortcutIcon {
    if (Platform.isIOS) {
      switch (icon) {
        case .cup:
          return shortcutIconIOSCup;
        case .flower:
          return shortcutIconIOSFlower;
        case .timer:
          return shortcutIconIOS;
      }
    }

    // Android drawable names are derived from the TeaIcon and TeaColor enum
    // names, e.g. ic_shortcut_cup_red; keep drawables in sync with the enums
    return icon == TeaIcon.timer
        ? '$shortcutIconPrefix${color.name}'
        : '$shortcutIconPrefix${icon.name}_${color.name}';
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

// Quick timer tea
Tea quickTimerTea(String name, int brewTime, {bool isActive = false}) => Tea(
  id: quickTimerTeaID,
  name: name,
  brewTime: brewTime,
  brewTemp: boilDegreesC,
  brewRatio: BrewRatio(),
  color: .black,
  isFavorite: false,
  isActive: isActive,
);

// Dummy tea for prototype items
final Tea dummyTea = Tea(
  id: dummyTeaID,
  name: unknownString * teaNameMaxLength,
  brewTime: defaultBrewTime,
  brewTemp: boilDegreesC,
  brewRatio: BrewRatio(),
  isFavorite: false,
  isActive: false,
);
