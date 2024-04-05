/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    teacup.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2024 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa teacup graphic

import 'package:cuppa_mobile/common/constants.dart';
import 'package:cuppa_mobile/data/provider.dart';
import 'package:cuppa_mobile/data/tea_timer.dart';

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Teacup with simple animations while a timer is active
Widget teacup() {
  return Selector<AppProvider, bool>(
    selector: (_, provider) => provider.appTheme.blackTheme,
    builder: (context, blackTheme, child) => Stack(
      children: [
        // Border color adjusted for theme darkness
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            blackTheme ? const Color(0xff323232) : Colors.black,
            BlendMode.srcIn,
          ),
          child: Image.asset(
            cupImageBorder,
            fit: BoxFit.fitWidth,
            gaplessPlayback: true,
          ),
        ),
        // Teacup image
        Image.asset(
          cupImageDefault,
          fit: BoxFit.fitWidth,
          gaplessPlayback: true,
        ),
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
                    fit: BoxFit.fitWidth,
                    gaplessPlayback: true,
                  ),
                ),
                // Put a teabag in the cup
                Image.asset(
                  cupImageBag,
                  fit: BoxFit.fitWidth,
                  gaplessPlayback: true,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
