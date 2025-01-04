/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    padding.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2025 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa padding, margins, and spacing

import 'package:flutter/material.dart';

// Row and column spacing
const double smallSpacing = 8;
const double largeSpacing = 14;

// General use padding
const EdgeInsetsGeometry noPadding = EdgeInsets.zero;
const EdgeInsetsGeometry smallDefaultPadding = EdgeInsets.all(4);
const EdgeInsetsGeometry largeDefaultPadding = EdgeInsets.all(8);
const EdgeInsetsGeometry rowPadding = EdgeInsets.symmetric(
  vertical: 0,
  horizontal: 4,
);
const EdgeInsetsGeometry columnPadding = EdgeInsets.only(bottom: 8);

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
const EdgeInsetsGeometry buttonRowPadding = EdgeInsets.symmetric(
  vertical: 0,
  horizontal: 6,
);
const EdgeInsetsGeometry buttonColumnPadding = EdgeInsets.symmetric(
  vertical: 6,
  horizontal: 0,
);
const EdgeInsetsGeometry bottomSliverPadding =
    EdgeInsets.fromLTRB(12, 6, 12, 12);
