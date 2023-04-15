/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    text_styles.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2023 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa text styles

import 'package:flutter/material.dart';

const Color textColorLink = Colors.blue;

const TextStyle textStyleHeader = TextStyle(
  fontSize: 18.0,
  fontWeight: FontWeight.bold,
);

const TextStyle textStyleTitle = TextStyle(
  fontSize: 16.0,
);

const TextStyle textStyleSubtitle = TextStyle(
  fontSize: 14.0,
  fontWeight: FontWeight.normal,
);

const TextStyle textStyleFooter = TextStyle(
  fontSize: 12.0,
);

const TextStyle textStyleFooterLink = TextStyle(
  fontSize: 12.0,
  color: textColorLink,
  decoration: TextDecoration.underline,
  decorationColor: textColorLink,
);

const TextStyle textStyleButton = TextStyle(
  fontSize: 15.0,
  fontWeight: FontWeight.bold,
);

const TextStyle textStyleButtonSecondary = TextStyle(
  fontSize: 13.0,
  fontWeight: FontWeight.bold,
);

const TextStyle textStyleSetting = TextStyle(
  fontSize: 18.0,
  fontWeight: FontWeight.bold,
);

const TextStyle textStyleSettingSeconday = TextStyle(
  fontSize: 18.0,
);

const TextStyle textStyleTutorial = TextStyle(
  fontSize: 16.0,
);

const TextStyle textStyleTutorialTitle = TextStyle(
  fontSize: 16.0,
  fontWeight: FontWeight.bold,
);
