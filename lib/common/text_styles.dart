/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    text_styles.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2025 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa text styles

import 'package:cuppa_mobile/common/colors.dart';

import 'package:flutter/material.dart';

const TextStyle textStyleNavBar = TextStyle(fontSize: 18);

const TextStyle textStyleHeader = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
);

const TextStyle textStyleTitle = TextStyle(fontSize: 16);

const TextStyle textStyleSubtitle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.normal,
);

const TextStyle textStyleFooter = TextStyle(fontSize: 12);

const TextStyle textStyleFooterLink = TextStyle(
  fontSize: 12,
  color: linkColor,
  decoration: TextDecoration.underline,
  decorationColor: linkColor,
);

const TextStyle textStyleButton = TextStyle(
  fontSize: 17,
  fontWeight: FontWeight.bold,
);

const TextStyle textStyleButtonSecondary = TextStyle(
  fontSize: 15,
  fontWeight: FontWeight.bold,
);

const TextStyle textStyleButtonTertiary = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.bold,
);

const TextStyle textStyleTimer = TextStyle(
  fontSize: 150,
  fontWeight: FontWeight.bold,
  color: timerForegroundColor,
  fontFeatures: [FontFeature.tabularFigures()],
);

const TextStyle textStyleTimerIncrement = TextStyle(
  fontSize: 16,
  color: timerForegroundColor,
);

const TextStyle textStyleSetting = TextStyle(
  fontSize: 17,
  fontWeight: FontWeight.bold,
);

const TextStyle textStyleSettingNumber = TextStyle(
  fontSize: 16,
  fontFeatures: [FontFeature.tabularFigures()],
);

const TextStyle textStyleSettingSecondary = TextStyle(fontSize: 15);

const TextStyle textStyleSettingTertiary = TextStyle(fontSize: 13);

const TextStyle textStyleTutorial = TextStyle(fontSize: 16);

const TextStyle textStyleTutorialTitle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.bold,
);

const TextStyle textStyleStat = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.bold,
);

const TextStyle textStyleStatLabel = TextStyle(fontSize: 16);
