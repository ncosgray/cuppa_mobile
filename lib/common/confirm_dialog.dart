/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    confirm_dialog.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2023 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Generic confirmation dialog

import 'package:cuppa_mobile/data/localization.dart';
import 'package:cuppa_mobile/widgets/platform_adaptive.dart';

import 'package:flutter/material.dart';

Future confirmDialog({
  required BuildContext context,
  required Widget body,
  Widget? bodyExtra,
}) {
  // Build the dialog text
  List<Widget> listBody = [body];
  if (bodyExtra != null) {
    listBody.add(const SizedBox(height: 14.0));
    listBody.add(bodyExtra);
  }

  return showAdaptiveDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog.adaptive(
        title: Text(AppString.confirm_title.translate()),
        content: SingleChildScrollView(
          child: ListBody(children: listBody),
        ),
        actions: [
          adaptiveDialogAction(
            isDefaultAction: true,
            text: AppString.no_button.translate(),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          adaptiveDialogAction(
            text: AppString.yes_button.translate(),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      );
    },
  );
}
