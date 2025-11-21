/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    teacup.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2025 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa teacup graphic

import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/data/prefs.dart';
import 'package:cuppa_mobile/data/provider.dart';
import 'package:cuppa_mobile/data/tea_timer.dart';

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Teacup with simple animations while a timer is active
Widget teacup() {
  return Selector<AppProvider, CupStyle>(
    selector: (_, provider) => provider.cupStyle,
    builder: (context, cupStyle, child) => Stack(
      children: [
        // Teacup image
        cupStyle.image,
        // Animate while timing
        Consumer<AppProvider>(
          builder: (context, provider, child) => Visibility(
            visible: activeTimerCount > 0,
            child: Stack(
              children: [
                // Gradually darken the tea in the cup
                Opacity(
                  opacity: min(timer1.timerPercent, timer2.timerPercent),
                  child: Image.asset(
                    cupImageTea,
                    fit: .fitWidth,
                    gaplessPlayback: true,
                  ),
                ),
                // Put a teabag in the cup
                Image.asset(cupImageBag, fit: .fitWidth, gaplessPlayback: true),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
