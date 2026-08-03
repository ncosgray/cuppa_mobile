/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    dialogs.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2026 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Generic dialogs
// - Confirmation dialog, informational dialog

import 'package:cuppa_mobile/common/padding.dart';
import 'package:cuppa_mobile/common/platform_adaptive.dart';
import 'package:cuppa_mobile/data/localization.dart';

import 'package:flutter/material.dart';

// Confirmation dialog with Yes/No options
Future showConfirmDialog({
  required BuildContext context,
  required Widget body,
  Widget? bodyExtra,
  bool isDestructiveAction = true,
}) {
  // Build the dialog text
  List<Widget> listBody = [body];
  if (bodyExtra != null) {
    listBody.add(bodyExtra);
  }

  return showAdaptiveDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return PlatformAdaptiveDialog(
        title: Text(AppString.confirm_title.translate()),
        message: SingleChildScrollView(
          child: Column(
            mainAxisSize: .min,
            spacing: smallSpacing,
            children: listBody,
          ),
        ),
        actions: [
          AdaptiveDialogAction(
            text: AppString.no_button.translate(),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          // The confirming action is the default one, so iOS gives it the
          // prominent filled treatment, trailing in the row of actions
          AdaptiveDialogAction(
            isDefaultAction: true,
            isDestructiveAction: isDestructiveAction,
            text: AppString.yes_button.translate(),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      );
    },
  );
}

// Information-only dialog without options
Future showInfoDialog({
  required BuildContext context,
  required String message,
}) {
  return showAdaptiveDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return PlatformAdaptiveDialog(
        message: SingleChildScrollView(child: Text(message)),
        actions: [
          AdaptiveDialogAction(
            isDefaultAction: true,
            text: AppString.ok_button.translate(),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    },
  );
}
