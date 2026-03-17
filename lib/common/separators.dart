/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    separators.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2026 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa separator builders

import 'package:flutter/material.dart';

// Select list separator
Widget separatorBuilder(BuildContext context, int index) {
  return listDivider;
}

// Placeholder list separator
Widget separatorDummy(BuildContext context, int index) {
  return Container();
}

// List divider
const Divider listDivider = Divider(thickness: 1, indent: 12, endIndent: 12);
