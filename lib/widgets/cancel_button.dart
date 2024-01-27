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
class CancelButton extends StatelessWidget {
  const CancelButton({
    super.key,
    this.active = false,
    required this.onPressed,
  });

  final bool active;
  final ValueChanged<bool> onPressed;

  void _handleTap() {
    onPressed(!active);
  }

  @override
  Widget build(BuildContext context) {
    // Button with "X" icon
    return InkWell(
      borderRadius: BorderRadius.circular(4.0),
      onTap: active ? _handleTap : null,
      child: Container(
        padding: smallDefaultPadding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            cancelIcon(color: Theme.of(context).colorScheme.error),
            smallSpacerWidget,
            Text(
              AppString.cancel_button.translate(),
              style: textStyleButtonSecondary.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
