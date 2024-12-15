/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    cancel_button.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2024 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa cancel timer button

import 'package:cuppa_mobile/common/icons.dart';
import 'package:cuppa_mobile/common/padding.dart';
import 'package:cuppa_mobile/common/text_styles.dart';
import 'package:cuppa_mobile/data/localization.dart';

import 'package:flutter/material.dart';

// Widget defining a cancel brewing button
Widget cancelButton({
  required Color color,
  required Function()? onPressed,
}) {
  // Button with "X" icon
  return InkWell(
    borderRadius: BorderRadius.circular(4),
    onTap: onPressed,
    child: Container(
      padding: smallDefaultPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: smallSpacing,
        children: [
          cancelIcon(color: color),
          Text(
            AppString.cancel_button.translate(),
            style: textStyleButtonSecondary.copyWith(color: color),
          ),
        ],
      ),
    ),
  );
}
