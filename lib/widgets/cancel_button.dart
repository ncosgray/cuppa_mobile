/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    cancel_button.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2023 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa cancel timer button

import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/widgets/text_styles.dart';

import 'package:flutter/material.dart';

// Widget defining a cancel brewing button
class CancelButton extends StatelessWidget {
  const CancelButton({Key? key, this.active = false, required this.onPressed})
      : super(key: key);

  final bool active;
  final ValueChanged<bool> onPressed;

  void _handleTap() {
    onPressed(!active);
  }

  @override
  Widget build(BuildContext context) {
    // Button with "X" icon
    return TextButton.icon(
      label: Text(
        AppString.cancel_button.translate(),
        style: TextStyle(
          color: active ? textColorWarn : Theme.of(context).disabledColor,
        ),
      ),
      icon: Icon(Icons.cancel,
          color: active ? textColorWarn : Theme.of(context).disabledColor,
          size: 14.0),
      onPressed: active ? _handleTap : null,
    );
  }
}
