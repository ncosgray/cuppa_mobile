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

// Spacing and spacers
const double smallSpacing = 8;
const double largeSpacing = 14;
const SizedBox spacerWidget = SizedBox(
  width: smallSpacing,
  height: smallSpacing,
);

// General use padding
const EdgeInsetsGeometry noPadding = EdgeInsets.zero;
const EdgeInsetsGeometry smallDefaultPadding = EdgeInsets.all(4);
const EdgeInsetsGeometry largeDefaultPadding = EdgeInsets.all(8);

// Element specific padding
const EdgeInsetsGeometry titlePadding = EdgeInsets.symmetric(
  vertical: 0,
  horizontal: 12,
);
const EdgeInsetsGeometry headerPadding = EdgeInsets.symmetric(
  vertical: 0,
  horizontal: 12,
);
const EdgeInsetsGeometry bodyPadding = EdgeInsets.symmetric(
  vertical: 4,
  horizontal: 12,
);
const EdgeInsetsGeometry narrowTimerLayoutPadding = EdgeInsets.all(12);
const EdgeInsetsGeometry wideTimerLayoutPadding = EdgeInsets.symmetric(
  vertical: 12,
  horizontal: 48,
);
const EdgeInsetsGeometry timerPadding = EdgeInsets.symmetric(
  vertical: 2,
  horizontal: 12,
);
const EdgeInsetsGeometry listTilePadding = EdgeInsets.symmetric(
  vertical: 6,
  horizontal: 12,
);
const EdgeInsetsGeometry radioTilePadding = EdgeInsets.symmetric(
  vertical: 0,
  horizontal: 6,
);
const EdgeInsetsGeometry rowPadding = EdgeInsets.symmetric(
  vertical: 0,
  horizontal: 4,
);
const EdgeInsetsGeometry bottomSliverPadding =
    EdgeInsets.fromLTRB(12, 6, 12, 12);
