/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    mini_tea_button.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2025 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa mini tea button widget

import 'package:cuppa_mobile/common/colors.dart';
import 'package:cuppa_mobile/common/padding.dart';
import 'package:cuppa_mobile/common/themes.dart';

import 'package:flutter/material.dart';

// Preview of a tea button with color and theme
Widget miniTeaButton({
  required Color? color,
  required IconData icon,
  bool isActive = false,
  bool darkTheme = false,
}) {
  return Theme(
    data: darkTheme ? darkThemeData : lightThemeData,
    child: Card(
      elevation: 1,
      margin: noPadding,
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(color: isActive ? color : null),
        child: Container(
          margin: largeDefaultPadding,
          child: Icon(
            icon,
            color: isActive ? timerActiveColor : color,
            size: 28,
          ),
        ),
      ),
    ),
  );
}
