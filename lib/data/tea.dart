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

import 'package:cuppa_mobile/helpers.dart';
import 'package:cuppa_mobile/data/prefs.dart';

import 'package:flutter/material.dart';

// Tea definition
class Tea {
  // ID
  late UniqueKey id;

  // Fields
  late String name;
  late int brewTime;
  late int brewTemp;
  late int color;
  late bool isFavorite;
  late bool isActive;

  // Constructor
  Tea(
      {required String name,
      required int brewTime,
      required int brewTemp,
      required int color,
      required bool isFavorite,
      required bool isActive}) {
    id = UniqueKey();
    this.name = name;
    this.brewTime = brewTime;
    this.brewTemp = brewTemp;
    this.color = color;
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
    return Prefs.themeColor(this.color, context);
  }

  // Shortcut icon name based on color
  get shortcutIcon {
    return Prefs.shortcutIcons[this.color];
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
        name: json['name'] ?? '',
        brewTime: json['brewTime'] ?? 0,
        brewTemp: json['brewTemp'] ?? 0,
        color: json['color'] ?? 0,
        isFavorite: json['isFavorite'] ?? false,
        isActive: json['isActive'] ?? false);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': this.name,
      'brewTime': this.brewTime,
      'brewTemp': this.brewTemp,
      'color': this.color,
      'isFavorite': this.isFavorite,
      'isActive': this.isActive,
    };
  }

  // Overrides for comparisons
  @override
  bool operator ==(otherTea) {
    return (otherTea is Tea) &&
        otherTea.name == this.name &&
        otherTea.brewTime == this.brewTime &&
        otherTea.brewTemp == this.brewTemp &&
        otherTea.color == this.color &&
        otherTea.isFavorite == this.isFavorite &&
        otherTea.isActive == this.isActive;
  }

  @override
  int get hashCode =>
      this.name.hashCode ^
      this.brewTime.hashCode ^
      this.brewTemp.hashCode ^
      this.color.hashCode ^
      this.isFavorite.hashCode ^
      this.isActive.hashCode;
}
