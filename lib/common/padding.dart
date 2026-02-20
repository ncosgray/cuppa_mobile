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
const double xsmallSpacing = 4;
const double smallSpacing = 8;
const double largeSpacing = 14;

// General use padding
const EdgeInsetsGeometry noPadding = .zero;
const EdgeInsetsGeometry smallDefaultPadding = .all(4);
const EdgeInsetsGeometry largeDefaultPadding = .all(8);
const EdgeInsetsGeometry rowPadding = .symmetric(vertical: 0, horizontal: 4);
const EdgeInsetsGeometry columnPadding = .only(bottom: 8);

// Element specific padding
const EdgeInsetsGeometry titlePadding = .symmetric(vertical: 0, horizontal: 12);
const EdgeInsetsGeometry headerPadding = .symmetric(
  vertical: 0,
  horizontal: 12,
);
const EdgeInsetsGeometry bodyPadding = .symmetric(vertical: 4, horizontal: 12);
const EdgeInsetsGeometry timerLayoutPadding = .fromLTRB(48, 28, 48, 12);
const EdgeInsetsGeometry timerPadding = .symmetric(vertical: 2, horizontal: 12);
const EdgeInsetsGeometry listTilePadding = .symmetric(
  vertical: 6,
  horizontal: 12,
);
const EdgeInsetsGeometry radioTilePadding = .symmetric(
  vertical: 0,
  horizontal: 6,
);
const EdgeInsetsGeometry buttonRowPadding = .symmetric(
  vertical: 0,
  horizontal: 6,
);
const EdgeInsetsGeometry buttonColumnPadding = .symmetric(
  vertical: 6,
  horizontal: 0,
);
const EdgeInsetsGeometry bottomSliverPadding = .fromLTRB(12, 6, 12, 12);
