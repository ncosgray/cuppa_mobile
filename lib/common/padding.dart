/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    padding.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2023 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa padding, margins, and spacers

import 'package:flutter/material.dart';

// Spacer
const spacerWidget = SizedBox(
  width: 14.0,
  height: 14.0,
);

// General use padding
const EdgeInsetsGeometry noPadding = EdgeInsets.zero;
const EdgeInsetsGeometry smallDefaultPadding = EdgeInsets.all(4.0);
const EdgeInsetsGeometry largeDefaultPadding = EdgeInsets.all(8.0);

// Element specific padding
const EdgeInsetsGeometry headerPadding = EdgeInsets.symmetric(
  vertical: 0.0,
  horizontal: 12.0,
);
const EdgeInsetsGeometry bodyPadding = EdgeInsets.symmetric(
  vertical: 4.0,
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
