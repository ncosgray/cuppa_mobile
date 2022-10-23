/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    cancel_button.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2022 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa cancel timer button

import 'package:cuppa_mobile/data/localization.dart';

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
        AppString.cancel_button.translate().toUpperCase(),
        style: TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.bold,
          color: active
              ? Colors.red[400]
              : Theme.of(context).textTheme.button!.color!,
        ),
      ),
      icon: Icon(Icons.cancel,
          color: active
              ? Colors.red[400]
              : Theme.of(context).textTheme.button!.color!,
          size: 16.0),
      onPressed: active ? _handleTap : null,
    );
  }
}
