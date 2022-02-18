/*
 *******************************************************************************
 Package:  cuppa_mobile
 Class:    platform_adaptive.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2017-2022 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Cuppa platform adaptive elements
// - Light and dark themes for Android and iOS
// - PlatformAdaptiveAppBar from https://github.com/efortuna/memechat
// - PlatformAdaptiveDialog chooses showDialog type by context platform

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// iOS themes
final ThemeData kIOSTheme = ThemeData(
  primaryColor: Colors.grey[100],
  textTheme: Typography.blackCupertino
      .copyWith(button: const TextStyle(color: Colors.black54)),
  brightness: Brightness.light,
);
final ThemeData kIOSDarkTheme = ThemeData(
  primaryColor: Colors.grey[900],
  textTheme: Typography.whiteCupertino
      .copyWith(button: const TextStyle(color: Colors.grey)),
  brightness: Brightness.dark,
);

// Android themes
final ThemeData kDefaultTheme = ThemeData(
  primarySwatch: Colors.blue,
  textTheme: Typography.blackMountainView
      .copyWith(button: const TextStyle(color: Colors.black54)),
  brightness: Brightness.light,
);
final ThemeData kDarkTheme = ThemeData(
  primarySwatch: Colors.blue,
  textTheme: Typography.whiteMountainView
      .copyWith(button: const TextStyle(color: Colors.grey)),
  brightness: Brightness.dark,
);

// Get theme appropriate to platform
ThemeData getPlatformAdaptiveTheme(TargetPlatform platform) {
  return platform == TargetPlatform.iOS ? kIOSTheme : kDefaultTheme;
}

ThemeData getPlatformAdaptiveDarkTheme(TargetPlatform platform) {
  return platform == TargetPlatform.iOS ? kIOSDarkTheme : kDarkTheme;
}

// App bar that uses iOS styling on iOS
class PlatformAdaptiveAppBar extends AppBar {
  PlatformAdaptiveAppBar({
    Key? key,
    required TargetPlatform platform,
    List<Widget>? actions,
    required Widget title,
    Widget? body,
  }) : super(
          key: key,
          elevation: platform == TargetPlatform.iOS ? 0.0 : 4.0,
          title: title,
          actions: actions,
        );
}

// Alert dialog that is Material on Android and Cupertino on iOS
class PlatformAdaptiveDialog extends StatelessWidget {
  PlatformAdaptiveDialog({
    Key? key,
    required this.platform,
    required this.title,
    required this.content,
    required this.buttonTextTrue,
    required this.buttonTextFalse,
  }) : super(
          key: key,
        );

  final TargetPlatform platform;
  final Widget title;
  final Widget content;
  final String buttonTextTrue;
  final String buttonTextFalse;

  @override
  Widget build(BuildContext context) {
    if (platform == TargetPlatform.iOS) {
      return CupertinoAlertDialog(
        title: title,
        content: content,
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text(buttonTextTrue),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
          CupertinoDialogAction(
            child: Text(buttonTextFalse),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
        ],
      );
    } else {
      return AlertDialog(
        title: title,
        content: content,
        actions: <Widget>[
          TextButton(
            child: Text(buttonTextTrue),
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
            ),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
          TextButton(
            child: Text(buttonTextFalse),
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
            ),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
        ],
      );
    }
  }
}
