/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    page_header.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2025 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa page header widget

import 'package:cuppa_mobile/common/padding.dart';
import 'package:cuppa_mobile/common/text_styles.dart';

import 'package:flutter/material.dart';

// Sliver app bar page header
Widget pageHeader(
  BuildContext context, {
  Widget? leading,
  required String title,
  List<Widget>? actions,
}) {
  return SliverAppBar(
    elevation: 1,
    pinned: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
    shadowColor: Theme.of(context).shadowColor,
    automaticallyImplyLeading: false,
    titleSpacing: 0,
    leading: leading,
    title: Container(
      margin: headerPadding,
      alignment: Alignment.centerLeft,
      child: FittedBox(
        child: Text(
          title,
          style: textStyleHeader.copyWith(
            color: Theme.of(context).textTheme.bodyLarge!.color!,
          ),
        ),
      ),
    ),
    actions: actions,
  );
}
