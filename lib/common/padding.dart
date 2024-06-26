/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    padding.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2024 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa padding, margins, and spacers

import 'package:flutter/material.dart';

// Spacers
const SizedBox spacerWidget = SizedBox(
  width: 14.0,
  height: 14.0,
);
const SizedBox smallSpacerWidget = SizedBox(
  width: 8.0,
  height: 8.0,
);

// General use padding
const EdgeInsetsGeometry noPadding = EdgeInsets.zero;
const EdgeInsetsGeometry smallDefaultPadding = EdgeInsets.all(4.0);
const EdgeInsetsGeometry largeDefaultPadding = EdgeInsets.all(8.0);

// Element specific padding
const EdgeInsetsGeometry titlePadding = EdgeInsets.symmetric(
  vertical: 0.0,
  horizontal: 12.0,
);
const EdgeInsetsGeometry headerPadding = EdgeInsets.symmetric(
  vertical: 0.0,
  horizontal: 12.0,
);
const EdgeInsetsGeometry bodyPadding = EdgeInsets.symmetric(
  vertical: 4.0,
  horizontal: 12.0,
);
const EdgeInsetsGeometry narrowTimerLayoutPadding = EdgeInsets.all(12.0);
const EdgeInsetsGeometry wideTimerLayoutPadding = EdgeInsets.symmetric(
  vertical: 12.0,
  horizontal: 48.0,
);
const EdgeInsetsGeometry timerPadding = EdgeInsets.symmetric(
  vertical: 2.0,
  horizontal: 12.0,
);
const EdgeInsetsGeometry listTilePadding = EdgeInsets.symmetric(
  vertical: 6.0,
  horizontal: 12.0,
);
const EdgeInsetsGeometry radioTilePadding = EdgeInsets.symmetric(
  vertical: 0.0,
  horizontal: 6.0,
);
const EdgeInsetsGeometry rowPadding = EdgeInsets.symmetric(
  vertical: 0.0,
  horizontal: 4.0,
);
